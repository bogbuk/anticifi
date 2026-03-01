import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { PredictionService } from './prediction.service.js';
import { PredictionRequestDto, ChatPredictionRequestDto, ForecastQueryDto } from './dto/prediction-request.dto.js';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard.js';
import { CurrentUser } from '../../common/decorators/current-user.decorator.js';

@Controller('predictions')
@UseGuards(JwtAuthGuard)
export class PredictionController {
  constructor(private readonly predictionService: PredictionService) {}

  @Post()
  async predict(
    @Body() dto: PredictionRequestDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.predictionService.getForecast(
      user.userId,
      dto.accountId,
      dto.daysAhead || 30,
    );
  }

  @Post('chat')
  async chatPredict(
    @Body() dto: ChatPredictionRequestDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.predictionService.chatPredict(user.userId, dto.question);
  }

  @Get('forecast/:accountId')
  async forecast(
    @Param('accountId') accountId: string,
    @Query() query: ForecastQueryDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.predictionService.getForecast(
      user.userId,
      accountId,
      query.daysAhead || 30,
    );
  }
}
