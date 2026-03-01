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

export class CreateScheduledPaymentDto {
  @IsUUID()
  declare accountId: string;

  @IsUUID()
  @IsOptional()
  declare categoryId?: string;

  @IsString()
  @MaxLength(255)
  declare name: string;

  @IsNumber()
  declare amount: number;

  @IsEnum(ScheduledPaymentType)
  declare type: ScheduledPaymentType;

  @IsEnum(PaymentFrequency)
  declare frequency: PaymentFrequency;

  @IsDateString()
  declare startDate: string;

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
