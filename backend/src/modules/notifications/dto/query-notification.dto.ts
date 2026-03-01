import { IsOptional, IsString } from 'class-validator';

export class QueryNotificationDto {
  @IsOptional()
  @IsString()
  page?: string;

  @IsOptional()
  @IsString()
  limit?: string;

  @IsOptional()
  @IsString()
  type?: string;

  @IsOptional()
  @IsString()
  isRead?: string;
}
