import { IsOptional, IsNumberString, IsEnum } from 'class-validator';
import { ReceiptStatus } from '../receipt.model.js';

export class QueryReceiptDto {
  @IsNumberString()
  @IsOptional()
  declare page?: string;

  @IsNumberString()
  @IsOptional()
  declare limit?: string;

  @IsEnum(ReceiptStatus)
  @IsOptional()
  declare status?: ReceiptStatus;
}