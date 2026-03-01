import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
  IsUUID,
  IsDateString,
} from 'class-validator';
import { TransactionType } from '../transaction.model.js';

export class UpdateTransactionDto {
  @IsUUID()
  @IsOptional()
  declare accountId?: string;

  @IsNumber()
  @IsOptional()
  declare amount?: number;

  @IsEnum(TransactionType)
  @IsOptional()
  declare type?: TransactionType;

  @IsString()
  @IsOptional()
  declare description?: string;

  @IsUUID()
  @IsOptional()
  declare categoryId?: string;

  @IsDateString()
  @IsOptional()
  declare date?: string;
}
