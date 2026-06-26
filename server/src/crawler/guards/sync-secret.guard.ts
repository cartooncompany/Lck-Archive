import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import { timingSafeEqual } from 'crypto';

@Injectable()
export class SyncSecretGuard implements CanActivate {
  private readonly secret: string | undefined;

  constructor(private readonly configService: ConfigService) {
    this.secret = this.configService.get<string>('SYNC_SECRET');
  }

  canActivate(context: ExecutionContext): boolean {
    if (!this.secret) {
      throw new UnauthorizedException(
        'Sync endpoint is disabled: SYNC_SECRET is not configured',
      );
    }

    const request = context.switchToHttp().getRequest<Request>();
    const provided = request.headers['x-sync-secret'];

    if (typeof provided !== 'string') {
      throw new UnauthorizedException('X-Sync-Secret header is required');
    }

    if (!this.safeCompare(provided, this.secret)) {
      throw new UnauthorizedException('Invalid sync secret');
    }

    return true;
  }

  private safeCompare(a: string, b: string): boolean {
    const bufA = Buffer.from(a);
    const bufB = Buffer.from(b);

    if (bufA.length !== bufB.length) {
      return false;
    }

    return timingSafeEqual(bufA, bufB);
  }
}
