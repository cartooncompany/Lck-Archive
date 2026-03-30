import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('/api/health (GET)', async () => {
    const server = app.getHttpServer() as Parameters<typeof request>[0];

    const response = await request(server).get('/api/health').expect(200);

    expect(response.body).toMatchObject({
      service: 'LCK Archive API',
      version: '0.1.0',
    });
    expect(response.body).toHaveProperty('timestamp');
  });
});
