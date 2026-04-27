import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBody,
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiServiceUnavailableResponse,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import {
  ErrorResponseDto,
  ServiceUnavailableErrorResponseDto,
  ValidationErrorResponseDto,
} from '../../common/responses/error-response.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { SignUpDto } from './dto/sign-up.dto';
import { AccessTokenResponseDto } from './responses/access-token.response';
import { AuthSessionResponseDto } from './responses/auth-session.response';
import { AuthService } from './auth.service';

@ApiTags('Auth')
@ApiServiceUnavailableResponse({
  description: '데이터베이스 연결을 사용할 수 없습니다.',
  type: ServiceUnavailableErrorResponseDto,
})
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  @ApiOperation({
    summary: '회원가입',
    description:
      '신규 사용자를 생성하고 access token, refresh token, 사용자 기본 정보를 함께 반환합니다.',
  })
  @ApiBody({
    type: SignUpDto,
    description: '회원가입 요청 본문',
    examples: {
      default: {
        summary: '기본 회원가입 예시',
        value: {
          nickname: 'faker',
          email: 'faker@example.com',
          password: 'securePassword123!',
          favoriteTeamId: 'clx123team',
        },
      },
    },
  })
  @ApiCreatedResponse({
    type: AuthSessionResponseDto,
    description: '회원가입 완료 후 즉시 사용할 수 있는 인증 세션 정보',
  })
  @ApiBadRequestResponse({
    description: '요청 본문 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  @ApiConflictResponse({
    description: '이미 사용 중인 이메일입니다.',
    type: ErrorResponseDto,
  })
  @ApiNotFoundResponse({
    description: '요청한 favoriteTeamId에 해당하는 팀이 없습니다.',
    type: ErrorResponseDto,
  })
  signUp(@Body() dto: SignUpDto): Promise<AuthSessionResponseDto> {
    return this.authService.signUp(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '로그인',
    description:
      '이메일과 비밀번호로 로그인하고 access token, refresh token, 사용자 기본 정보를 반환합니다.',
  })
  @ApiBody({
    type: LoginDto,
    description: '로그인 요청 본문',
    examples: {
      default: {
        summary: '기본 로그인 예시',
        value: {
          email: 'faker@example.com',
          password: 'securePassword123!',
        },
      },
    },
  })
  @ApiOkResponse({
    type: AuthSessionResponseDto,
    description: '로그인에 성공한 사용자의 인증 세션 정보',
  })
  @ApiBadRequestResponse({
    description: '요청 본문 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  @ApiUnauthorizedResponse({
    description: '이메일 또는 비밀번호가 올바르지 않습니다.',
    type: ErrorResponseDto,
  })
  login(@Body() dto: LoginDto): Promise<AuthSessionResponseDto> {
    return this.authService.login(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '액세스 토큰 재발급',
    description:
      '유효한 refresh token을 검증한 뒤 새로운 access token과 만료 시각을 반환합니다.',
  })
  @ApiBody({
    type: RefreshTokenDto,
    description: '액세스 토큰 재발급 요청 본문',
    examples: {
      default: {
        summary: '기본 재발급 예시',
        value: {
          refreshToken:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.refresh-token.signature',
        },
      },
    },
  })
  @ApiOkResponse({
    type: AccessTokenResponseDto,
    description: '새로 발급된 액세스 토큰 정보',
  })
  @ApiBadRequestResponse({
    description: '요청 본문 검증에 실패했습니다.',
    type: ValidationErrorResponseDto,
  })
  @ApiUnauthorizedResponse({
    description:
      '리프레시 토큰이 유효하지 않거나 더 이상 활성 상태가 아닙니다.',
    type: ErrorResponseDto,
  })
  refreshAccessToken(
    @Body() dto: RefreshTokenDto,
  ): Promise<AccessTokenResponseDto> {
    return this.authService.refreshAccessToken(dto);
  }
}
