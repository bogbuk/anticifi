import {
  IsString,
  IsEnum,
  IsOptional,
  IsUUID,
  IsDateString,
  IsNumberString,
} from 'class-validator';
import { TransactionType } from '../transaction.model.js';

export class QueryTransactionDto {
  @IsNumberString()
  @IsOptional()
  declare page?: string;

  @IsNumberString()
  @IsOptional()
  declare limit?: string;

  @IsUUID()
  @IsOptional()
  declare accountId?: string;

  @IsEnum(TransactionType)
  @IsOptional()
  declare type?: TransactionType;

  @IsUUID()
  @IsOptional()
  declare categoryId?: string;

  @IsDateString()
  @IsOptional()
  declare startDate?: string;

  @IsDateString()
  @IsOptional()
  declare endDate?: string;

  @IsString()
  @IsOptional()
  declare search?: string;
}
