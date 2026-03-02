import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { DebtsService } from './debts.service.js';
import { CreateDebtDto } from './dto/create-debt.dto.js';
import { UpdateDebtDto } from './dto/update-debt.dto.js';
import { QueryDebtDto } from './dto/query-debt.dto.js';
import { CreateDebtPaymentDto } from './dto/create-debt-payment.dto.js';
import { QueryDebtPaymentDto } from './dto/query-debt-payment.dto.js';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard.js';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Debts')
@ApiBearerAuth()
@Controller('debts')
@UseGuards(JwtAuthGuard)
export class DebtsController {
  constructor(private readonly debtsService: DebtsService) {}

  @Get('summary')
  async getSummary(@CurrentUser() user: { userId: string }) {
    return this.debtsService.getSummary(user.userId);
  }

  @Get()
  async findAll(
    @Query() query: QueryDebtDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.debtsService.findAll(user.userId, query);
  }

  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.debtsService.findOne(id, user.userId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Body() dto: CreateDebtDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.debtsService.create(user.userId, dto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateDebtDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.debtsService.update(id, user.userId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    await this.debtsService.remove(id, user.userId);
  }

  @Post(':id/payments')
  @HttpCode(HttpStatus.CREATED)
  async recordPayment(
    @Param('id') id: string,
    @Body() dto: CreateDebtPaymentDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.debtsService.recordPayment(id, user.userId, dto);
  }

  @Get(':id/payments')
  async getPayments(
    @Param('id') id: string,
    @Query() query: QueryDebtPaymentDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.debtsService.getPayments(id, user.userId, query);
  }
}
