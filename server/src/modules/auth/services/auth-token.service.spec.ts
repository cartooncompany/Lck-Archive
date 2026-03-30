import { UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthTokenService } from './auth-token.service';

describe('AuthTokenService', () => {
  let service: AuthTokenService;

  beforeEach(() => {
    service = new AuthTokenService(
      new ConfigService({
        JWT_ACCESS_SECRET: 'test-access-secret',
        JWT_REFRESH_SECRET: 'test-refresh-secret',
      }),
    );
  });

  it('issues and verifies access tokens', () => {
    const issuedToken = service.issueAccessToken({
      id: 'user-1',
      email: 'faker@example.com',
    });
    const payload = service.verifyAccessToken(issuedToken.token);

    expect(payload.sub).toBe('user-1');
    expect(payload.email).toBe('faker@example.com');
    expect(payload.type).toBe('access');
  });

  it('rejects expired tokens', () => {
    const dateNowSpy = jest.spyOn(Date, 'now');

    dateNowSpy.mockReturnValue(1_700_000_000_000);
    const issuedToken = service.issueAccessToken({
      id: 'user-1',
      email: 'faker@example.com',
    });

    dateNowSpy.mockReturnValue(1_700_003_700_000);

    expect(() => service.verifyAccessToken(issuedToken.token)).toThrow(
      UnauthorizedException,
    );

    dateNowSpy.mockRestore();
  });
});
