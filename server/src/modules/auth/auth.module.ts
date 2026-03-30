import { Module } from '@nestjs/common';
import { UsersRepository } from '../users/users.repository';
import { AccessTokenGuard } from './access-token.guard';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AuthTokenService } from './services/auth-token.service';
import { PasswordHasherService } from './services/password-hasher.service';

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    UsersRepository,
    PasswordHasherService,
    AuthTokenService,
    AccessTokenGuard,
  ],
  exports: [AuthTokenService, AccessTokenGuard],
})
export class AuthModule {}
