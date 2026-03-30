import { Request } from 'express';
import { AccessTokenPayload } from './token-payload.interface';

export interface AuthRequest extends Request {
  authUser?: AccessTokenPayload;
}
