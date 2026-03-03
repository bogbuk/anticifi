import { Controller, Get, Query, Req, Res, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import type { Response } from 'express';
import { ExportService, ExportQuery } from './export.service.js';

@Controller('export')
@UseGuards(AuthGuard('jwt'))
export class ExportController {
  constructor(private readonly exportService: ExportService) {}

  @Get('csv')
  async exportCSV(
    @Req() req: any,
    @Res() res: Response,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('accountId') accountId?: string,
    @Query('type') type?: string,
  ) {
    const query: ExportQuery = { startDate, endDate, accountId, type };
    const csv = await this.exportService.exportCSV(req.user.id, query);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader(
      'Content-Disposition',
      'attachment; filename=transactions.csv',
    );
    res.send(csv);
  }

  @Get('pdf')
  async exportPDF(
    @Req() req: any,
    @Res() res: Response,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('accountId') accountId?: string,
    @Query('type') type?: string,
  ) {
    const query: ExportQuery = { startDate, endDate, accountId, type };
    const doc = await this.exportService.exportPDF(req.user.id, query);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader(
      'Content-Disposition',
      'attachment; filename=transactions.pdf',
    );
    doc.pipe(res);
  }
}
