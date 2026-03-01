import {
  IsString,
  IsOptional,
  IsUUID,
} from 'class-validator';

export class CreateCategoryDto {
  @IsString()
  declare name: string;

  @IsString()
  @IsOptional()
  declare icon?: string;

  @IsString()
  @IsOptional()
  declare color?: string;

  @IsUUID()
  @IsOptional()
  declare parentId?: string;
}
