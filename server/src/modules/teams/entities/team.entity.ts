import { BaseEntity } from '../../../common/entities/base.entity';

export class TeamEntity extends BaseEntity {
  name: string;
  shortName: string;
  slug: string;
  logoUrl: string | null;
  rank: number | null;
  wins: number;
  losses: number;
  setWins: number;
  setLosses: number;
  setDifferential: number;
  externalSource: string;
  externalId: string;
}
