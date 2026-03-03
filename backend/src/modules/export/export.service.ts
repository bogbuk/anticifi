import { Injectable } from '@nestjs/common';
import { Parser } from 'json2csv';
import PDFDocument from 'pdfkit';
import { TransactionsService } from '../transactions/transactions.service.js';
import { AccountsService } from '../accounts/accounts.service.js';
import { TransactionType } from '../transactions/transaction.model.js';

export interface ExportQuery {
  startDate?: string;
  endDate?: string;
  accountId?: string;
  type?: string;
}

@Injectable()
export class ExportService {
  constructor(
    private readonly transactionsService: TransactionsService,
    private readonly accountsService: AccountsService,
  ) {}

  async exportCSV(userId: string, query: ExportQuery): Promise<string> {
    const result = await this.transactionsService.findAll(userId, {
      startDate: query.startDate,
      endDate: query.endDate,
      accountId: query.accountId,
      type: query.type as TransactionType | undefined,
      limit: '10000',
      page: '1',
    });

    const data = result.data.map((tx: any) => ({
      Date: tx.date,
      Description: tx.description || '',
      Amount: Number(tx.amount).toFixed(2),
      Type: tx.type,
      Category: tx.category?.name || 'Uncategorized',
      Account: tx.account?.name || '',
    }));

    const parser = new Parser({
      fields: ['Date', 'Description', 'Amount', 'Type', 'Category', 'Account'],
    });

    return parser.parse(data);
  }

  async exportPDF(userId: string, query: ExportQuery): Promise<typeof PDFDocument.prototype> {
    const result = await this.transactionsService.findAll(userId, {
      startDate: query.startDate,
      endDate: query.endDate,
      accountId: query.accountId,
      type: query.type as TransactionType | undefined,
      limit: '10000',
      page: '1',
    });

    const doc = new PDFDocument({ margin: 50 });

    // Header
    doc.fontSize(20).text('AnticiFi - Transaction Report', { align: 'center' });
    doc.moveDown(0.5);

    // Period
    const period = [
      query.startDate ? `From: ${query.startDate}` : '',
      query.endDate ? `To: ${query.endDate}` : '',
    ]
      .filter(Boolean)
      .join('  |  ');
    if (period) {
      doc.fontSize(10).text(period, { align: 'center' });
    }
    doc.moveDown();

    // Summary
    let totalIncome = 0;
    let totalExpense = 0;
    result.data.forEach((tx: any) => {
      const amount = Number(tx.amount);
      if (tx.type === 'income') totalIncome += amount;
      else totalExpense += amount;
    });

    doc.fontSize(12).text('Summary', { underline: true });
    doc.fontSize(10)
      .text(`Total Transactions: ${result.data.length}`)
      .text(`Total Income: $${totalIncome.toFixed(2)}`)
      .text(`Total Expenses: $${totalExpense.toFixed(2)}`)
      .text(`Net: $${(totalIncome - totalExpense).toFixed(2)}`);
    doc.moveDown();

    // Table header
    doc.fontSize(12).text('Transactions', { underline: true });
    doc.moveDown(0.5);

    const tableTop = doc.y;
    const colWidths = [70, 170, 70, 60, 80];
    const headers = ['Date', 'Description', 'Amount', 'Type', 'Category'];

    doc.fontSize(8).font('Helvetica-Bold');
    let xPos = 50;
    headers.forEach((header, i) => {
      doc.text(header, xPos, tableTop, { width: colWidths[i] });
      xPos += colWidths[i];
    });

    doc.font('Helvetica').fontSize(8);
    let yPos = tableTop + 15;

    for (const tx of result.data as any[]) {
      if (yPos > 700) {
        doc.addPage();
        yPos = 50;
      }

      xPos = 50;
      const row = [
        tx.date,
        (tx.description || '').substring(0, 30),
        `$${Number(tx.amount).toFixed(2)}`,
        tx.type,
        tx.category?.name || '-',
      ];

      row.forEach((cell, i) => {
        doc.text(cell, xPos, yPos, { width: colWidths[i] });
        xPos += colWidths[i];
      });

      yPos += 14;
    }

    doc.end();
    return doc;
  }
}
