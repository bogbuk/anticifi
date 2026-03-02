import { IsOptional, IsNumberString } from 'class-validator';

export class QueryDebtPaymentDto {
  @IsNumberString()
  @IsOptional()
  declare page?: string;

  @IsNumberString()
  @IsOptional()
  declare limit?: string;
}
