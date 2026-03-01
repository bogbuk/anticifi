import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op } from 'sequelize';
import { Category } from './category.model.js';
import { CreateCategoryDto } from './dto/create-category.dto.js';
import { UpdateCategoryDto } from './dto/update-category.dto.js';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectModel(Category)
    private readonly categoryModel: typeof Category,
  ) {}

  async findAll(userId: string): Promise<Category[]> {
    return this.categoryModel.findAll({
      where: {
        [Op.or]: [{ isDefault: true }, { userId }],
      },
      include: [{ model: Category, as: 'children' }],
      order: [['name', 'ASC']],
    });
  }

  async create(userId: string, dto: CreateCategoryDto): Promise<Category> {
    return this.categoryModel.create({
      userId,
      name: dto.name,
      icon: dto.icon,
      color: dto.color,
      parentId: dto.parentId,
      isDefault: false,
    } as any);
  }

  async update(
    id: string,
    userId: string,
    dto: UpdateCategoryDto,
  ): Promise<Category> {
    const category = await this.categoryModel.findOne({
      where: { id, userId },
    });
    if (!category) {
      throw new NotFoundException('Category not found');
    }
    if (category.isDefault) {
      throw new ForbiddenException('Cannot update system categories');
    }
    await category.update(dto);
    return category;
  }

  async remove(id: string, userId: string): Promise<void> {
    const category = await this.categoryModel.findOne({
      where: { id, userId },
    });
    if (!category) {
      throw new NotFoundException('Category not found');
    }
    if (category.isDefault) {
      throw new ForbiddenException('Cannot delete system categories');
    }
    await category.destroy();
  }

  async seed(): Promise<void> {
    const count = await this.categoryModel.count({
      where: { isDefault: true },
    });
    if (count > 0) {
      return;
    }

    const defaults = [
      { name: 'Food', icon: 'restaurant', color: '#FF6B6B' },
      { name: 'Transport', icon: 'directions_car', color: '#4ECDC4' },
      { name: 'Housing', icon: 'home', color: '#45B7D1' },
      { name: 'Entertainment', icon: 'movie', color: '#96CEB4' },
      { name: 'Shopping', icon: 'shopping_bag', color: '#FFEAA7' },
      { name: 'Health', icon: 'local_hospital', color: '#DDA0DD' },
      { name: 'Salary', icon: 'account_balance_wallet', color: '#98D8C8' },
      { name: 'Freelance', icon: 'work', color: '#F7DC6F' },
      { name: 'Other', icon: 'more_horiz', color: '#BDC3C7' },
    ];

    await this.categoryModel.bulkCreate(
      defaults.map((d) => ({
        ...d,
        isDefault: true,
        userId: null,
      })) as any[],
    );
  }
}
