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

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @BelongsTo(() => User)
  declare user: User;
}
