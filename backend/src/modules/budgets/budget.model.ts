import {
  Table,
  Column,
  Model,
  DataType,
  PrimaryKey,
  Default,
  AllowNull,
  ForeignKey,
  BelongsTo,
  CreatedAt,
  UpdatedAt,
  DeletedAt,
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';
import { Category } from '../categories/category.model.js';

export enum BudgetPeriod {
  WEEKLY = 'weekly',
  MONTHLY = 'monthly',
  YEARLY = 'yearly',
}

@Table({
  tableName: 'budgets',
  timestamps: true,
  paranoid: true,
  underscored: true,
  indexes: [
    { fields: ['user_id', 'is_active'] },
    { fields: ['user_id', 'category_id'] },
  ],
})
export class Budget extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @ForeignKey(() => Category)
  @AllowNull(true)
  @Column(DataType.UUID)
  declare categoryId: string | null;

  @AllowNull(false)
  @Column(DataType.STRING(255))
  declare name: string;

  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare amount: number;

  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(BudgetPeriod)))
  declare period: BudgetPeriod;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  declare startDate: string;

  @AllowNull(true)
  @Column(DataType.DATEONLY)
  declare endDate: string | null;

  @Default(true)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isActive: boolean;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;

  @BelongsTo(() => User)
  declare user: User;

  @BelongsTo(() => Category)
  declare category: Category;
}
