export interface GridConnectionEdge<TNode> {
  node: TNode;
}

export interface GridPageInfo {
  endCursor?: string | null;
  hasNextPage?: boolean | null;
}

export interface GridConnection<TNode> {
  edges?: Array<GridConnectionEdge<TNode>> | null;
  pageInfo?: GridPageInfo | null;
}

export interface GridTeamBaseInfo {
  id: string;
  name: string;
  logoUrl?: string | null;
}

export interface GridSeriesTeam {
  baseInfo?: GridTeamBaseInfo | null;
}

export interface GridTournament {
  id: string;
  name: string;
}

export interface GridTitle {
  id: string;
  nameShortened?: string | null;
}

export interface GridSeriesNode {
  id: string;
  startTimeScheduled: string;
  tournament?: GridTournament | null;
  title?: GridTitle | null;
  teams?: GridSeriesTeam[] | null;
}

export interface GridPlayerRole {
  id?: string | null;
  name?: string | null;
  title?: {
    name?: string | null;
  } | null;
}

export interface GridPlayerNode {
  id: string;
  nickname: string;
  roles?: GridPlayerRole[] | null;
}

export interface GridSeriesPlayerState {
  id: string;
  name: string;
  participationStatus?: string | null;
}

export interface GridCharacter {
  id: string;
  name: string;
}

export interface GridGamePlayerState extends GridSeriesPlayerState {
  character?: GridCharacter | null;
  roles?: GridPlayerRole[] | null;
  kills?: number | null;
  deaths?: number | null;
  killAssistsGiven?: number | null;
  totalMoneyEarned?: number | null;
  damageDealt?: number | null;
  damageTaken?: number | null;
  visionScore?: number | null;
  kdaRatio?: number | null;
  killParticipation?: number | null;
}

export interface GridSeriesStateTeam {
  id: string;
  name?: string | null;
  won?: boolean | null;
  score?: number | null;
  players?: GridSeriesPlayerState[] | null;
}

export interface GridGameState {
  id?: string | null;
  sequenceNumber?: number | null;
  started?: boolean | null;
  finished?: boolean | null;
  forfeited?: boolean | null;
  startedAt?: string | null;
  duration?: string | null;
  map?: GridMapState | null;
  teams?: GridGameTeamState[] | null;
  draftActions?: GridDraftAction[] | null;
}

export interface GridGameTeamState extends GridSeriesStateTeam {
  side?: string | null;
  players?: GridGamePlayerState[] | null;
}

export interface GridMapState {
  id?: string | null;
  name: string;
}

export interface GridDraftEntity {
  id: string;
  type: string;
}

export interface GridDraftable extends GridDraftEntity {
  name: string;
}

export interface GridDraftAction {
  id: string;
  type: string;
  sequenceNumber: string;
  drafter: GridDraftEntity;
  draftable: GridDraftable;
}

export interface GridSeriesState {
  id?: string | null;
  format?: string | null;
  valid?: boolean | null;
  started?: boolean | null;
  finished?: boolean | null;
  forfeited?: boolean | null;
  startedAt?: string | null;
  updatedAt?: string | null;
  duration?: string | null;
  teams?: GridSeriesStateTeam[] | null;
  games?: GridGameState[] | null;
}

export interface GridLckSnapshotPayload {
  series: GridSeriesNode[];
  playersByTeamId: Record<string, GridPlayerNode[]>;
  statesBySeriesId: Record<string, GridSeriesState | null>;
}
