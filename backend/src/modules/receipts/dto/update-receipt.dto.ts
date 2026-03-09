import {
  IsOptional,
  IsString,
  IsNumber,
  IsArray,
  ValidateNested,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

class ReceiptItemDto {
  @IsString()
  declare name: string;

  @IsNumber()
  @Min(0)
  declare price: number;
}

export class UpdateReceiptDto {
  @IsOptional()
  @IsString()
  declare merchant?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  declare amount?: number;

  @IsOptional()
  @IsString()
  declare date?: string;

  @IsOptional()
  @IsString()
  declare currency?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ReceiptItemDto)
  declare items?: ReceiptItemDto[];
}