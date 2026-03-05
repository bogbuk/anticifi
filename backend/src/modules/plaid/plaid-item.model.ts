import {
  Table,
  Column,
  Model,
  DataType,
  PrimaryKey,
  Default,
  ForeignKey,
  BelongsTo,
  AllowNull,
  HasMany,
} from 'sequelize-typescript';
import { User } from '../users/user.model';
import { Account } from '../accounts/account.model';

export enum PlaidItemStatus {
  ACTIVE = 'active',
  ERROR = 'error',
  PENDING_EXPIRATION = 'pending_expiration',
  REVOKED = 'revoked',
}

@Table({
  tableName: 'plaid_items',
  timestamps: true,
  paranoid: true,
  underscored: true,
})
export class PlaidItem extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @AllowNull(false)
  @Column({ type: DataType.STRING(100), unique: true, field: 'item_id' })
  declare itemId: string;

  @AllowNull(false)
  @Column(DataType.TEXT)
  declare accessToken: string;

  @AllowNull(true)
  @Column(DataType.STRING(50))
  declare institutionId: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(200))
  declare institutionName: string | null;

  @Default(PlaidItemStatus.ACTIVE)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(PlaidItemStatus)))
  declare status: PlaidItemStatus;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare consentExpiresAt: Date | null;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare lastSyncedAt: Date | null;

  @AllowNull(true)
  @Column(DataType.TEXT)
  declare cursor: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(100))
  declare errorCode: string | null;

  @AllowNull(true)
  @Column(DataType.TEXT)
  declare errorMessage: string | null;

  @BelongsTo(() => User)
  declare user: User;

  @HasMany(() => Account)
  declare accounts: Account[];
}
