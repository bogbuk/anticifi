import { IsUUID } from 'class-validator';

export class ImportCsvDto {
  @IsUUID()
  declare accountId: string;
}
