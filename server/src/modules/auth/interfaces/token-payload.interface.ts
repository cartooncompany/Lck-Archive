export interface BaseTokenPayload {
  sub: string;
  type: 'access' | 'refresh';
  iat: number;
  exp: number;
}

export interface AccessTokenPayload extends BaseTokenPayload {
  type: 'access';
  email: string;
}

export interface RefreshTokenPayload extends BaseTokenPayload {
  type: 'refresh';
}

export interface IssuedToken {
  token: string;
  expiresAt: Date;
}
