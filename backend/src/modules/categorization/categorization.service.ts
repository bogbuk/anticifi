import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { TransactionsService } from '../transactions/transactions.service.js';
import { CategorizeTransactionDto } from './dto/categorize.dto.js';
import { InjectModel } from '@nestjs/sequelize';
import { Category } from '../categories/category.model.js';

export interface CategorySuggestion {
  categoryId: string;
  categoryName: string;
  confidence: number;
}

@Injectable()
export class CategorizationService {
  private readonly logger = new Logger(CategorizationService.name);
  private readonly mlServiceUrl: string;

  constructor(
    private readonly transactionsService: TransactionsService,
    private readonly configService: ConfigService,
    @InjectModel(Category)
    private readonly categoryModel: typeof Category,
  ) {
    this.mlServiceUrl =
      this.configService.get('ML_SERVICE_URL') || 'http://localhost:8000';
  }

  async suggestCategories(
    userId: string,
    dto: CategorizeTransactionDto,
  ): Promise<CategorySuggestion[]> {
    try {
      const history = await this.transactionsService.findAll(userId, {
        limit: '100',
        page: '1',
      });

      const transactions = history.data.map((tx: any) => ({
        description: tx.description || '',
        categoryId: tx.categoryId,
        categoryName: tx.category?.name || null,
        amount: Number(tx.amount),
        type: tx.type,
      }));

      const categories = await this.categoryModel.findAll({
        where: { userId },
      });

      const response = await axios.post(
        `${this.mlServiceUrl}/api/categorize`,
        {
          description: dto.description,
          type: dto.type,
          amount: dto.amount,
          history: transactions,
          categories: categories.map((c: any) => ({
            id: c.id,
            name: c.name,
          })),
        },
        { timeout: 5000 },
      );

      return response.data.suggestions || [];
    } catch (error) {
      this.logger.warn('ML categorization failed, falling back to keywords');
      return this.keywordFallback(userId, dto.description);
    }
  }

  private async keywordFallback(
    userId: string,
    description: string,
  ): Promise<CategorySuggestion[]> {
    const categories = await this.categoryModel.findAll({
      where: { userId },
    });

    const keywords: Record<string, string[]> = {
      'Food & Dining': ['restaurant', 'cafe', 'coffee', 'food', 'pizza', 'burger', 'lunch', 'dinner', 'breakfast', 'grocery', 'supermarket'],
      'Transportation': ['uber', 'lyft', 'taxi', 'gas', 'fuel', 'parking', 'metro', 'bus', 'train'],
      'Shopping': ['amazon', 'store', 'shop', 'mall', 'purchase', 'buy'],
      'Entertainment': ['movie', 'netflix', 'spotify', 'gaming', 'concert', 'theater'],
      'Bills & Utilities': ['electric', 'water', 'internet', 'phone', 'insurance', 'rent'],
      'Health': ['pharmacy', 'doctor', 'hospital', 'clinic', 'medicine', 'gym', 'fitness'],
      'Salary': ['salary', 'payroll', 'wages', 'income', 'deposit'],
    };

    const desc = description.toLowerCase();
    const suggestions: CategorySuggestion[] = [];

    for (const [categoryName, kws] of Object.entries(keywords)) {
      const matchCount = kws.filter((kw) => desc.includes(kw)).length;
      if (matchCount > 0) {
        const cat = categories.find(
          (c: any) => c.name.toLowerCase() === categoryName.toLowerCase(),
        );
        if (cat) {
          suggestions.push({
            categoryId: (cat as any).id,
            categoryName: (cat as any).name,
            confidence: Math.min(0.9, 0.3 + matchCount * 0.2),
          });
        }
      }
    }

    return suggestions
      .sort((a, b) => b.confidence - a.confidence)
      .slice(0, 3);
  }
}
