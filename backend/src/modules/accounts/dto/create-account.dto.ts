import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
} from 'class-validator';
import { AccountType } from '../account.model.js';

export class CreateAccountDto {
  @IsString()
  declare name: string;

  @IsEnum(AccountType)
  declare type: AccountType;

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
