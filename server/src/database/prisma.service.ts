import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma, PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient {
  constructor(configService: ConfigService) {
    const databaseUrl = configService.get<string>('DATABASE_URL');
    const logLevels: Prisma.LogLevel[] =
      configService.get<string>('NODE_ENV') === 'development'
        ? ['query', 'info', 'warn', 'error']
        : ['warn', 'error'];

    const prismaOptions: Prisma.PrismaClientOptions = {
      log: logLevels,
    };

    if (databaseUrl) {
      prismaOptions.datasources = {
        db: {
          url: databaseUrl,
        },
      };
    }

    super(prismaOptions);
  }
}
