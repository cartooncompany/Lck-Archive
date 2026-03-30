import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { SignUpDto } from './dto/sign-up.dto';
import { AccessTokenResponseDto } from './responses/access-token.response';
import { AuthSessionResponseDto } from './responses/auth-session.response';
import { AuthService } from './auth.service';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  @ApiOperation({ summary: '회원가입' })
  @ApiCreatedResponse({ type: AuthSessionResponseDto })
  @ApiConflictResponse({ description: '이미 사용 중인 이메일입니다.' })
  @ApiNotFoundResponse({ description: '응원 팀을 찾을 수 없습니다.' })
  signUp(@Body() dto: SignUpDto): Promise<AuthSessionResponseDto> {
    return this.authService.signUp(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '로그인' })
  @ApiOkResponse({ type: AuthSessionResponseDto })
  @ApiUnauthorizedResponse({
    description: '이메일 또는 비밀번호가 올바르지 않습니다.',
  })
  login(@Body() dto: LoginDto): Promise<AuthSessionResponseDto> {
    return this.authService.login(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '리프레시 토큰으로 액세스 토큰 재발급' })
  @ApiOkResponse({ type: AccessTokenResponseDto })
  @ApiUnauthorizedResponse({
    description: '유효하지 않은 리프레시 토큰입니다.',
  })
  refreshAccessToken(
    @Body() dto: RefreshTokenDto,
  ): Promise<AccessTokenResponseDto> {
    return this.authService.refreshAccessToken(dto);
  }
}
