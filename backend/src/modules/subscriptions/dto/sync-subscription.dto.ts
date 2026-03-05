import { IsString, IsBoolean, IsOptional, IsDateString } from 'class-validator';

export class SyncSubscriptionDto {
  @IsString()
  revenuecatId: string;

  @IsBoolean()
  isPremium: boolean;

  @IsOptional()
  @IsDateString()
  expiresAt?: string;

  @IsOptional()
  @IsString()
  productId?: string;
}
