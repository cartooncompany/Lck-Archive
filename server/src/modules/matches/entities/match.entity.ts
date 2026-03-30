import { MatchStatus } from '@prisma/client';
import { BaseEntity } from '../../../common/entities/base.entity';

export class MatchEntity extends BaseEntity {
  externalSource: string;
  externalId: string;
  scheduledAt: Date;
  seasonYear: number;
  split: string;
  stage: string;
  matchNumber: string | null;
  homeTeamId: string;
  awayTeamId: string;
  homeScore: number;
  awayScore: number;
  winnerTeamId: string | null;
  status: MatchStatus;
  vodUrl: string | null;
}
