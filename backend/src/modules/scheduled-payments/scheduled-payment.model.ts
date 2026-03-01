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
import { Account } from '../accounts/account.model.js';
import { Category } from '../categories/category.model.js';

export enum ScheduledPaymentType {
  INCOME = 'income',
  EXPENSE = 'expense',
}

export enum PaymentFrequency {
  DAILY = 'daily',
  WEEKLY = 'weekly',
  BIWEEKLY = 'biweekly',
  MONTHLY = 'monthly',
  QUARTERLY = 'quarterly',
  YEARLY = 'yearly',
}

@Table({
  tableName: 'scheduled_payments',
  timestamps: true,
  paranoid: true,
  underscored: true,
  indexes: [
    { fields: ['user_id', 'is_active'] },
    { fields: ['next_execution_date', 'is_active'] },
  ],
})
export class ScheduledPayment extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @ForeignKey(() => Account)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare accountId: string;

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
  @Column(DataType.ENUM(...Object.values(ScheduledPaymentType)))
  declare type: ScheduledPaymentType;

  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(PaymentFrequency)))
  declare frequency: PaymentFrequency;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  declare startDate: string;

  @AllowNull(true)
  @Column(DataType.DATEONLY)
  declare endDate: string | null;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  declare nextExecutionDate: string;

  @Default(true)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isActive: boolean;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare lastExecutedAt: Date | null;

  @AllowNull(true)
  @Column(DataType.STRING(500))
  declare description: string | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;

  @BelongsTo(() => User)
  declare user: User;

  @BelongsTo(() => Account)
  declare account: Account;

  @BelongsTo(() => Category)
  declare category: Category;
}
