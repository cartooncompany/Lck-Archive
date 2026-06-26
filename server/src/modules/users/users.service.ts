import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UserProfileResponseDto } from './responses/user-profile.response';
import { UsersRepository } from './users.repository';

@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: UsersRepository) {}

  async getMyProfile(userId: string): Promise<UserProfileResponseDto> {
    const user = await this.usersRepository.findById(userId);

    if (!user) {
      throw new NotFoundException(`User not found: ${userId}`);
    }

    return {
      nickname: user.nickname,
      email: user.email,
    };
  }

  async updateMyProfile(
    userId: string,
    dto: UpdateProfileDto,
  ): Promise<UserProfileResponseDto> {
    if (!dto.nickname && !dto.favoriteTeamId) {
      throw new BadRequestException(
        'nickname 또는 favoriteTeamId 중 하나 이상을 제공해야 합니다.',
      );
    }

    if (dto.favoriteTeamId) {
      const exists = await this.usersRepository.favoriteTeamExists(
        dto.favoriteTeamId,
      );
      if (!exists) {
        throw new BadRequestException(
          `팀을 찾을 수 없습니다: ${dto.favoriteTeamId}`,
        );
      }
    }

    const user = await this.usersRepository.updateProfile(userId, {
      nickname: dto.nickname,
      favoriteTeamId: dto.favoriteTeamId,
    });

    if (!user) {
      throw new NotFoundException(`User not found: ${userId}`);
    }

    return {
      nickname: user.nickname,
      email: user.email,
    };
  }

  async deleteMyAccount(userId: string): Promise<void> {
    const isDeleted = await this.usersRepository.deleteAccountData(userId);

    if (!isDeleted) {
      throw new NotFoundException(`User not found: ${userId}`);
    }
  }
}
