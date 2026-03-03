import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { createWorker } from 'tesseract.js';
import * as path from 'path';
import * as fs from 'fs';
import { ReceiptScan, ReceiptStatus } from './receipt.model.js';
import { TransactionsService } from '../transactions/transactions.service.js';
import { ConfirmReceiptDto } from './dto/confirm-receipt.dto.js';

@Injectable()
export class ReceiptService {
  private readonly logger = new Logger(ReceiptService.name);
  private readonly uploadsDir = path.join(process.cwd(), 'uploads', 'receipts');

  constructor(
    @InjectModel(ReceiptScan)
    private readonly receiptModel: typeof ReceiptScan,
    private readonly transactionsService: TransactionsService,
  ) {
    if (!fs.existsSync(this.uploadsDir)) {
      fs.mkdirSync(this.uploadsDir, { recursive: true });
    }
  }

  async scanReceipt(
    userId: string,
    file: Express.Multer.File,
  ): Promise<ReceiptScan> {
    const filename = `${Date.now()}-${file.originalname}`;
    const filePath = path.join(this.uploadsDir, filename);
    fs.writeFileSync(filePath, file.buffer);

    const receipt = await this.receiptModel.create({
      userId,
      status: ReceiptStatus.PROCESSING,
      originalFilename: file.originalname,
      imagePath: filePath,
    } as any);

    try {
      const worker = await createWorker('eng');
      const { data } = await worker.recognize(filePath);
      await worker.terminate();

      const parsedData = this.parseOcrText(data.text);
      const confidence = data.confidence || 0;

      await receipt.update({
        status: ReceiptStatus.COMPLETED,
        parsedData,
        confidence,
      });
    } catch (error) {
      this.logger.error('OCR processing failed', error);
      await receipt.update({ status: ReceiptStatus.FAILED });
    }

    return receipt.reload();
  }

  async confirmReceipt(
    userId: string,
    receiptId: string,
    dto: ConfirmReceiptDto,
  ): Promise<any> {
    const receipt = await this.receiptModel.findOne({
      where: { id: receiptId, userId },
    });

    if (!receipt) {
      throw new NotFoundException('Receipt scan not found');
    }

    const transaction = await this.transactionsService.create(userId, {
      accountId: dto.accountId,
      amount: dto.amount,
      type: dto.type as any,
      description: dto.merchant || 'Receipt scan',
      date: dto.date,
      categoryId: dto.categoryId,
    });

    return transaction;
  }

  async getUserScans(userId: string): Promise<ReceiptScan[]> {
    return this.receiptModel.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']],
    });
  }

  private parseOcrText(text: string): {
    merchant?: string;
    amount?: number;
    date?: string;
    items?: Array<{ name: string; price: number }>;
    currency?: string;
  } {
    const lines = text.split('\n').map((l) => l.trim()).filter(Boolean);
    const result: any = {};

    if (lines.length > 0) {
      result.merchant = lines[0];
    }

    const totalPattern = /(?:total|amount|sum|due)[:\s]*\$?([\d,.]+)/i;
    for (const line of lines) {
      const match = line.match(totalPattern);
      if (match) {
        result.amount = parseFloat(match[1].replace(',', ''));
        break;
      }
    }

    if (!result.amount) {
      const amountPattern = /\$?([\d]+\.[\d]{2})/g;
      let maxAmount = 0;
      for (const line of lines) {
        let match;
        while ((match = amountPattern.exec(line)) !== null) {
          const val = parseFloat(match[1]);
          if (val > maxAmount) maxAmount = val;
        }
      }
      if (maxAmount > 0) result.amount = maxAmount;
    }

    const datePattern = /(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})/;
    for (const line of lines) {
      const match = line.match(datePattern);
      if (match) {
        result.date = match[1];
        break;
      }
    }

    const items: Array<{ name: string; price: number }> = [];
    const itemPattern = /^(.+?)\s+\$?([\d]+\.[\d]{2})$/;
    for (const line of lines) {
      const match = line.match(itemPattern);
      if (match && !line.match(/total|subtotal|tax|tip/i)) {
        items.push({ name: match[1].trim(), price: parseFloat(match[2]) });
      }
    }
    if (items.length > 0) result.items = items;

    if (text.includes('$')) result.currency = 'USD';
    else if (text.includes('€')) result.currency = 'EUR';
    else if (text.includes('£')) result.currency = 'GBP';

    return result;
  }
}
