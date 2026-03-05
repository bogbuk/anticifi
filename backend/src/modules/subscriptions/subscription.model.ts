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
  Index,
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';

export enum SubscriptionTier {
  FREE = 'free',
  PREMIUM = 'premium',
}

export enum SubscriptionPeriod {
  MONTHLY = 'monthly',
  YEARLY = 'yearly',
  LIFETIME = 'lifetime',
}

export enum SubscriptionStatus {
  ACTIVE = 'active',
  EXPIRED = 'expired',
  CANCELLED = 'cancelled',
  GRACE_PERIOD = 'grace_period',
  BILLING_RETRY = 'billing_retry',
}

@Table({
  tableName: 'subscriptions',
  timestamps: true,
  underscored: true,
  indexes: [
    { fields: ['user_id'], unique: true },
    { fields: ['revenuecat_id'] },
  ],
})
export class Subscription extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @ForeignKey(() => User)
  @AllowNull(false)
  @Column(DataType.UUID)
  declare userId: string;

  @BelongsTo(() => User)
  declare user: User;

  @Default(SubscriptionTier.FREE)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(SubscriptionTier)))
  declare tier: SubscriptionTier;

  @Default(SubscriptionStatus.ACTIVE)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(SubscriptionStatus)))
  declare status: SubscriptionStatus;

  @AllowNull(true)
  @Column(DataType.ENUM(...Object.values(SubscriptionPeriod)))
  declare period: SubscriptionPeriod | null;

  @AllowNull(true)
  @Column(DataType.STRING(255))
  declare revenuecatId: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(100))
  declare productId: string | null;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare expiresAt: Date | null;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare originalPurchaseDate: Date | null;

  @AllowNull(true)
  @Column(DataType.STRING(20))
  declare store: string | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  get isPremium(): boolean {
    return (
      this.tier === SubscriptionTier.PREMIUM &&
      this.status === SubscriptionStatus.ACTIVE &&
      (!this.expiresAt || this.expiresAt > new Date())
    );
  }
}
