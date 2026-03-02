import {
  Table, Column, Model, DataType, PrimaryKey, Default,
  AllowNull, ForeignKey, BelongsTo, HasMany, CreatedAt, UpdatedAt, DeletedAt,
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';

export enum DebtType {
  CREDIT_CARD = 'credit_card',
  PERSONAL_LOAN = 'personal_loan',
  MORTGAGE = 'mortgage',
  AUTO_LOAN = 'auto_loan',
  STUDENT_LOAN = 'student_loan',
  PERSONAL = 'personal',
  OTHER = 'other',
}

@Table({
  tableName: 'debts',
  timestamps: true,
  paranoid: true,
  underscored: true,
  indexes: [
    { fields: ['user_id', 'is_active'] },
    { fields: ['user_id', 'is_paid_off'] },
  ],
})
export class Debt extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @AllowNull(false)
  @Column(DataType.STRING(255))
  declare name: string;

  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(DebtType)))
  declare type: DebtType;

  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare originalAmount: number;

  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare currentBalance: number;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.DECIMAL(5, 2))
  declare interestRate: number;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare minimumPayment: number;

  @AllowNull(true)
  @Column(DataType.INTEGER)
  declare dueDay: number | null;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  declare startDate: string;

  @AllowNull(true)
  @Column(DataType.DATEONLY)
  declare expectedPayoffDate: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(255))
  declare creditorName: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(1000))
  declare notes: string | null;

  @Default(true)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isActive: boolean;

  @Default(false)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isPaidOff: boolean;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;

  @BelongsTo(() => User)
  declare user: User;
}
