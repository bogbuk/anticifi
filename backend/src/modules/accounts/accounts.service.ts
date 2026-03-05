import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Account } from './account.model.js';
import { CreateAccountDto } from './dto/create-account.dto.js';
import { UpdateAccountDto } from './dto/update-account.dto.js';
import { SubscriptionsService } from '../subscriptions/subscriptions.service.js';

@Injectable()
export class AccountsService {
  constructor(
    @InjectModel(Account)
    private readonly accountModel: typeof Account,
    private readonly subscriptionsService: SubscriptionsService,
  ) {}

  async findAllByUserId(userId: string): Promise<Account[]> {
    return this.accountModel.findAll({ where: { userId } });
  }

  async findOneByIdAndUserId(id: string, userId: string): Promise<Account> {
    const account = await this.accountModel.findOne({ where: { id, userId } });
    if (!account) {
      throw new NotFoundException('Account not found');
    }
    return account;
  }

  async create(userId: string, dto: CreateAccountDto): Promise<Account> {
    const currentAccounts = await this.accountModel.count({ where: { userId } });
    await this.subscriptionsService.checkAccountLimit(userId, currentAccounts);

    return this.accountModel.create({
      userId,
      name: dto.name,
      type: dto.type,
      bank: dto.bank,
      currency: dto.currency || 'USD',
      balance: dto.initialBalance || 0,
      initialBalance: dto.initialBalance || 0,
    } as any);
  }

  async update(
    id: string,
    userId: string,
    dto: UpdateAccountDto,
  ): Promise<Account> {
    const account = await this.findOneByIdAndUserId(id, userId);
    await account.update(dto);
    return account;
  }

  async remove(id: string, userId: string): Promise<void> {
    const account = await this.findOneByIdAndUserId(id, userId);
    await account.destroy();
  }
}
