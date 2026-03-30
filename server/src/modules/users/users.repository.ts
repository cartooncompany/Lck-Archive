import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { UserEntity } from './entities/user.entity';

const userSelect = Prisma.validator<Prisma.UserSelect>()({
  id: true,
  nickname: true,
  email: true,
  passwordHash: true,
  favoriteTeamId: true,
  refreshTokenHash: true,
  createdAt: true,
  updatedAt: true,
});

export interface CreateUserInput {
  nickname: string;
  email: string;
  passwordHash: string;
  favoriteTeamId: string;
}

@Injectable()
export class UsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(input: CreateUserInput): Promise<UserEntity> {
    const user = await this.prisma.user.create({
      data: input,
      select: userSelect,
    });

    return user as UserEntity;
  }

  async findById(id: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: userSelect,
    });

    return user as UserEntity | null;
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({
      where: { email },
      select: userSelect,
    });

    return user as UserEntity | null;
  }

  async favoriteTeamExists(teamId: string): Promise<boolean> {
    const count = await this.prisma.team.count({
      where: { id: teamId },
    });

    return count > 0;
  }

  async updateRefreshTokenHash(
    userId: string,
    refreshTokenHash: string | null,
  ): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        refreshTokenHash,
      },
    });
  }
}
