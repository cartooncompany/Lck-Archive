import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { PrismaExceptionFilter } from './common/filters/prisma-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.setGlobalPrefix('api');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  app.useGlobalFilters(new HttpExceptionFilter(), new PrismaExceptionFilter());

  const document = SwaggerModule.createDocument(
    app,
    new DocumentBuilder()
      .setTitle('LCK Archive API')
      .setDescription(
        [
          'LCK 팀, 선수, 경기, 뉴스 데이터 조회와 사용자 인증을 제공하는 REST API입니다.',
          '',
          '- 모든 엔드포인트의 기본 경로는 `/api` 입니다.',
          '- 인증이 필요한 요청은 우측 상단 `Authorize`에 `Bearer <accessToken>` 형식으로 입력합니다.',
          '- 오류 응답은 공통적으로 `statusCode`, `message`, `error`, `path`, `timestamp` 필드를 반환합니다.',
        ].join('\n'),
      )
      .setVersion('0.1.0')
      .addServer('/api', '기본 API Prefix')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'Authorization',
          in: 'header',
        },
        'access-token',
      )
      .addTag('Health', '헬스 체크 및 서버 상태 확인')
      .addTag('Auth', '회원가입, 로그인, 토큰 재발급')
      .addTag('Users', '인증된 사용자 프로필 조회')
      .addTag('Teams', 'LCK 팀 목록, 상세, 팀별 경기 조회')
      .addTag('Players', 'LCK 선수 목록 및 상세 조회')
      .addTag('Matches', 'LCK 경기 목록 및 상세 조회')
      .addTag('News', 'LCK 뉴스 기사 목록 조회')
      .addTag('Crawler', '수집 배치 수동 실행용 내부 엔드포인트')
      .build(),
  );

  SwaggerModule.setup('docs', app, document, {
    customSiteTitle: 'LCK Archive API Docs',
    jsonDocumentUrl: 'docs/openapi.json',
    swaggerOptions: {
      displayRequestDuration: true,
      docExpansion: 'none',
      filter: true,
      operationsSorter: 'alpha',
      persistAuthorization: true,
      tagsSorter: 'alpha',
    },
  });

  await app.listen(process.env.PORT ?? 3000);
}

void bootstrap();
