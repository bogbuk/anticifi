import { IsString, IsOptional, IsNumber, IsInt, Min, Max } from 'class-validator';

export class PredictionRequestDto {
  @IsOptional()
  @IsString()
  accountId?: string;

  @IsOptional()
  @IsString()
  targetDate?: string;

  @IsOptional()
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
  @IsInt()
  @Min(1)
  @Max(365)
  daysAhead?: number;
}
