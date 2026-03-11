import { Controller, Get, Query, Req, Res, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { PremiumGuard } from '../../common/guards/premium.guard.js';
import type { FastifyReply } from 'fastify';
import { ExportService, ExportQuery } from './export.service.js';

@Controller('export')
@UseGuards(AuthGuard('jwt'), PremiumGuard)
export class ExportController {
  constructor(private readonly exportService: ExportService) {}

  @Get('csv')
  async exportCSV(
    @Req() req: any,
    @Res() res: FastifyReply,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('accountId') accountId?: string,
    @Query('type') type?: string,
  ) {
    const query: ExportQuery = { startDate, endDate, accountId, type };
    const csv = await this.exportService.exportCSV(req.user.id, query);

    res.header('Content-Type', 'text/csv');
    res.header(
      'Content-Disposition',
      'attachment; filename=transactions.csv',
    );
    res.send(csv);
  }

  @Get('pdf')
  async exportPDF(
    @Req() req: any,
    @Res() res: FastifyReply,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('accountId') accountId?: string,
    @Query('type') type?: string,
  ) {
    const query: ExportQuery = { startDate, endDate, accountId, type };
    const doc = await this.exportService.exportPDF(req.user.id, query);

    res.header('Content-Type', 'application/pdf');
    res.header(
      'Content-Disposition',
      'attachment; filename=transactions.pdf',
    );

    // Collect PDF into buffer for Fastify (no stream piping)
    const chunks: Buffer[] = [];
    doc.on('data', (chunk: Buffer) => chunks.push(chunk));
    doc.on('end', () => {
      res.send(Buffer.concat(chunks));
    });
    doc.end();
  }
}
