import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { ImportJob, ImportJobStatus, ImportFormat } from './import-job.model.js';
import { Transaction, TransactionType } from '../transactions/transaction.model.js';
import { TransactionsService } from '../transactions/transactions.service.js';

interface ParsedRow {
  date: string;
  description: string;
  amount: number;
  type: TransactionType;
}

@Injectable()
export class ImportService {
  constructor(
    @InjectModel(ImportJob)
    private readonly importJobModel: typeof ImportJob,
    @InjectModel(Transaction)
    private readonly transactionModel: typeof Transaction,
    private readonly transactionsService: TransactionsService,
  ) {}

  async createImportJob(
    userId: string,
    accountId: string,
    format: ImportFormat,
  ): Promise<ImportJob> {
    return this.importJobModel.create({
      userId,
      accountId,
      format,
      status: ImportJobStatus.PENDING,
    } as any);
  }

  async processCSV(jobId: string, csvContent: string): Promise<ImportJob> {
    const job = await this.importJobModel.findByPk(jobId);
    if (!job) {
      throw new NotFoundException('Import job not found');
    }

    await job.update({
      status: ImportJobStatus.PROCESSING,
      startedAt: new Date(),
    });

    let importedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;
    const errorDetails: Array<{ line: number; error: string }> = [];

    const lines = csvContent.split('\n').filter((line) => line.trim());

    // Skip header line
    const dataLines = lines.length > 1 ? lines.slice(1) : lines;

    for (let i = 0; i < dataLines.length; i++) {
      try {
        const parsed = this.parseCSVRow(dataLines[i]);
        if (!parsed) {
          skippedCount++;
          continue;
        }

        const transactionHash = this.transactionsService.generateHash(
          job.accountId,
          parsed.amount,
          parsed.date,
          parsed.description,
        );

        // Check for duplicates
        const existing = await this.transactionModel.findOne({
          where: { transactionHash },
        });

        if (existing) {
          skippedCount++;
          continue;
        }

        await this.transactionModel.create({
          userId: job.userId,
          accountId: job.accountId,
          amount: parsed.amount,
          type: parsed.type,
          description: parsed.description,
          date: parsed.date,
          transactionHash,
        } as any);

        importedCount++;
      } catch (err: any) {
        errorCount++;
        errorDetails.push({
          line: i + 2, // +2 for 1-based index + header
          error: err.message || 'Unknown error',
        });
      }
    }

    // Recalculate account balance
    await this.transactionsService.recalculateBalance(job.accountId);

    const finalStatus =
      errorCount > 0 && importedCount === 0
        ? ImportJobStatus.FAILED
        : ImportJobStatus.COMPLETED;

    await job.update({
      status: finalStatus,
      importedCount,
      skippedCount,
      errorCount,
      errorDetails: errorDetails.length > 0 ? errorDetails : null,
      completedAt: new Date(),
    });

    return job;
  }

  async getJobStatus(jobId: string, userId: string): Promise<ImportJob> {
    const job = await this.importJobModel.findOne({
      where: { id: jobId, userId },
    });
    if (!job) {
      throw new NotFoundException('Import job not found');
    }
    return job;
  }

  async getJobs(userId: string): Promise<ImportJob[]> {
    return this.importJobModel.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']],
    });
  }

  parseCSVRow(row: string): ParsedRow | null {
    if (!row || !row.trim()) {
      return null;
    }

    // Handle quoted CSV fields
    const fields: string[] = [];
    let current = '';
    let inQuotes = false;

    for (const char of row) {
      if (char === '"') {
        inQuotes = !inQuotes;
      } else if (char === ',' && !inQuotes) {
        fields.push(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    fields.push(current.trim());

    if (fields.length < 3) {
      throw new BadRequestException(`Invalid CSV row: expected at least 3 fields, got ${fields.length}`);
    }

    // Expected format: date, description, amount
    const dateStr = fields[0];
    const description = fields[1];
    const amountStr = fields[2];

    // Parse date — support various formats
    const date = this.parseDate(dateStr);
    if (!date) {
      throw new BadRequestException(`Invalid date format: ${dateStr}`);
    }

    // Parse amount — handle comma/dot decimal, negative for expenses
    const amount = this.parseAmount(amountStr);
    if (amount === null || isNaN(amount)) {
      throw new BadRequestException(`Invalid amount format: ${amountStr}`);
    }

    const type = amount < 0 ? TransactionType.EXPENSE : TransactionType.INCOME;

    return {
      date,
      description,
      amount: Math.abs(amount),
      type,
    };
  }

  private parseDate(dateStr: string): string | null {
    // Try ISO format (YYYY-MM-DD)
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
      return dateStr;
    }
    // Try DD/MM/YYYY or DD.MM.YYYY
    const dmyMatch = dateStr.match(/^(\d{1,2})[./](\d{1,2})[./](\d{4})$/);
    if (dmyMatch) {
      const [, day, month, year] = dmyMatch;
      return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
    }
    // Try MM/DD/YYYY
    const mdyMatch = dateStr.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
    if (mdyMatch) {
      const [, month, day, year] = mdyMatch;
      return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
    }
    return null;
  }

  private parseAmount(amountStr: string): number | null {
    // Remove currency symbols and whitespace
    let cleaned = amountStr.replace(/[^0-9.,\-+]/g, '').trim();
    if (!cleaned) {
      return null;
    }

    // Handle European format: 1.234,56 → 1234.56
    if (/\d+\.\d{3},\d{2}$/.test(cleaned)) {
      cleaned = cleaned.replace(/\./g, '').replace(',', '.');
    }
    // Handle comma as decimal separator: 1234,56 → 1234.56
    else if (/,\d{2}$/.test(cleaned)) {
      cleaned = cleaned.replace(',', '.');
    }

    const value = parseFloat(cleaned);
    return isNaN(value) ? null : value;
  }
}
