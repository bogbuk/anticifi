import {
  IsOptional,
  IsNumberString,
  IsBooleanString,
} from 'class-validator';

export class QueryBudgetDto {
  @IsNumberString()
  @IsOptional()
  declare page?: string;

  @IsNumberString()
  @IsOptional()
  declare limit?: string;

  @IsBooleanString()
  @IsOptional()
  declare isActive?: string;
}
