import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CategorizeTransactionDto {
  @IsNotEmpty()
  @IsString()
  description: string;

  @IsOptional()
  @IsString()
  type?: string;

  @IsOptional()
  amount?: number;
}
