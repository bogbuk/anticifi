import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Query,
  Body,
  Headers,
  UseGuards,
  ForbiddenException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthGuard } from '@nestjs/passport';
import { AdminGuard } from '../../common/guards/admin.guard.js';
import { AdminService } from './admin.service.js';
import { AdminAnalyticsService } from './admin-analytics.service.js';
import { AuditLogService } from './audit-log.service.js';
import { QueryUsersDto } from './dto/query-users.dto.js';
import { UpdateUserAdminDto } from './dto/update-user-admin.dto.js';
import { UpdateSubscriptionAdminDto } from './dto/update-subscription-admin.dto.js';

@Controller('admin')
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly analyticsService: AdminAnalyticsService,
    private readonly auditLogService: AuditLogService,
    private readonly configService: ConfigService,
  ) {}

  // --- Setup (no auth) ---

  @Post('setup')
  async setupAdmin(
    @Body() body: { email: string },
    @Headers('x-admin-secret') secret: string,
  ) {
    const adminSecret = this.configService.get<string>('ADMIN_SETUP_SECRET');
    if (!adminSecret || secret !== adminSecret) {
      throw new ForbiddenException('Invalid setup secret');
    }
    return this.adminService.promoteToAdmin(body.email);
  }

  @Post('reset-password')
  async resetPassword(
    @Body() body: { email: string; password: string },
    @Headers('x-admin-secret') secret: string,
  ) {
    const adminSecret = this.configService.get<string>('ADMIN_SETUP_SECRET');
    if (!adminSecret || secret !== adminSecret) {
      throw new ForbiddenException('Invalid setup secret');
    }
    return this.adminService.resetPassword(body.email, body.password);
  }

  // --- Dashboard ---

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('stats')
  getStats() {
    return this.adminService.getStats();
  }

  // --- Users CRUD ---

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('users')
  getUsers(@Query() query: QueryUsersDto) {
    return this.adminService.getUsers(query);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('users/:id')
  getUserById(@Param('id') id: string) {
    return this.adminService.getUserById(id);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Patch('users/:id')
  updateUser(@Param('id') id: string, @Body() dto: UpdateUserAdminDto) {
    return this.adminService.updateUser(id, dto);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Delete('users/:id')
  deleteUser(@Param('id') id: string) {
    return this.adminService.deleteUser(id);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Patch('users/:id/subscription')
  updateSubscription(
    @Param('id') id: string,
    @Body() dto: UpdateSubscriptionAdminDto,
  ) {
    return this.adminService.updateSubscription(id, dto);
  }

  // --- User data ---

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('users/:id/transactions')
  getUserTransactions(@Param('id') id: string, @Query() query: any) {
    return this.adminService.getUserTransactions(id, query);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('users/:id/accounts')
  getUserAccounts(@Param('id') id: string) {
    return this.adminService.getUserAccounts(id);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('users/:id/budgets')
  getUserBudgets(@Param('id') id: string) {
    return this.adminService.getUserBudgets(id);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('users/:id/debts')
  getUserDebts(@Param('id') id: string) {
    return this.adminService.getUserDebts(id);
  }

  // --- Global views ---

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('transactions')
  getAllTransactions(@Query() query: any) {
    return this.adminService.getAllTransactions(query);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('subscriptions')
  getAllSubscriptions(@Query() query: any) {
    return this.adminService.getAllSubscriptions(query);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('receipts')
  getReceipts(@Query() query: any) {
    return this.adminService.getReceipts(query);
  }

  // --- Notifications ---

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Post('notifications/broadcast')
  broadcastNotification(@Body() body: { title: string; body: string; userIds?: string[] }) {
    return this.adminService.broadcastNotification(body);
  }

  // --- Analytics ---

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('analytics/user-growth')
  getUserGrowth(@Query('days') days?: string) {
    return this.analyticsService.getUserGrowth(days ? Number(days) : undefined);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('analytics/transactions')
  getTransactionVolume(@Query('days') days?: string) {
    return this.analyticsService.getTransactionVolume(days ? Number(days) : undefined);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('analytics/revenue')
  getRevenue(@Query('days') days?: string) {
    return this.analyticsService.getRevenue(days ? Number(days) : undefined);
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('analytics/retention')
  getRetention() {
    return this.analyticsService.getRetention();
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('analytics/categories')
  getCategoryBreakdown() {
    return this.analyticsService.getCategoryBreakdown();
  }

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('analytics/subscriptions')
  getSubscriptionBreakdown() {
    return this.analyticsService.getSubscriptionBreakdown();
  }

  // --- Audit logs ---

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('audit-logs')
  getAuditLogs(@Query() query: any) {
    return this.auditLogService.getLogs(query);
  }
}
