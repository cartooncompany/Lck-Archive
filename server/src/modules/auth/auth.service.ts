import {
  ConflictException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { UserProfileResponseDto } from '../users/responses/user-profile.response';
import { UserEntity } from '../users/entities/user.entity';
import { UsersRepository } from '../users/users.repository';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { SignUpDto } from './dto/sign-up.dto';
import { AccessTokenResponseDto } from './responses/access-token.response';
import { AuthSessionResponseDto } from './responses/auth-session.response';
import { AuthTokenService } from './services/auth-token.service';
import { PasswordHasherService } from './services/password-hasher.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersRepository: UsersRepository,
    private readonly passwordHasherService: PasswordHasherService,
    private readonly authTokenService: AuthTokenService,
  ) {}

  async signUp(dto: SignUpDto): Promise<AuthSessionResponseDto> {
    const email = this.normalizeEmail(dto.email);
    const existingUser = await this.usersRepository.findByEmail(email);

    if (existingUser) {
      throw new ConflictException('Email already in use');
    }

    const favoriteTeamExists = await this.usersRepository.favoriteTeamExists(
      dto.favoriteTeamId,
    );

    if (!favoriteTeamExists) {
      throw new NotFoundException(
        `Favorite team not found: ${dto.favoriteTeamId}`,
      );
    }

    const passwordHash = await this.passwordHasherService.hash(dto.password);

    try {
      const user = await this.usersRepository.create({
        nickname: dto.nickname.trim(),
        email,
        passwordHash,
        favoriteTeamId: dto.favoriteTeamId,
      });

      return this.createSession(user);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException('Email already in use');
      }

      throw error;
    }
  }

  async login(dto: LoginDto): Promise<AuthSessionResponseDto> {
    const user = await this.usersRepository.findByEmail(
      this.normalizeEmail(dto.email),
    );

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const isPasswordValid = await this.passwordHasherService.verify(
      dto.password,
      user.passwordHash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    return this.createSession(user);
  }

  async refreshAccessToken(
    dto: RefreshTokenDto,
  ): Promise<AccessTokenResponseDto> {
    const payload = this.authTokenService.verifyRefreshToken(dto.refreshToken);
    const user = await this.usersRepository.findById(payload.sub);

    if (!user || !user.refreshTokenHash) {
      throw new UnauthorizedException('Refresh token is not active');
    }

    const isRefreshTokenValid = await this.passwordHasherService.verify(
      dto.refreshToken,
      user.refreshTokenHash,
    );

    if (!isRefreshTokenValid) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const accessToken = this.authTokenService.issueAccessToken(user);

    return {
      accessToken: accessToken.token,
      accessTokenExpiresAt: accessToken.expiresAt.toISOString(),
    };
  }

  private async createSession(
    user: UserEntity,
  ): Promise<AuthSessionResponseDto> {
    const accessToken = this.authTokenService.issueAccessToken(user);
    const refreshToken = this.authTokenService.issueRefreshToken(user.id);
    const refreshTokenHash = await this.passwordHasherService.hash(
      refreshToken.token,
    );

    await this.usersRepository.updateRefreshTokenHash(
      user.id,
      refreshTokenHash,
    );

    return {
      accessToken: accessToken.token,
      accessTokenExpiresAt: accessToken.expiresAt.toISOString(),
      refreshToken: refreshToken.token,
      refreshTokenExpiresAt: refreshToken.expiresAt.toISOString(),
      user: this.toUserProfile(user),
    };
  }

  private toUserProfile(user: UserEntity): UserProfileResponseDto {
    return {
      nickname: user.nickname,
      email: user.email,
    };
  }

  private normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }
}
