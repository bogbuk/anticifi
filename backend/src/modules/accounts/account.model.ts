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
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';
import { PlaidItem } from '../plaid/plaid-item.model.js';

export enum ConnectionType {
  MANUAL = 'manual',
  PLAID = 'plaid',
}

export enum AccountType {
  CHECKING = 'checking',
  SAVINGS = 'savings',
  CREDIT = 'credit',
  CASH = 'cash',
}

@Table({
  tableName: 'accounts',
  timestamps: true,
  underscored: true,
})
export class Account extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @AllowNull(false)
  @Column(DataType.STRING(100))
  declare name: string;

  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(AccountType)))
  declare type: AccountType;

  @AllowNull(true)
  @Column(DataType.STRING(100))
  declare bank: string | null;

  @Default('USD')
  @AllowNull(false)
  @Column(DataType.STRING(3))
  declare currency: string;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare balance: number;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare initialBalance: number;

  @Default(true)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isActive: boolean;

  @Default(ConnectionType.MANUAL)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(ConnectionType)))
  declare connectionType: ConnectionType;

  @AllowNull(true)
  @Column(DataType.STRING(100))
  declare plaidAccountId: string | null;

  @ForeignKey(() => PlaidItem)
  @AllowNull(true)
  @Column(DataType.UUID)
  declare plaidItemId: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(4))
  declare mask: string | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @BelongsTo(() => User)
  declare user: User;

  @BelongsTo(() => PlaidItem)
  declare plaidItem: PlaidItem;
}
