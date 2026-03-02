import { IsOptional, IsString } from 'class-validator';

export class WebhookEventDto {
  @IsString()
  webhook_type!: string;

  @IsString()
  webhook_code!: string;

  @IsString()
  @IsOptional()
  item_id?: string;

  @IsOptional()
  error?: Record<string, unknown>;
}
