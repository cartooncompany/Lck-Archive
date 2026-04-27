import {
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiNoContentResponse,
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
} from '../../common/responses/error-response.dto';
import { AccessTokenGuard } from '../auth/access-token.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AccessTokenPayload } from '../auth/interfaces/token-payload.interface';
import { UserProfileResponseDto } from './responses/user-profile.response';
import { UsersService } from './users.service';

@ApiTags('Users')
@ApiServiceUnavailableResponse({
  description: '데이터베이스 연결을 사용할 수 없습니다.',
  type: ServiceUnavailableErrorResponseDto,
})
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @UseGuards(AccessTokenGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: '내 프로필 조회',
    description:
      'Bearer access token 기준으로 현재 로그인한 사용자의 프로필 정보를 조회합니다.',
  })
  @ApiOkResponse({
    type: UserProfileResponseDto,
    description: '현재 로그인한 사용자의 프로필 정보',
  })
  @ApiUnauthorizedResponse({
    description: '액세스 토큰이 없거나 만료되었거나 형식이 올바르지 않습니다.',
    type: ErrorResponseDto,
  })
  @ApiNotFoundResponse({
    description: '토큰의 사용자 id에 해당하는 사용자를 찾을 수 없습니다.',
    type: ErrorResponseDto,
  })
  getMyProfile(
    @CurrentUser() user: AccessTokenPayload,
  ): Promise<UserProfileResponseDto> {
    return this.usersService.getMyProfile(user.sub);
  }

  @Delete('me')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(AccessTokenGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: '회원 탈퇴',
    description:
      '현재 로그인한 사용자를 삭제합니다. 현재 스키마 기준으로 사용자 레코드와 저장된 인증 정보가 함께 제거됩니다.',
  })
  @ApiNoContentResponse({
    description: '회원 탈퇴가 완료되어 사용자 데이터가 삭제되었습니다.',
  })
  @ApiUnauthorizedResponse({
    description: '액세스 토큰이 없거나 만료되었거나 형식이 올바르지 않습니다.',
    type: ErrorResponseDto,
  })
  @ApiNotFoundResponse({
    description: '토큰의 사용자 id에 해당하는 사용자를 찾을 수 없습니다.',
    type: ErrorResponseDto,
  })
  deleteMyAccount(@CurrentUser() user: AccessTokenPayload): Promise<void> {
    return this.usersService.deleteMyAccount(user.sub);
  }
}
