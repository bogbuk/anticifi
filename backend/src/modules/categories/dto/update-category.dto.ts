import {
  IsString,
  IsOptional,
  IsUUID,
} from 'class-validator';

export class UpdateCategoryDto {
  @IsString()
  @IsOptional()
  declare name?: string;

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
