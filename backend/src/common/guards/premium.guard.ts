import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { SubscriptionsService } from '../../modules/subscriptions/subscriptions.service.js';

@Injectable()
export class PremiumGuard implements CanActivate {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user?.userId) {
      throw new ForbiddenException('Authentication required');
    }

    const isPremium = await this.subscriptionsService.isPremiumUser(user.userId);

    if (!isPremium) {
      throw new ForbiddenException(
        'This feature requires a Premium subscription. Upgrade to unlock it.',
      );
    }

    return true;
  }
}
