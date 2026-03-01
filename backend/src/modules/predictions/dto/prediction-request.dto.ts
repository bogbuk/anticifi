import { IsString, IsOptional, IsNumber, IsInt, Min, Max } from 'class-validator';
import { Transform } from 'class-transformer';

export class PredictionRequestDto {
  @IsOptional()
  @IsString()
  accountId?: string;

  @IsOptional()
  @IsString()
  targetDate?: string;

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  @Min(1)
  @Max(365)
  daysAhead?: number;
}

export class ChatPredictionRequestDto {
  @IsString()
  question!: string;
}

export class ForecastQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  @Min(1)
  @Max(365)
  daysAhead?: number;
}
