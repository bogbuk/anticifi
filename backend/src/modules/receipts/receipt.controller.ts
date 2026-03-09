import {
  Controller, Post, Get, Delete, Param, Body, Query, UseGuards,
  UseInterceptors, UploadedFile, Req, ParseFilePipe, MaxFileSizeValidator,
  HttpCode, HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { FileInterceptor } from '@nestjs/platform-express';
import { ReceiptService } from './receipt.service.js';
import { ConfirmReceiptDto } from './dto/confirm-receipt.dto.js';

@Controller('receipts')
@UseGuards(AuthGuard('jwt'))
export class ReceiptController {
  constructor(private readonly receiptService: ReceiptService) {}

  @Post('scan')
  @UseInterceptors(FileInterceptor('image'))
  async scanReceipt(
    @Req() req: any,
    @UploadedFile(
      new ParseFilePipe({
        validators: [new MaxFileSizeValidator({ maxSize: 10 * 1024 * 1024 })],
      }),
    )
    file: Express.Multer.File,
  ) {
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
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.receiptService.getUserScans(
      req.user.id,
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
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
