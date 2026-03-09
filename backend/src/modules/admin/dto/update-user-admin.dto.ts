import { IsOptional, IsString, IsEmail, IsEnum, IsBoolean } from 'class-validator';

export class UpdateUserAdminDto {
  @IsOptional()
  @IsString()
  firstName?: string;

  @IsOptional()
  @IsString()
  lastName?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsEnum(['USER', 'ADMIN'])
  role?: string;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsString()
  locale?: string;

  @IsOptional()
  @IsBoolean()
  isEmailVerified?: boolean;
}
