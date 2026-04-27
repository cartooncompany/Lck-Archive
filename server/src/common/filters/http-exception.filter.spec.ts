import { ArgumentsHost, BadRequestException } from '@nestjs/common';
import { HttpExceptionFilter } from './http-exception.filter';

describe('HttpExceptionFilter', () => {
  it('formats validation errors with a consistent response body', () => {
    const filter = new HttpExceptionFilter();
    const json = jest.fn();
    const status = jest.fn().mockReturnValue({ json });
    const host = {
      switchToHttp: () => ({
        getRequest: () => ({
          url: '/api/auth/login',
        }),
        getResponse: () => ({
          status,
        }),
      }),
    } as ArgumentsHost;

    filter.catch(
      new BadRequestException([
        'email must be an email',
        'password must be longer than or equal to 8 characters',
      ]),
      host,
    );

    expect(status).toHaveBeenCalledWith(400);
    const [firstCall] = json.mock.calls as unknown[][];
    const responseBody = firstCall?.[0] as {
      statusCode: number;
      message: string[];
      error: string;
      path: string;
      timestamp: string;
    };

    expect(responseBody).toMatchObject({
      statusCode: 400,
      message: [
        'email must be an email',
        'password must be longer than or equal to 8 characters',
      ],
      error: 'Bad Request',
      path: '/api/auth/login',
    });
    expect(responseBody.timestamp).toEqual(expect.any(String));
  });
});
