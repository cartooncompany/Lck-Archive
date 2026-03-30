import { PlayerPosition } from '@prisma/client';
import { BaseEntity } from '../../../common/entities/base.entity';

export class PlayerEntity extends BaseEntity {
  teamId: string | null;
  name: string;
  slug: string;
  position: PlayerPosition;
  profileImageUrl: string | null;
  realName: string | null;
  nationality: string | null;
  birthDate: Date | null;
  recentMatchCount: number;
  externalSource: string;
  externalId: string;
}
