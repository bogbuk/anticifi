import { IsString, IsNumber, IsEnum, IsOptional, IsDateString, MaxLength, Min, Max, IsInt } from 'class-validator';
import { DebtType } from '../debt.model.js';

export class CreateDebtDto {
  @IsString()
  @MaxLength(255)
  declare name: string;

  @IsEnum(DebtType)
  declare type: DebtType;

  @IsNumber()
  @Min(0)
  declare originalAmount: number;

  @IsNumber()
  @Min(0)
  declare currentBalance: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(100)
  declare interestRate?: number;

  @IsNumber()
  @IsOptional()
  @Min(0)
  declare minimumPayment?: number;

  @IsInt()
  @IsOptional()
  @Min(1)
  @Max(31)
  declare dueDay?: number;

  @IsDateString()
  @IsOptional()
  declare startDate?: string;

  @IsDateString()
  @IsOptional()
  declare expectedPayoffDate?: string;

  @IsString()
  @IsOptional()
  @MaxLength(255)
  declare creditorName?: string;

  @IsString()
  @IsOptional()
  @MaxLength(1000)
  declare notes?: string;
}
