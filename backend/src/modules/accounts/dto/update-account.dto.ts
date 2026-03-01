import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
} from 'class-validator';
import { AccountType } from '../account.model.js';

export class UpdateAccountDto {
  @IsString()
  @IsOptional()
  declare name?: string;

  @IsEnum(AccountType)
  @IsOptional()
  declare type?: AccountType;

  @IsString()
  @IsOptional()
  declare bank?: string;

  @IsString()
  @IsOptional()
  declare currency?: string;

  @IsNumber()
  @IsOptional()
  declare initialBalance?: number;
}
