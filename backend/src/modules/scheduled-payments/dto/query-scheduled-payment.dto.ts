import {
  IsEnum,
  IsOptional,
  IsUUID,
  IsNumberString,
  IsBooleanString,
} from 'class-validator';
import { ScheduledPaymentType } from '../scheduled-payment.model.js';

export class QueryScheduledPaymentDto {
  @IsNumberString()
  @IsOptional()
  declare page?: string;

  @IsNumberString()
  @IsOptional()
  declare limit?: string;

  @IsUUID()
  @IsOptional()
  declare accountId?: string;

  @IsEnum(ScheduledPaymentType)
  @IsOptional()
  declare type?: ScheduledPaymentType;

  @IsBooleanString()
  @IsOptional()
  declare isActive?: string;
}
