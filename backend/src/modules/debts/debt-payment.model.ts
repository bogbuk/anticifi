import {
  Table, Column, Model, DataType, PrimaryKey, Default,
  AllowNull, ForeignKey, BelongsTo, CreatedAt, UpdatedAt,
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';
import { Debt } from './debt.model.js';

@Table({
  tableName: 'debt_payments',
  timestamps: true,
  underscored: true,
  indexes: [
    { fields: ['debt_id'] },
    { fields: ['user_id'] },
    { fields: ['payment_date'] },
  ],
})
export class DebtPayment extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => Debt)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare debtId: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @AllowNull(false)
  @Column(DataType.DECIMAL(15, 2))
  declare amount: number;

  @AllowNull(false)
  @Column(DataType.DATEONLY)
  declare paymentDate: string;

  @AllowNull(true)
  @Column(DataType.STRING(1000))
  declare notes: string | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @BelongsTo(() => Debt)
  declare debt: Debt;

  @BelongsTo(() => User)
  declare user: User;
}
