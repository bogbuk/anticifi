import {
  Table, Column, Model, DataType, PrimaryKey, Default,
  AllowNull, ForeignKey, BelongsTo, CreatedAt, UpdatedAt, DeletedAt,
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';

export enum ReceiptStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Table({
  tableName: 'receipt_scans',
  timestamps: true,
  paranoid: true,
  underscored: true,
  indexes: [
    { fields: ['user_id', 'status'] },
  ],
})
export class ReceiptScan extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @Default(ReceiptStatus.PENDING)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(ReceiptStatus)))
  declare status: ReceiptStatus;

  @AllowNull(false)
  @Column(DataType.STRING(255))
  declare originalFilename: string;

  @AllowNull(false)
  @Column(DataType.STRING(500))
  declare imagePath: string;

  @AllowNull(true)
  @Column(DataType.JSONB)
  declare parsedData: {
    merchant?: string;
    amount?: number;
    date?: string;
    items?: Array<{ name: string; price: number }>;
    currency?: string;
  } | null;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.DECIMAL(5, 2))
  declare confidence: number;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;

  @BelongsTo(() => User)
  declare user: User;
}
