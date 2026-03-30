import { Injectable, NotFoundException } from '@nestjs/common';
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
}
