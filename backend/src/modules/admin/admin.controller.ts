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
import { QueryUsersDto } from './dto/query-users.dto.js';
import { UpdateUserAdminDto } from './dto/update-user-admin.dto.js';
import { UpdateSubscriptionAdminDto } from './dto/update-subscription-admin.dto.js';

@Controller('admin')
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly configService: ConfigService,
  ) {}

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

  @UseGuards(AuthGuard('jwt'), AdminGuard)
  @Get('stats')
  getStats() {
    return this.adminService.getStats();
  }

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
}
