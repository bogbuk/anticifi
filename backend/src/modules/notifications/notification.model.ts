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

export enum NotificationType {
  BALANCE_ALERT = 'balance_alert',
  PAYMENT_REMINDER = 'payment_reminder',
  PREDICTION_ALERT = 'prediction_alert',
  BUDGET_ALERT = 'budget_alert',
  DEBT_PAYMENT_DUE = 'debt_payment_due',
  SYSTEM = 'system',
}

@Table({
  tableName: 'notifications',
  timestamps: true,
  underscored: true,
  indexes: [
    { fields: ['user_id', 'is_read'] },
    { fields: ['user_id', 'created_at'] },
  ],
})
export class Notification extends Model {
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
  declare title: string;

  @AllowNull(false)
  @Column(DataType.STRING(1000))
  declare body: string;

  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(NotificationType)))
  declare type: NotificationType;

  @Default(false)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isRead: boolean;

  @AllowNull(true)
  @Column(DataType.JSONB)
  declare metadata: Record<string, unknown> | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @BelongsTo(() => User)
  declare user: User;
}
