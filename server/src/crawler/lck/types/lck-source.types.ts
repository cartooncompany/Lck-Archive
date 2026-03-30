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
}

export interface RawLckSnapshotPayload {
  teams: RawLckTeamPayload[];
  players: RawLckPlayerPayload[];
  matches: RawLckMatchPayload[];
}
