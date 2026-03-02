import { IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ExchangePublicTokenDto {
  @ApiProperty({ description: 'Public token from Plaid Link' })
  @IsString()
  @IsNotEmpty()
  publicToken!: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  institutionId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  institutionName?: string;
}
