import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  Body,
  UseGuards,
  Logger,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard.js';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';
import { PlaidService } from './plaid.service.js';
import { PlaidSyncService } from './plaid-sync.service.js';
import { ExchangePublicTokenDto } from './dto/exchange-public-token.dto.js';
import { WebhookEventDto } from './dto/webhook-event.dto.js';
import { PlaidItemStatus } from './plaid-item.model.js';

@ApiTags('Plaid')
@Controller('plaid')
export class PlaidController {
  private readonly logger = new Logger(PlaidController.name);

  constructor(
    private readonly plaidService: PlaidService,
    private readonly plaidSyncService: PlaidSyncService,
  ) {}

  @Post('link-token')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create Plaid Link token' })
  @ApiResponse({ status: 201, description: 'Link token created' })
  async createLinkToken(
    @CurrentUser() user: { userId: string },
  ) {
    return this.plaidService.createLinkToken(user.userId);
  }

  @Post('exchange-token')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Exchange public token and create accounts' })
  @ApiResponse({ status: 201, description: 'Token exchanged, accounts created' })
  async exchangeToken(
    @CurrentUser() user: { userId: string },
    @Body() dto: ExchangePublicTokenDto,
  ) {
    return this.plaidService.exchangePublicToken(
      user.userId,
      dto.publicToken,
      dto.institutionId,
      dto.institutionName,
    );
  }

  @Get('items')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List connected banks' })
  @ApiResponse({ status: 200, description: 'List of Plaid items' })
  async getItems(@CurrentUser() user: { userId: string }) {
    return this.plaidService.getItemsByUserId(user.userId);
  }

  @Delete('items/:itemId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Disconnect a bank' })
  @ApiResponse({ status: 200, description: 'Bank disconnected' })
  async removeItem(
    @Param('itemId') itemId: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.plaidService.removeItem(itemId, user.userId);
  }

  @Post('sync/:itemId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Manually trigger transaction sync' })
  @ApiResponse({ status: 200, description: 'Sync completed' })
  async syncItem(
    @Param('itemId') itemId: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.plaidSyncService.syncTransactionsForItem(
      itemId,
      user.userId,
    );
  }

  @Post('webhook')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Plaid webhook receiver (public)' })
  @ApiResponse({ status: 200, description: 'Webhook processed' })
  async handleWebhook(@Body() body: WebhookEventDto) {
    this.logger.log(
      `Webhook received: ${body.webhook_type}/${body.webhook_code}`,
    );

    switch (`${body.webhook_type}/${body.webhook_code}`) {
      case 'TRANSACTIONS/SYNC_UPDATES_AVAILABLE':
        if (body.item_id) {
          // Run sync asynchronously — Plaid requires response < 3 sec
          setImmediate(() => {
            this.plaidSyncService
              .syncByPlaidItemId(body.item_id!)
              .catch((err) =>
                this.logger.error(`Webhook sync failed: ${err.message}`),
              );
          });
        }
        break;

      case 'ITEM/ERROR':
        if (body.item_id) {
          const errorCode =
            (body.error as any)?.error_code || 'UNKNOWN';
          const errorMessage =
            (body.error as any)?.error_message || 'Unknown error';
          await this.plaidService.updateItemStatus(
            body.item_id,
            PlaidItemStatus.ERROR,
            errorCode,
            errorMessage,
          );
        }
        break;

      case 'ITEM/PENDING_EXPIRATION':
        if (body.item_id) {
          await this.plaidService.updateItemStatus(
            body.item_id,
            PlaidItemStatus.PENDING_EXPIRATION,
          );
        }
        break;

      case 'ITEM/USER_PERMISSION_REVOKED':
        if (body.item_id) {
          await this.plaidService.updateItemStatus(
            body.item_id,
            PlaidItemStatus.REVOKED,
          );
        }
        break;

      default:
        this.logger.warn(
          `Unhandled webhook: ${body.webhook_type}/${body.webhook_code}`,
        );
    }

    return { received: true };
  }
}
