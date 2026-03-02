import { createHash } from 'node:crypto';
import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { PlaidItem, PlaidItemStatus } from './plaid-item.model.js';
import { Account } from '../accounts/account.model.js';
import {
  Transaction,
  TransactionType,
} from '../transactions/transaction.model.js';
import { PlaidService } from './plaid.service.js';
import { EventsGateway } from '../events/events.gateway.js';
import { NotificationsService } from '../notifications/notifications.service.js';

@Injectable()
export class PlaidSyncService {
  private readonly logger = new Logger(PlaidSyncService.name);

  constructor(
    @InjectModel(PlaidItem) private readonly plaidItemModel: typeof PlaidItem,
    @InjectModel(Account) private readonly accountModel: typeof Account,
    @InjectModel(Transaction)
    private readonly transactionModel: typeof Transaction,
    private readonly plaidService: PlaidService,
    private readonly eventsGateway: EventsGateway,
    private readonly notificationsService: NotificationsService,
  ) {}

  async syncTransactionsForItem(
    itemDbId: string,
    userId: string,
  ): Promise<{ added: number; modified: number; removed: number }> {
    const item = await this.plaidItemModel.findOne({
      where: { id: itemDbId, userId },
    });

    if (!item) {
      throw new NotFoundException('Plaid item not found');
    }

    const accessToken = this.plaidService.getDecryptedAccessToken(item);
    const client = this.plaidService.getPlaidClient();

    let cursor = item.cursor || undefined;
    let added = 0;
    let modified = 0;
    let removed = 0;
    let hasMore = true;

    const affectedAccountIds = new Set<string>();

    while (hasMore) {
      const response = await client.transactionsSync({
        access_token: accessToken,
        cursor,
      });

      const data = response.data;

      for (const tx of data.added) {
        const account = await this.findLinkedAccount(tx.account_id, userId);
        if (!account) continue;

        const hash = this.generatePlaidHash(tx.transaction_id);
        const type =
          tx.amount < 0 ? TransactionType.INCOME : TransactionType.EXPENSE;
        const amount = Math.abs(tx.amount);

        await this.transactionModel.upsert(
          {
            userId,
            accountId: account.id,
            amount,
            type,
            description: tx.name || tx.merchant_name || null,
            date: tx.date,
            transactionHash: hash,
          } as any,
          { conflictFields: ['transaction_hash'] },
        );

        affectedAccountIds.add(account.id);
        added++;
      }

      for (const tx of data.modified) {
        const hash = this.generatePlaidHash(tx.transaction_id);
        const existing = await this.transactionModel.findOne({
          where: { transactionHash: hash, userId },
        });

        if (existing) {
          const account = await this.findLinkedAccount(tx.account_id, userId);
          const type =
            tx.amount < 0 ? TransactionType.INCOME : TransactionType.EXPENSE;
          const amount = Math.abs(tx.amount);

          await existing.update({
            amount,
            type,
            description: tx.name || tx.merchant_name || null,
            date: tx.date,
            accountId: account?.id || existing.accountId,
          });

          affectedAccountIds.add(existing.accountId);
          if (account) affectedAccountIds.add(account.id);
          modified++;
        }
      }

      for (const tx of data.removed) {
        const txId =
          typeof tx === 'string'
            ? tx
            : (tx as any).transaction_id;
        if (!txId) continue;

        const hash = this.generatePlaidHash(txId);
        const existing = await this.transactionModel.findOne({
          where: { transactionHash: hash, userId },
        });

        if (existing) {
          affectedAccountIds.add(existing.accountId);
          await existing.destroy();
          removed++;
        }
      }

      cursor = data.next_cursor;
      hasMore = data.has_more;
    }

    await item.update({
      cursor,
      lastSyncedAt: new Date(),
    });

    for (const accountId of affectedAccountIds) {
      await this.recalculateBalance(accountId);
      const account = await this.accountModel.findByPk(accountId);
      if (account) {
        this.eventsGateway.emitToUser(userId, 'balance:updated', {
          accountId: account.id,
          balance: account.balance,
        });
      }
    }

    this.eventsGateway.emitToUser(userId, 'plaid:sync-complete', {
      itemId: itemDbId,
      added,
      modified,
      removed,
    });

    if (added > 0 || modified > 0 || removed > 0) {
      await this.notificationsService.createNotification(
        userId,
        'Transactions synced',
        `Synced ${added} new, ${modified} updated, ${removed} removed transactions from ${item.institutionName || 'your bank'}.`,
        'system' as any,
      );
    }

    this.logger.log(
      `Synced item ${itemDbId}: +${added} ~${modified} -${removed}`,
    );

    return { added, modified, removed };
  }

  async syncByPlaidItemId(
    plaidItemId: string,
  ): Promise<{ added: number; modified: number; removed: number }> {
    const item = await this.plaidItemModel.findOne({
      where: { itemId: plaidItemId },
    });

    if (!item) {
      this.logger.warn(
        `Received sync request for unknown Plaid item: ${plaidItemId}`,
      );
      return { added: 0, modified: 0, removed: 0 };
    }

    return this.syncTransactionsForItem(item.id, item.userId);
  }

  async syncAllForUser(
    userId: string,
  ): Promise<{ added: number; modified: number; removed: number }> {
    const items = await this.plaidItemModel.findAll({
      where: { userId, status: PlaidItemStatus.ACTIVE },
    });

    let totalAdded = 0;
    let totalModified = 0;
    let totalRemoved = 0;

    for (const item of items) {
      try {
        const result = await this.syncTransactionsForItem(item.id, userId);
        totalAdded += result.added;
        totalModified += result.modified;
        totalRemoved += result.removed;
      } catch (error) {
        this.logger.error(
          `Failed to sync item ${item.id}: ${(error as Error).message}`,
        );
      }
    }

    return {
      added: totalAdded,
      modified: totalModified,
      removed: totalRemoved,
    };
  }

  private async findLinkedAccount(
    plaidAccountId: string,
    userId: string,
  ): Promise<Account | null> {
    return this.accountModel.findOne({
      where: { plaidAccountId, userId },
    });
  }

  private generatePlaidHash(plaidTransactionId: string): string {
    return createHash('sha256')
      .update(`plaid:${plaidTransactionId}`)
      .digest('hex');
  }

  private async recalculateBalance(accountId: string): Promise<void> {
    const account = await this.accountModel.findByPk(accountId);
    if (!account) return;

    const incomeSum =
      (await this.transactionModel.sum('amount', {
        where: { accountId, type: TransactionType.INCOME },
      })) || 0;

    const expenseSum =
      (await this.transactionModel.sum('amount', {
        where: { accountId, type: TransactionType.EXPENSE },
      })) || 0;

    const balance =
      Number(account.initialBalance) + Number(incomeSum) - Number(expenseSum);
    await account.update({ balance });
  }
}
