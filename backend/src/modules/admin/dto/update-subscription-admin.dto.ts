import { IsOptional, IsEnum, IsDateString } from 'class-validator';

export class UpdateSubscriptionAdminDto {
  @IsOptional()
  @IsEnum(['free', 'premium'])
  tier?: string;

  @IsOptional()
  @IsEnum(['active', 'expired', 'cancelled', 'grace_period', 'billing_retry'])
  status?: string;

  @IsOptional()
  @IsEnum(['monthly', 'yearly', 'lifetime'])
  period?: string;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}
