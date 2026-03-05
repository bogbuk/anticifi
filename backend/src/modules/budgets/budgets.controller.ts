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
import { BudgetsService } from './budgets.service.js';
import { CreateBudgetDto } from './dto/create-budget.dto.js';
import { UpdateBudgetDto } from './dto/update-budget.dto.js';
import { QueryBudgetDto } from './dto/query-budget.dto.js';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard.js';
import { PremiumGuard } from '../../common/guards/premium.guard.js';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Budgets')
@ApiBearerAuth()
@Controller('budgets')
@UseGuards(JwtAuthGuard, PremiumGuard)
export class BudgetsController {
  constructor(private readonly budgetsService: BudgetsService) {}

  @Get('summary')
  async getSummary(@CurrentUser() user: { userId: string }) {
    return this.budgetsService.getActiveBudgetsWithProgress(user.userId);
  }

  @Get()
  async findAll(
    @Query() query: QueryBudgetDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.budgetsService.findAll(user.userId, query);
  }

  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.budgetsService.findOne(id, user.userId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Body() dto: CreateBudgetDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.budgetsService.create(user.userId, dto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateBudgetDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.budgetsService.update(id, user.userId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    await this.budgetsService.remove(id, user.userId);
  }
}
