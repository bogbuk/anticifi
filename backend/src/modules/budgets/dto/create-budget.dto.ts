import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
  IsUUID,
  IsDateString,
  MaxLength,
} from 'class-validator';
import { BudgetPeriod } from '../budget.model.js';

export class CreateBudgetDto {
  @IsString()
  @MaxLength(255)
  declare name: string;

  @IsNumber()
  declare amount: number;

  @IsEnum(BudgetPeriod)
  declare period: BudgetPeriod;

  @IsUUID()
  @IsOptional()
  declare categoryId?: string;

  @IsDateString()
  @IsOptional()
  declare startDate?: string;

  @IsDateString()
  @IsOptional()
  declare endDate?: string;
}
