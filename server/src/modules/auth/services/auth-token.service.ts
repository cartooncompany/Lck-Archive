import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'crypto';
import {
  AccessTokenPayload,
  IssuedToken,
  RefreshTokenPayload,
} from '../interfaces/token-payload.interface';

interface JwtHeader {
  alg: 'HS256';
  typ: 'JWT';
}

type JwtPayload = Record<string, unknown>;

export const ACCESS_TOKEN_EXPIRES_IN_SECONDS = 60 * 60;
export const REFRESH_TOKEN_EXPIRES_IN_SECONDS = 60 * 60 * 24;

@Injectable()
export class AuthTokenService {
  private readonly accessSecret: string;
  private readonly refreshSecret: string;

  constructor(private readonly configService: ConfigService) {
    this.accessSecret =
      this.configService.get<string>('JWT_ACCESS_SECRET') ??
      'local-access-secret';
    this.refreshSecret =
      this.configService.get<string>('JWT_REFRESH_SECRET') ??
      'local-refresh-secret';
  }

  issueAccessToken(user: { id: string; email: string }): IssuedToken {
    return this.signToken(
      {
        sub: user.id,
        email: user.email,
        type: 'access',
      },
      this.accessSecret,
      ACCESS_TOKEN_EXPIRES_IN_SECONDS,
    );
  }

  issueRefreshToken(userId: string): IssuedToken {
    return this.signToken(
      {
        sub: userId,
        type: 'refresh',
      },
      this.refreshSecret,
      REFRESH_TOKEN_EXPIRES_IN_SECONDS,
    );
  }

  verifyAccessToken(token: string): AccessTokenPayload {
    const payload = this.verifyToken(token, this.accessSecret);

    if (!this.isAccessTokenPayload(payload)) {
      throw new UnauthorizedException('Invalid access token');
    }

    return payload;
  }

  verifyRefreshToken(token: string): RefreshTokenPayload {
    const payload = this.verifyToken(token, this.refreshSecret);

    if (!this.isRefreshTokenPayload(payload)) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    return payload;
  }

  private signToken(
    payload:
      | Omit<AccessTokenPayload, 'iat' | 'exp'>
      | Omit<RefreshTokenPayload, 'iat' | 'exp'>,
    secret: string,
    expiresInSeconds: number,
  ): IssuedToken {
    const issuedAt = this.getCurrentTimestampInSeconds();
    const expiresAt = issuedAt + expiresInSeconds;
    const header: JwtHeader = {
      alg: 'HS256',
      typ: 'JWT',
    };
    const encodedHeader = this.encodeJson(header);
    const encodedPayload = this.encodeJson({
      ...payload,
      iat: issuedAt,
      exp: expiresAt,
    });
    const signature = this.sign(`${encodedHeader}.${encodedPayload}`, secret);

    return {
      token: `${encodedHeader}.${encodedPayload}.${signature}`,
      expiresAt: new Date(expiresAt * 1000),
    };
  }

  private verifyToken(token: string, secret: string): JwtPayload {
    const [encodedHeader, encodedPayload, signature] = token.split('.');

    if (!encodedHeader || !encodedPayload || !signature) {
      throw new UnauthorizedException('Malformed token');
    }

    const header = this.decodeJson<JwtHeader>(encodedHeader);

    if (header.alg !== 'HS256' || header.typ !== 'JWT') {
      throw new UnauthorizedException('Unsupported token');
    }

    const expectedSignature = this.sign(
      `${encodedHeader}.${encodedPayload}`,
      secret,
    );

    if (!this.safeCompare(signature, expectedSignature)) {
      throw new UnauthorizedException('Invalid token signature');
    }

    const payload = this.decodeJson<JwtPayload>(encodedPayload);

    if (typeof payload.exp !== 'number' || typeof payload.iat !== 'number') {
      throw new UnauthorizedException('Invalid token payload');
    }

    if (payload.exp <= this.getCurrentTimestampInSeconds()) {
      throw new UnauthorizedException('Token expired');
    }

    return payload;
  }

  private isAccessTokenPayload(
    payload: unknown,
  ): payload is AccessTokenPayload {
    if (!payload || typeof payload !== 'object') {
      return false;
    }

    return (
      (payload as JwtPayload).type === 'access' &&
      typeof (payload as JwtPayload).sub === 'string' &&
      typeof (payload as JwtPayload).email === 'string' &&
      typeof (payload as JwtPayload).iat === 'number' &&
      typeof (payload as JwtPayload).exp === 'number'
    );
  }

  private isRefreshTokenPayload(
    payload: unknown,
  ): payload is RefreshTokenPayload {
    if (!payload || typeof payload !== 'object') {
      return false;
    }

    return (
      (payload as JwtPayload).type === 'refresh' &&
      typeof (payload as JwtPayload).sub === 'string' &&
      typeof (payload as JwtPayload).iat === 'number' &&
      typeof (payload as JwtPayload).exp === 'number'
    );
  }

  private encodeJson(value: object): string {
    return Buffer.from(JSON.stringify(value)).toString('base64url');
  }

  private decodeJson<T>(value: string): T {
    try {
      return JSON.parse(Buffer.from(value, 'base64url').toString('utf8')) as T;
    } catch {
      throw new UnauthorizedException('Invalid token encoding');
    }
  }

  private sign(value: string, secret: string): string {
    return createHmac('sha256', secret).update(value).digest('base64url');
  }

  private safeCompare(left: string, right: string): boolean {
    const leftBuffer = Buffer.from(left);
    const rightBuffer = Buffer.from(right);

    if (leftBuffer.length !== rightBuffer.length) {
      return false;
    }

    return timingSafeEqual(leftBuffer, rightBuffer);
  }

  private getCurrentTimestampInSeconds(): number {
    return Math.floor(Date.now() / 1000);
  }
}
