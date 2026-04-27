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
      details: string;
    };

    expect(responseBody).toMatchObject({
      statusCode: HttpStatus.SERVICE_UNAVAILABLE,
      message:
        'Database is unavailable. Check DATABASE_URL and database status.',
      error: 'Service Unavailable',
      path: '/api/teams',
      details: 'Database connection failed',
    });
    expect(responseBody.timestamp).toEqual(expect.any(String));
  });
});
