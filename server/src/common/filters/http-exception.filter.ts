import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { STATUS_CODES } from 'http';

type ErrorMessage = string | string[];

interface HttpExceptionResponseBody {
  message?: ErrorMessage;
  error?: string;
}

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost): void {
    const http = host.switchToHttp();
    const request = http.getRequest<Request>();
    const response = http.getResponse<Response>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();
    const { message, error } = this.normalizeResponse(
      exceptionResponse,
      status,
      exception.message,
    );

    response.status(status).json({
      statusCode: status,
      message,
      error,
      path: request.url,
      timestamp: new Date().toISOString(),
    });
  }

  private normalizeResponse(
    exceptionResponse: string | object,
    status: number,
    fallbackMessage: string,
  ): { message: ErrorMessage; error: string } {
    const defaultError = STATUS_CODES[status] ?? 'Error';

    if (typeof exceptionResponse === 'string') {
      return {
        message: exceptionResponse,
        error: defaultError,
      };
    }

    const responseBody = exceptionResponse as HttpExceptionResponseBody;

    return {
      message: responseBody.message ?? fallbackMessage,
      error: responseBody.error ?? defaultError,
    };
  }
}
