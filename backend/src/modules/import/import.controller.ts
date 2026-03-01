import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ImportService } from './import.service.js';
import { ImportCsvDto } from './dto/import-csv.dto.js';
import { ImportFormat } from './import-job.model.js';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard.js';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';

@Controller('import')
@UseGuards(JwtAuthGuard)
export class ImportController {
  constructor(private readonly importService: ImportService) {}

  @Post('csv')
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('file'))
  async importCsv(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: ImportCsvDto,
    @CurrentUser() user: { userId: string },
  ) {
    if (!file) {
      throw new BadRequestException('CSV file is required');
    }

    const csvContent = file.buffer.toString('utf-8');
    const job = await this.importService.createImportJob(
      user.userId,
      dto.accountId,
      ImportFormat.CSV,
    );

    const result = await this.importService.processCSV(job.id, csvContent);
    return result;
  }

  @Get('jobs')
  async getJobs(@CurrentUser() user: { userId: string }) {
    return this.importService.getJobs(user.userId);
  }

  @Get('jobs/:id')
  async getJobStatus(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.importService.getJobStatus(id, user.userId);
  }
}
