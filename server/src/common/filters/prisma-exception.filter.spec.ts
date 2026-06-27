import { ArgumentsHost, HttpStatus } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaExceptionFilter } from './prisma-exception.filter';

describe('PrismaExceptionFilter', () => {
  it('maps Prisma initialization errors to 503', () => {
    const filter = new PrismaExceptionFilter();
    const json = jest.fn();
    const status = jest.fn().mockReturnValue({ json });
    const host = {
      switchToHttp: () => ({
        getRequest: () => ({
          url: '/api/teams',
        }),
        getResponse: () => ({
          status,
        }),
      }),
    } as ArgumentsHost;

    filter.catch(
      {
        message: 'Database connection failed',
      } as Prisma.PrismaClientInitializationError,
      host,
    );

    expect(status).toHaveBeenCalledWith(HttpStatus.SERVICE_UNAVAILABLE);
    const [firstCall] = json.mock.calls as unknown[][];
    const responseBody = firstCall?.[0] as {
      statusCode: number;
      message: string;
      error: string;
      path: string;
      timestamp: string;
    };

    expect(responseBody).toMatchObject({
      statusCode: HttpStatus.SERVICE_UNAVAILABLE,
      message: 'Database is unavailable. Please try again later.',
      error: 'Service Unavailable',
      path: '/api/teams',
    });
    // 내부 구현 정보(DB 연결 실패 원인 등)는 응답에 노출되지 않아야 한다.
    expect(responseBody).not.toHaveProperty('details');
    expect(responseBody.timestamp).toEqual(expect.any(String));
  });
});
