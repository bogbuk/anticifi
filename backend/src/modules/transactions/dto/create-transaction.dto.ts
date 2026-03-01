import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
  IsUUID,
  IsDateString,
} from 'class-validator';
import { TransactionType } from '../transaction.model.js';

export class CreateTransactionDto {
  @IsUUID()
  declare accountId: string;

  @IsNumber()
  declare amount: number;

  @IsEnum(TransactionType)
  declare type: TransactionType;

  @IsString()
  @IsOptional()
  declare description?: string;

  @IsUUID()
  @IsOptional()
  declare categoryId?: string;

  @IsDateString()
  declare date: string;
}
