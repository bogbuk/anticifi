import {
  Controller,
  Get,
  Post,
  Body,
  Headers,
  UseGuards,
  HttpCode,
  HttpStatus,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SubscriptionsService } from './subscriptions.service.js';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard.js';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';
import { SyncSubscriptionDto } from './dto/sync-subscription.dto.js';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Subscriptions')
@Controller('subscriptions')
export class SubscriptionsController {
  private readonly logger = new Logger(SubscriptionsController.name);

  constructor(
    private readonly subscriptionsService: SubscriptionsService,
    private readonly configService: ConfigService,
  ) {}

  @Get('status')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async getStatus(@CurrentUser() user: { userId: string }) {
    return this.subscriptionsService.getSubscriptionInfo(user.userId);
  }

  @Post('sync')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async syncSubscription(
    @CurrentUser() user: { userId: string },
    @Body() dto: SyncSubscriptionDto,
  ) {
    return this.subscriptionsService.syncWithRevenueCat(
      user.userId,
      dto.revenuecatId,
      dto.isPremium,
      dto.expiresAt ? new Date(dto.expiresAt) : null,
      dto.productId ?? null,
    );
  }

  @Post('webhook')
  @HttpCode(HttpStatus.OK)
  async handleWebhook(
    @Body() body: any,
    @Headers('authorization') authorization: string,
  ) {
    const webhookSecret = this.configService.get<string>('REVENUECAT_WEBHOOK_SECRET');

    if (webhookSecret && authorization !== `Bearer ${webhookSecret}`) {
      throw new UnauthorizedException('Invalid webhook secret');
    }

    const event = body.event;
    if (!event) {
      this.logger.warn('Received webhook without event payload');
      return { received: true };
    }

    await this.subscriptionsService.handleWebhookEvent(event);
    return { received: true };
  }
}
