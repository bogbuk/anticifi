import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/sequelize';
import {
  PlaidApi,
  Configuration,
  PlaidEnvironments,
  Products,
  CountryCode,
} from 'plaid';
import { PlaidItem, PlaidItemStatus } from './plaid-item.model.js';
import { Account, ConnectionType } from '../accounts/account.model.js';
import { PlaidEncryptionService } from './plaid-encryption.service.js';

@Injectable()
export class PlaidService {
  private readonly logger = new Logger(PlaidService.name);
  private readonly plaidClient: PlaidApi;

  constructor(
    private readonly configService: ConfigService,
    private readonly encryptionService: PlaidEncryptionService,
    @InjectModel(PlaidItem) private readonly plaidItemModel: typeof PlaidItem,
    @InjectModel(Account) private readonly accountModel: typeof Account,
  ) {
    const configuration = new Configuration({
      basePath:
        PlaidEnvironments[
          this.configService.get<string>('PLAID_ENV', 'sandbox')
        ],
      baseOptions: {
        headers: {
          'PLAID-CLIENT-ID': this.configService.get<string>('PLAID_CLIENT_ID'),
          'PLAID-SECRET': this.configService.get<string>('PLAID_SECRET'),
        },
      },
    });
    this.plaidClient = new PlaidApi(configuration);
  }

  async createLinkToken(userId: string): Promise<{ linkToken: string }> {
    const response = await this.plaidClient.linkTokenCreate({
      user: { client_user_id: userId },
      client_name: 'AnticiFi',
      products: [Products.Transactions],
      country_codes: [CountryCode.Us],
      language: 'en',
      webhook: this.configService.get<string>('PLAID_WEBHOOK_URL') || undefined,
    });

    return { linkToken: response.data.link_token };
  }

  async exchangePublicToken(
    userId: string,
    publicToken: string,
    institutionId?: string,
    institutionName?: string,
  ): Promise<{ item: PlaidItem; accounts: Account[] }> {
    const response =
      await this.plaidClient.itemPublicTokenExchange({
        public_token: publicToken,
      });

    const { access_token, item_id } = response.data;

    const encryptedToken = this.encryptionService.encrypt(access_token);

    const plaidItem = await this.plaidItemModel.create({
      userId,
      itemId: item_id,
      accessToken: encryptedToken,
      institutionId: institutionId || null,
      institutionName: institutionName || null,
      status: PlaidItemStatus.ACTIVE,
    } as any);

    const accountsResponse = await this.plaidClient.accountsGet({
      access_token,
    });

    const createdAccounts: Account[] = [];

    for (const plaidAccount of accountsResponse.data.accounts) {
      const accountType = this.mapPlaidAccountType(plaidAccount.type);
      const balance = plaidAccount.balances.current ?? 0;

      const account = await this.accountModel.create({
        userId,
        name: plaidAccount.name || plaidAccount.official_name || 'Account',
        type: accountType,
        bank: institutionName || null,
        currency: plaidAccount.balances.iso_currency_code || 'USD',
        balance,
        initialBalance: balance,
        connectionType: ConnectionType.PLAID,
        plaidAccountId: plaidAccount.account_id,
        plaidItemId: plaidItem.id,
        mask: plaidAccount.mask || null,
      } as any);

      createdAccounts.push(account);
    }

    this.logger.log(
      `Linked ${createdAccounts.length} accounts for user ${userId} from ${institutionName || item_id}`,
    );

    return { item: plaidItem, accounts: createdAccounts };
  }

  async getItemsByUserId(userId: string): Promise<PlaidItem[]> {
    return this.plaidItemModel.findAll({
      where: { userId },
      include: [{ model: Account }],
      order: [['createdAt', 'DESC']],
    });
  }

  async removeItem(
    itemDbId: string,
    userId: string,
  ): Promise<{ success: boolean }> {
    const item = await this.plaidItemModel.findOne({
      where: { id: itemDbId, userId },
    });

    if (!item) {
      throw new NotFoundException('Plaid item not found');
    }

    try {
      const accessToken = this.encryptionService.decrypt(item.accessToken);
      await this.plaidClient.itemRemove({ access_token: accessToken });
    } catch (error) {
      this.logger.warn(
        `Failed to remove item from Plaid API: ${(error as Error).message}`,
      );
    }

    await this.accountModel.update(
      {
        connectionType: ConnectionType.MANUAL,
        plaidAccountId: null,
        plaidItemId: null,
      },
      { where: { plaidItemId: item.id } },
    );

    await item.destroy();

    this.logger.log(`Removed Plaid item ${itemDbId} for user ${userId}`);

    return { success: true };
  }

  async updateItemStatus(
    plaidItemId: string,
    status: PlaidItemStatus,
    errorCode?: string,
    errorMessage?: string,
  ): Promise<void> {
    await this.plaidItemModel.update(
      { status, errorCode: errorCode || null, errorMessage: errorMessage || null },
      { where: { itemId: plaidItemId } },
    );
  }

  getPlaidClient(): PlaidApi {
    return this.plaidClient;
  }

  getDecryptedAccessToken(item: PlaidItem): string {
    return this.encryptionService.decrypt(item.accessToken);
  }

  private mapPlaidAccountType(
    plaidType: string,
  ): 'checking' | 'savings' | 'credit' | 'cash' {
    switch (plaidType) {
      case 'depository':
        return 'checking';
      case 'credit':
        return 'credit';
      case 'investment':
      case 'brokerage':
        return 'savings';
      case 'loan':
        return 'credit';
      default:
        return 'checking';
    }
  }
}
