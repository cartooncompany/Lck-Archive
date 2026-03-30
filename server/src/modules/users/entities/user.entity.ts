import { BaseEntity } from '../../../common/entities/base.entity';

export class UserEntity extends BaseEntity {
  nickname: string;
  email: string;
  passwordHash: string;
  favoriteTeamId: string;
  refreshTokenHash: string | null;
}
