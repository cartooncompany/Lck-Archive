import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthRequest } from '../interfaces/auth-request.interface';
import { AccessTokenPayload } from '../interfaces/token-payload.interface';

export const CurrentUser = createParamDecorator(
  (
    _data: unknown,
    context: ExecutionContext,
  ): AccessTokenPayload | undefined => {
    const request = context.switchToHttp().getRequest<AuthRequest>();

    return request.authUser;
  },
);
