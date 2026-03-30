import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AccessTokenGuard } from '../auth/access-token.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AccessTokenPayload } from '../auth/interfaces/token-payload.interface';
import { UserProfileResponseDto } from './responses/user-profile.response';
import { UsersService } from './users.service';

@ApiTags('Users')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @UseGuards(AccessTokenGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: '마이페이지 정보 조회' })
  @ApiOkResponse({ type: UserProfileResponseDto })
  @ApiUnauthorizedResponse({ description: '유효한 액세스 토큰이 필요합니다.' })
  @ApiNotFoundResponse({ description: '사용자를 찾을 수 없습니다.' })
  getMyProfile(
    @CurrentUser() user: AccessTokenPayload,
  ): Promise<UserProfileResponseDto> {
    return this.usersService.getMyProfile(user.sub);
  }
}
