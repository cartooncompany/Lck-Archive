import { MatchStatus, PlayerPosition } from '@prisma/client';

export interface LolesportsApiResponse<T> {
  data: T;
}

export interface LolesportsScheduleEventTeam {
  name: string;
  code: string;
  image?: string | null;
  result?: {
    outcome?: 'win' | 'loss' | null;
    gameWins?: number | null;
  };
}

export interface LolesportsScheduleEvent {
  startTime: string;
  state: string;
  type: string;
  blockName?: string | null;
  league: {
    name: string;
    slug: string;
  };
  match?: {
    id: string;
    teams: LolesportsScheduleEventTeam[];
  };
}

export interface LolesportsScheduleData {
  schedule: LolesportsSchedule;
}

export interface LolesportsSchedule {
  pages: {
    older?: string | null;
    newer?: string | null;
  };
  events: LolesportsScheduleEvent[];
}

export interface LolesportsStandingsTeam {
  id: string;
  slug: string;
  name: string;
  code: string;
  image?: string | null;
  result?: {
    outcome?: 'win' | 'loss' | null;
    gameWins?: number | null;
  };
  record?: {
    wins?: number | null;
    losses?: number | null;
  };
}

export interface LolesportsStandingRanking {
  ordinal: number;
  teams: LolesportsStandingsTeam[];
}

export interface LolesportsStandingSection {
  name: string;
  matches: Array<{
    id: string;
    state: string;
    teams: LolesportsStandingsTeam[];
  }>;
  rankings: LolesportsStandingRanking[];
}

export interface LolesportsStandingStage {
  id: string;
  name: string;
  slug: string;
  sections: LolesportsStandingSection[];
}

export interface LolesportsStandingsEntry {
  stages: LolesportsStandingStage[];
}

export interface LolesportsStandingsData {
  standings: LolesportsStandingsEntry[];
}

export interface LolesportsTeamPlayer {
  id: string;
  summonerName: string;
  firstName?: string | null;
  lastName?: string | null;
  image?: string | null;
  role?: string | null;
}

export interface LolesportsTeamDetails {
  id: string;
  slug: string;
  name: string;
  code: string;
  image?: string | null;
  players: LolesportsTeamPlayer[];
}

export interface LolesportsTeamData {
  teams: LolesportsTeamDetails[];
}

export interface LolesportsSnapshotPayload {
  standings: LolesportsStandingsEntry[];
  scheduleEvents: LolesportsScheduleEvent[];
  teams: LolesportsTeamDetails[];
}

export interface RawLckTeamPayload {
  externalId: string;
  name: string;
  shortName: string;
  logoUrl?: string | null;
  rank?: number | null;
  wins?: number;
  losses?: number;
  setWins?: number;
  setLosses?: number;
}

export interface RawLckPlayerPayload {
  externalId: string;
  name: string;
  teamExternalId?: string | null;
  position: PlayerPosition;
  profileImageUrl?: string | null;
  realName?: string | null;
  nationality?: string | null;
  birthDate?: string | null;
  recentMatchCount?: number;
}

export interface RawLckMatchParticipantPayload {
  playerExternalId: string;
  teamExternalId: string;
  role?: PlayerPosition | null;
  isStarter?: boolean;
}

export interface RawLckMatchGamePlayerStatPayload {
  playerExternalId: string;
  teamExternalId: string;
  role?: PlayerPosition | null;
  participationStatus?: string | null;
  characterId?: string | null;
  characterName?: string | null;
  kills?: number | null;
  deaths?: number | null;
  assists?: number | null;
  totalMoneyEarned?: number | null;
  damageDealt?: number | null;
  damageTaken?: number | null;
  visionScore?: number | null;
  kdaRatio?: number | null;
  killParticipation?: number | null;
}

export interface RawLckMatchDraftActionPayload {
  externalId?: string | null;
  type: string;
  sequenceNumber: string;
  sequenceOrder?: number | null;
  drafterId?: string | null;
  drafterType?: string | null;
  draftableId?: string | null;
  draftableType?: string | null;
  draftableName?: string | null;
}

export interface RawLckMatchGamePayload {
  externalId?: string | null;
  sequenceNumber: number;
  startedAt?: string | null;
  duration?: string | null;
  mapId?: string | null;
  mapName?: string | null;
  winnerTeamExternalId?: string | null;
  playerStats?: RawLckMatchGamePlayerStatPayload[];
  draftActions?: RawLckMatchDraftActionPayload[];
}

export interface RawLckMatchPayload {
  externalId: string;
  scheduledAt: string;
  seasonYear: number;
  split: string;
  stage: string;
  matchNumber?: string | null;
  homeTeamExternalId: string;
  awayTeamExternalId: string;
  homeScore?: number;
  awayScore?: number;
  winnerTeamExternalId?: string | null;
  status?: MatchStatus;
  vodUrl?: string | null;
  participants?: RawLckMatchParticipantPayload[];
  games?: RawLckMatchGamePayload[];
}

export interface RawLckSnapshotPayload {
  teams: RawLckTeamPayload[];
  players: RawLckPlayerPayload[];
  matches: RawLckMatchPayload[];
}
