import { ConfigService } from '@nestjs/config';
import { SequelizeModuleAsyncOptions } from '@nestjs/sequelize';

export const databaseConfig: SequelizeModuleAsyncOptions = {
  inject: [ConfigService],
  useFactory: (configService: ConfigService) => ({
    dialect: 'postgres',
    host: configService.get<string>('DB_HOST', 'localhost'),
    port: configService.get<number>('DB_PORT', 5432),
    username: configService.get<string>('DB_USER', 'postgres'),
    password: configService.get<string>('DB_PASSWORD', 'postgres'),
    database: configService.get<string>('DB_NAME', 'oracul'),
    autoLoadModels: true,
    synchronize: true,
    sync: {
      alter: configService.get<string>('NODE_ENV', 'development') === 'development',
    },
    logging: configService.get<string>('NODE_ENV') === 'development' ? console.log : false,
  }),
};
