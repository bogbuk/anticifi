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
import {
  ScheduledPaymentType,
  PaymentFrequency,
} from '../scheduled-payment.model.js';

export class UpdateScheduledPaymentDto {
  @IsUUID()
  @IsOptional()
  declare accountId?: string;

  @IsUUID()
  @IsOptional()
  declare categoryId?: string;

  @IsString()
  @IsOptional()
  @MaxLength(255)
  declare name?: string;

  @IsNumber()
  @IsOptional()
  declare amount?: number;

  @IsEnum(ScheduledPaymentType)
  @IsOptional()
  declare type?: ScheduledPaymentType;

  @IsEnum(PaymentFrequency)
  @IsOptional()
  declare frequency?: PaymentFrequency;

  @IsDateString()
  @IsOptional()
  declare startDate?: string;

  @IsDateString()
  @IsOptional()
  declare endDate?: string;

  @IsDateString()
  @IsOptional()
  declare nextExecutionDate?: string;

  @IsBoolean()
  @IsOptional()
  declare isActive?: boolean;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  declare description?: string;
}
