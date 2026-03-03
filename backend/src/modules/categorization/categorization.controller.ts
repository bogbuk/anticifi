import { Controller, Post, Body, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CategorizationService } from './categorization.service.js';
import { CategorizeTransactionDto } from './dto/categorize.dto.js';

@Controller('transactions')
@UseGuards(AuthGuard('jwt'))
export class CategorizationController {
  constructor(
    private readonly categorizationService: CategorizationService,
  ) {}

  @Post('categorize')
  async categorize(
    @Req() req: any,
    @Body() dto: CategorizeTransactionDto,
  ) {
    const suggestions = await this.categorizationService.suggestCategories(
      req.user.id,
      dto,
    );
    return { suggestions };
  }
}
