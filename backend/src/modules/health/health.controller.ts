import { Controller, Get } from '@nestjs/common';
import { Sequelize } from 'sequelize-typescript';

@Controller('health')
export class HealthController {
  private readonly startTime = Date.now();

  constructor(private readonly sequelize: Sequelize) {}

  @Get()
  async check() {
    let dbStatus = 'ok';

    try {
      await this.sequelize.authenticate();
    } catch {
      dbStatus = 'error';
    }

    const uptimeMs = Date.now() - this.startTime;
    const uptimeSeconds = Math.floor(uptimeMs / 1000);

    return {
      status: dbStatus === 'ok' ? 'ok' : 'degraded',
      version: process.env.npm_package_version || '0.0.1',
      uptime: uptimeSeconds,
      database: dbStatus,
      timestamp: new Date().toISOString(),
    };
  }
}
