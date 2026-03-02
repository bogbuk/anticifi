import { IsNumber, IsDateString, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CreateDebtPaymentDto {
  @IsNumber()
  @Min(0.01)
  declare amount: number;

  @IsDateString()
  @IsOptional()
  declare paymentDate?: string;

  @IsString()
  @IsOptional()
  @MaxLength(1000)
  declare notes?: string;
}
