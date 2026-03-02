import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
  IsUUID,
  IsDateString,
  IsBoolean,
  MaxLength,
} from 'class-validator';
import { BudgetPeriod } from '../budget.model.js';

export class UpdateBudgetDto {
  @IsString()
  @IsOptional()
  @MaxLength(255)
  declare name?: string;

  @IsNumber()
  @IsOptional()
  declare amount?: number;

  @IsEnum(BudgetPeriod)
  @IsOptional()
  declare period?: BudgetPeriod;

  @IsUUID()
  @IsOptional()
  declare categoryId?: string;

  @IsDateString()
  @IsOptional()
  declare startDate?: string;

  @IsDateString()
  @IsOptional()
  declare endDate?: string;

  @IsBoolean()
  @IsOptional()
  declare isActive?: boolean;
}
