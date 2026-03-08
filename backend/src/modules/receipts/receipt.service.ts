import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op } from 'sequelize';
import { createWorker } from 'tesseract.js';
import * as path from 'path';
import * as fs from 'fs';
import { ReceiptScan, ReceiptStatus } from './receipt.model.js';
import { TransactionsService } from '../transactions/transactions.service.js';
import { SubscriptionsService } from '../subscriptions/subscriptions.service.js';
import { ConfirmReceiptDto } from './dto/confirm-receipt.dto.js';

const FREE_DAILY_SCAN_LIMIT = 5;

@Injectable()
export class ReceiptService {
  private readonly logger = new Logger(ReceiptService.name);
  private readonly uploadsDir = path.join(process.cwd(), 'uploads', 'receipts');

  constructor(
    @InjectModel(ReceiptScan)
    private readonly receiptModel: typeof ReceiptScan,
    private readonly transactionsService: TransactionsService,
    private readonly subscriptionsService: SubscriptionsService,
  ) {
    if (!fs.existsSync(this.uploadsDir)) {
      fs.mkdirSync(this.uploadsDir, { recursive: true });
    }
  }

  private async checkDailyLimit(userId: string): Promise<void> {
    const isPremium = await this.subscriptionsService.isPremiumUser(userId);
    if (isPremium) return;

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const todayCount = await this.receiptModel.count({
      where: {
        userId,
        createdAt: { [Op.gte]: todayStart },
      },
    });

    if (todayCount >= FREE_DAILY_SCAN_LIMIT) {
      throw new ForbiddenException(
        `Free plan is limited to ${FREE_DAILY_SCAN_LIMIT} receipt scans per day. Upgrade to Premium for unlimited scans.`,
      );
    }
  }

  async scanReceipt(
    userId: string,
    file: Express.Multer.File,
  ): Promise<ReceiptScan> {
    // TODO: re-enable after testing
    // await this.checkDailyLimit(userId);
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
      const worker = await createWorker('eng+fra+deu+spa+ron');
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

  private parseAmount(raw: string): number | null {
    let cleaned = raw.replace(/[€$£\s]/g, '').trim();
    // European format: 1.234,56
    if (/^\d{1,3}(\.\d{3})*(,\d{2})$/.test(cleaned)) {
      cleaned = cleaned.replace(/\./g, '').replace(',', '.');
    }
    // US format: 1,234.56
    else if (/^\d{1,3}(,\d{3})*(\.\d{2})$/.test(cleaned)) {
      cleaned = cleaned.replace(/,/g, '');
    }
    // Simple comma decimal: 9,00
    else if (/^\d+,\d{2}$/.test(cleaned)) {
      cleaned = cleaned.replace(',', '.');
    }
    const val = parseFloat(cleaned);
    return isNaN(val) || val <= 0 ? null : val;
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

    // --- Currency detection (¢ is common OCR misread of €) ---
    if (/\bMDL\b/.test(text)) result.currency = 'MDL';
    else if (/\bRON\b|\bLEI\b/i.test(text)) result.currency = 'RON';
    else if (text.includes('€') || text.includes('¢') || /\bEUR\b/.test(text)) result.currency = 'EUR';
    else if (text.includes('£') || /\bGBP\b/.test(text)) result.currency = 'GBP';
    else if (text.includes('$') || /\bUSD\b/.test(text)) result.currency = 'USD';

    // --- Merchant: try labeled field first (RO: Comerciant, FR: Marchand, etc.) ---
    const merchantLabel = /(?:comerciant|merchant|marchand|händler)[:\s]+(.+)/i;
    for (const line of lines) {
      const match = line.match(merchantLabel);
      if (match) {
        result.merchant = match[1].trim();
        break;
      }
    }

    // Fallback: first meaningful line (5+ alpha chars)
    if (!result.merchant) {
      const skipMerchant = /^tel\b|^\d+\s*(rue|st|ave|blvd|road|str|sos\.|adresa)/i;
      for (const line of lines) {
        const clean = line.replace(/[^a-zA-Z\u00C0-\u024F0-9\s\-'.]/g, '').trim();
        const alphaCount = (clean.match(/[a-zA-Z\u00C0-\u024F]/g) || []).length;
        if (alphaCount >= 5 && !skipMerchant.test(line)) {
          result.merchant = clean;
          break;
        }
      }
    }

    // Currency symbols including common OCR misreads (¢ for €)
    const cur = '[$\u20AC\u00A3\u00A2]';
    // --- Total amount (multi-language) ---
    const totalPatterns = [
      // FR: Total a payer, Montant, Total TTC
      new RegExp(`(?:total\\s*(?:a|à)\\s*payer|montant\\s*(?:total|ttc)?|total\\s*ttc)[:\\s|]*${cur}?\\s*([\\d.,]+)\\s*${cur}?`, 'i'),
      // EN: Total, Amount Due, Grand Total
      new RegExp(`(?:grand\\s*total|total\\s*due|balance\\s*due|amount\\s*due|total)[:\\s|]*${cur}?\\s*([\\d.,]+)\\s*${cur}?`, 'i'),
      // DE: Gesamtbetrag, Summe
      new RegExp(`(?:gesamtbetrag|summe|gesamt|zu\\s*zahlen)[:\\s|]*${cur}?\\s*([\\d.,]+)\\s*${cur}?`, 'i'),
      // ES: Total a pagar, Importe
      new RegExp(`(?:total\\s*a\\s*pagar|importe\\s*total|importe)[:\\s|]*${cur}?\\s*([\\d.,]+)\\s*${cur}?`, 'i'),
      // RO: Suma, Total de plata
      new RegExp(`(?:suma|total\\s*de\\s*plat[aă])[:\\s|]*${cur}?\\s*([\\d.,]+)\\s*(?:MDL|RON|LEI)?`, 'i'),
    ];

    for (const pattern of totalPatterns) {
      for (const line of lines) {
        const match = line.match(pattern);
        if (match) {
          const amount = this.parseAmount(match[1]);
          if (amount) {
            result.amount = amount;
            break;
          }
        }
      }
      if (result.amount) break;
    }

    // Fallback: find the largest price-like value, skipping lines with phone/address
    if (!result.amount) {
      const pricePattern = new RegExp(`${cur}?\\s*([\\d]+[.,]\\d{2})\\s*${cur}?`, 'g');
      const skipFallback = /tel|phone|fax|rue|street|addr/i;
      let maxAmount = 0;
      for (const line of lines) {
        if (skipFallback.test(line)) continue;
        let match;
        while ((match = pricePattern.exec(line)) !== null) {
          const val = this.parseAmount(match[1]);
          if (val && val > maxAmount) maxAmount = val;
        }
      }
      if (maxAmount > 0) result.amount = maxAmount;
    }

    // --- Date ---
    const datePattern = /(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})/;
    for (const line of lines) {
      const match = line.match(datePattern);
      if (match) {
        result.date = match[1];
        break;
      }
    }

    // --- Items ---
    const items: Array<{ name: string; price: number }> = [];
    const skipItems = /total|subtotal|sub.total|tax|tip|tva|montant|payer|summe|gesamt|importe|balance|change|visa|master|carte|cb\s|emv|article|suma|achitare|reusit|comerciant|locatie|adresa|terminal|autorizare|tranzactie|contactless|returnare|multumim|suport/i;
    const itemPatternRe = new RegExp(`^(.+?)\\s+${cur}?\\s*([\\d]+[.,]\\d{2})\\s*${cur}?\\s*$`);
    for (const line of lines) {
      if (skipItems.test(line)) continue;
      const match = line.match(itemPatternRe);
      if (match) {
        const price = this.parseAmount(match[2]);
        if (price && price < 10000) {
          items.push({ name: match[1].replace(/^\*+/, '').trim(), price });
        }
      }
    }
    if (items.length > 0) result.items = items;

    return result;
  }
}
