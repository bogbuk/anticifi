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
import { ScheduledPaymentsService } from './scheduled-payments.service.js';
import { CreateScheduledPaymentDto } from './dto/create-scheduled-payment.dto.js';
import { UpdateScheduledPaymentDto } from './dto/update-scheduled-payment.dto.js';
import { QueryScheduledPaymentDto } from './dto/query-scheduled-payment.dto.js';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard.js';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';

@Controller('scheduled-payments')
@UseGuards(JwtAuthGuard)
export class ScheduledPaymentsController {
  constructor(
    private readonly scheduledPaymentsService: ScheduledPaymentsService,
  ) {}

  @Get()
  async findAll(
    @Query() query: QueryScheduledPaymentDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.scheduledPaymentsService.findAll(user.userId, query);
  }

  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.scheduledPaymentsService.findOne(id, user.userId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Body() dto: CreateScheduledPaymentDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.scheduledPaymentsService.create(user.userId, dto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateScheduledPaymentDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.scheduledPaymentsService.update(id, user.userId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    await this.scheduledPaymentsService.remove(id, user.userId);
  }

  @Post(':id/execute')
  async execute(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.scheduledPaymentsService.executeSingle(id, user.userId);
  }
}
