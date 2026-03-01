import {
  Table,
  Column,
  Model,
  DataType,
  PrimaryKey,
  Default,
  AllowNull,
  Unique,
  ForeignKey,
  BelongsTo,
  CreatedAt,
  UpdatedAt,
  DeletedAt,
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';
import { Account } from '../accounts/account.model.js';
import { Category } from '../categories/category.model.js';

export enum TransactionType {
  INCOME = 'income',
  EXPENSE = 'expense',
}

@Table({
  tableName: 'transactions',
  timestamps: true,
  paranoid: true,
  underscored: true,
  indexes: [
    { fields: ['account_id', 'date'] },
    { fields: ['user_id', 'date'] },
    { fields: ['transaction_hash'], unique: true },
  ],
})
export class Transaction extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => Account)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare accountId: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare amount: number;

  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(TransactionType)))
  declare type: TransactionType;

  @AllowNull(true)
  @Column(DataType.STRING(500))
  declare description: string | null;

  @ForeignKey(() => Category)
  @AllowNull(true)
  @Column(DataType.UUID)
  declare categoryId: string | null;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  declare date: string;

  @Unique
  @AllowNull(true)
  @Column(DataType.STRING(64))
  declare transactionHash: string | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;

  @BelongsTo(() => Account)
  declare account: Account;

  @BelongsTo(() => User)
  declare user: User;

  @BelongsTo(() => Category)
  declare category: Category;
}
