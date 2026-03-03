import { IsOptional, IsUUID } from 'class-validator';

export class ScanReceiptDto {
  @IsOptional()
  @IsUUID()
  accountId?: string;
}
