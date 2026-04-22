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

export interface GridSeriesStateTeam {
  id: string;
  won?: boolean | null;
  score?: number | null;
}

export interface GridGameState {
  sequenceNumber?: number | null;
  teams?: GridSeriesStateTeam[] | null;
}

export interface GridSeriesState {
  valid?: boolean | null;
  started?: boolean | null;
  finished?: boolean | null;
  startedAt?: string | null;
  teams?: GridSeriesStateTeam[] | null;
  games?: GridGameState[] | null;
}

export interface GridLckSnapshotPayload {
  series: GridSeriesNode[];
  playersByTeamId: Record<string, GridPlayerNode[]>;
  statesBySeriesId: Record<string, GridSeriesState | null>;
}
