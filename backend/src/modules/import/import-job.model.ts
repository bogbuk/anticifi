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

export enum ImportJobStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

export enum ImportFormat {
  CSV = 'csv',
  OCR = 'ocr',
}

@Table({
  tableName: 'import_jobs',
  timestamps: true,
  paranoid: true,
  underscored: true,
})
export class ImportJob extends Model {
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

  @Default(ImportJobStatus.PENDING)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(ImportJobStatus)))
  declare status: ImportJobStatus;

  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(ImportFormat)))
  declare format: ImportFormat;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.INTEGER)
  declare importedCount: number;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.INTEGER)
  declare skippedCount: number;

  @Default(0)
  @AllowNull(false)
  @Column(DataType.INTEGER)
  declare errorCount: number;

  @AllowNull(true)
  @Column(DataType.JSON)
  declare errorDetails: any;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare startedAt: Date | null;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare completedAt: Date | null;

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
}
