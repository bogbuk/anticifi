import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { ConfigService } from '@nestjs/config';
import {
  Subscription,
  SubscriptionTier,
  SubscriptionStatus,
} from './subscription.model.js';
import { EventsGateway } from '../events/events.gateway.js';

const FREE_ACCOUNT_LIMIT = 2;

export interface SubscriptionInfo {
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  isPremium: boolean;
  expiresAt: Date | null;
  period: string | null;
  entitlements: string[];
}

const PREMIUM_ENTITLEMENTS = [
  'unlimited_accounts',
  'plaid',
  'ocr_receipts',
  'oracle_predictions',
  'ml_categorization',
  'budgets',
  'debts',
  'export',
  'multi_currency',
];

@Injectable()
export class SubscriptionsService {
  private readonly logger = new Logger(SubscriptionsService.name);

  constructor(
    @InjectModel(Subscription)
    private readonly subscriptionModel: typeof Subscription,
    private readonly eventsGateway: EventsGateway,
    private readonly configService: ConfigService,
  ) {}

  async getOrCreateSubscription(userId: string): Promise<Subscription> {
    let subscription = await this.subscriptionModel.findOne({
      where: { userId },
    });

    if (!subscription) {
      subscription = await this.subscriptionModel.create({
        userId,
        tier: SubscriptionTier.FREE,
        status: SubscriptionStatus.ACTIVE,
      } as any);
    }

    return subscription;
  }

  async getSubscriptionInfo(userId: string): Promise<SubscriptionInfo> {
    const subscription = await this.getOrCreateSubscription(userId);
    const isPremium = subscription.isPremium;

    return {
      tier: subscription.tier,
      status: subscription.status,
      isPremium,
      expiresAt: subscription.expiresAt,
      period: subscription.period,
      entitlements: isPremium ? PREMIUM_ENTITLEMENTS : [],
    };
  }

  async isPremiumUser(userId: string): Promise<boolean> {
    const subscription = await this.subscriptionModel.findOne({
      where: { userId },
    });
    return subscription?.isPremium ?? false;
  }

  async checkAccountLimit(userId: string, currentCount: number): Promise<void> {
    const isPremium = await this.isPremiumUser(userId);
    if (!isPremium && currentCount >= FREE_ACCOUNT_LIMIT) {
      throw new ForbiddenException(
        `Free plan is limited to ${FREE_ACCOUNT_LIMIT} accounts. Upgrade to Premium for unlimited accounts.`,
      );
    }
  }

  async handleWebhookEvent(event: any): Promise<void> {
    const { type, app_user_id, product_id, expiration_at_ms, period_type, store } = event;

    this.logger.log(`RevenueCat webhook: ${type} for user ${app_user_id}`);

    const subscription = await this.getOrCreateSubscription(app_user_id);

    switch (type) {
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
      case 'PRODUCT_CHANGE':
        await subscription.update({
          tier: SubscriptionTier.PREMIUM,
          status: SubscriptionStatus.ACTIVE,
          productId: product_id,
          expiresAt: expiration_at_ms ? new Date(expiration_at_ms) : null,
          period: period_type === 'ANNUAL' ? 'yearly' : 'monthly',
          store,
          originalPurchaseDate:
            type === 'INITIAL_PURCHASE' ? new Date() : subscription.originalPurchaseDate,
        });
        break;

      case 'CANCELLATION':
        await subscription.update({
          status: SubscriptionStatus.CANCELLED,
        });
        break;

      case 'EXPIRATION':
        await subscription.update({
          tier: SubscriptionTier.FREE,
          status: SubscriptionStatus.EXPIRED,
        });
        break;

      case 'BILLING_ISSUE':
        await subscription.update({
          status: SubscriptionStatus.BILLING_RETRY,
        });
        break;

      case 'SUBSCRIBER_ALIAS':
        await subscription.update({
          revenuecatId: event.new_app_user_id,
        });
        break;

      default:
        this.logger.warn(`Unhandled RevenueCat event type: ${type}`);
    }

    this.eventsGateway.emitToUser(app_user_id, 'subscription:updated', {
      tier: subscription.tier,
      status: subscription.status,
      isPremium: subscription.isPremium,
    });
  }

  async syncWithRevenueCat(
    userId: string,
    revenuecatId: string,
    isPremium: boolean,
    expiresAt: Date | null,
    productId: string | null,
  ): Promise<Subscription> {
    const subscription = await this.getOrCreateSubscription(userId);

    await subscription.update({
      revenuecatId,
      tier: isPremium ? SubscriptionTier.PREMIUM : SubscriptionTier.FREE,
      status: isPremium ? SubscriptionStatus.ACTIVE : subscription.status,
      expiresAt,
      productId,
    });

    return subscription;
  }
}
