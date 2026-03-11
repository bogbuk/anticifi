import {
  Controller, Post, Get, Patch, Delete, Param, Body, Query, UseGuards,
  UseInterceptors, Req, BadRequestException,
  HttpCode, HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { FileUpload } from '../../common/interceptors/file-upload.interceptor.js';
import type { UploadedFile } from '../../common/interceptors/file-upload.interceptor.js';
import { UploadedFileParam } from '../../common/decorators/uploaded-file.decorator.js';
import { ReceiptService } from './receipt.service.js';
import { ConfirmReceiptDto } from './dto/confirm-receipt.dto.js';
import { QueryReceiptDto } from './dto/query-receipt.dto.js';
import { UpdateReceiptDto } from './dto/update-receipt.dto.js';

@Controller('receipts')
@UseGuards(AuthGuard('jwt'))
export class ReceiptController {
  constructor(private readonly receiptService: ReceiptService) {}

  @Post('scan')
  @UseInterceptors(FileUpload('image'))
  async scanReceipt(
    @Req() req: any,
    @UploadedFileParam() file: UploadedFile,
  ) {
    if (!file) {
      throw new BadRequestException('Image file is required');
    }
    if (file.size > 10 * 1024 * 1024) {
      throw new BadRequestException('File size exceeds 10MB limit');
    }
    return this.receiptService.scanReceipt(req.user.id, file);
  }

  @Post(':id/confirm')
  async confirmReceipt(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: ConfirmReceiptDto,
  ) {
    return this.receiptService.confirmReceipt(req.user.id, id, dto);
  }

  @Get()
  async getUserScans(
    @Req() req: any,
    @Query() query: QueryReceiptDto,
  ) {
    return this.receiptService.getUserScans(req.user.id, query);
  }

  @Patch(':id')
  async updateScan(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: UpdateReceiptDto,
  ) {
    return this.receiptService.updateScan(req.user.id, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteScan(
    @Req() req: any,
    @Param('id') id: string,
  ) {
    await this.receiptService.deleteScan(req.user.id, id);
  }
}
