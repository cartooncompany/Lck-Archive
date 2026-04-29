import '../../../../shared/models/lck_match_detail.dart';
import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../teams/data/dto/team_match_dto.dart';
import '../datasource/matches_remote_data_source.dart';
import '../dto/match_detail_dto.dart';

class MatchesRepository {
  MatchesRepository({required MatchesRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final MatchesRemoteDataSource _remoteDataSource;

  Future<List<LckScheduledMatch>> getScheduledMatches({
    required DateTime from,
    DateTime? to,
  }) async {
    final response = await _remoteDataSource.getScheduledMatches(
      from: from,
      to: to,
    );
    return response.items.map(_mapScheduledMatch).toList();
  }

  Future<void> requestLckSync() {
    return _remoteDataSource.requestLckSync();
  }

  Future<LckMatchDetail> getMatchDetail(String id) async {
    final dto = await _remoteDataSource.getMatchDetail(id);
    return _mapMatchDetail(dto);
  }

  LckScheduledMatch _mapScheduledMatch(TeamMatchDto dto) {
    return LckScheduledMatch(
      id: dto.id,
      scheduledAt: dto.scheduledAt,
      split: dto.split,
      stage: dto.stage,
      status: dto.status,
      homeTeam: _mapTeam(dto.homeTeam),
      awayTeam: _mapTeam(dto.awayTeam),
    );
  }

  LckScheduledTeam _mapTeam(TeamMatchTeamDto dto) {
    return LckScheduledTeam(
      id: dto.id,
      name: dto.name,
      shortName: dto.shortName,
      logoUrl: dto.logoUrl,
    );
  }

  LckMatchDetail _mapMatchDetail(MatchDetailDto dto) {
    return LckMatchDetail(
      id: dto.id,
      scheduledAt: dto.scheduledAt,
      seasonYear: dto.seasonYear,
      split: dto.split,
      stage: dto.stage,
      status: dto.status,
      homeTeam: _mapTeam(dto.homeTeam),
      awayTeam: _mapTeam(dto.awayTeam),
      score: LckMatchScore(home: dto.score.home, away: dto.score.away),
      winner: dto.winner == null ? null : _mapTeam(dto.winner!),
      matchNumber: dto.matchNumber,
      vodUrl: dto.vodUrl,
      participants: dto.participants.map(_mapParticipant).toList(),
      games: dto.games.map(_mapGame).toList(),
    );
  }

  LckMatchParticipant _mapParticipant(MatchParticipantDto dto) {
    return LckMatchParticipant(
      playerId: dto.playerId,
      playerName: dto.playerName,
      position: dto.position,
      isStarter: dto.isStarter,
      team: _mapTeam(dto.team),
    );
  }

  LckMatchGame _mapGame(MatchGameDto dto) {
    return LckMatchGame(
      sequenceNumber: dto.sequenceNumber,
      mapName: dto.mapName,
      duration: dto.duration,
      startedAt: dto.startedAt,
      winner: dto.winner == null ? null : _mapTeam(dto.winner!),
      playerStats: dto.playerStats.map(_mapPlayerStat).toList(),
      draftActions: dto.draftActions.map(_mapDraftAction).toList(),
    );
  }

  LckMatchGamePlayerStat _mapPlayerStat(MatchGamePlayerStatDto dto) {
    return LckMatchGamePlayerStat(
      playerId: dto.playerId,
      playerName: dto.playerName,
      team: _mapTeam(dto.team),
      position: dto.position,
      championName: dto.championName,
      kills: dto.kills,
      deaths: dto.deaths,
      assists: dto.assists,
      totalGold: dto.totalGold,
      damageDealt: dto.damageDealt,
      damageTaken: dto.damageTaken,
      visionScore: dto.visionScore,
      kdaRatio: dto.kdaRatio,
      killParticipation: dto.killParticipation,
    );
  }

  LckMatchDraftAction _mapDraftAction(MatchDraftActionDto dto) {
    return LckMatchDraftAction(
      type: dto.type,
      sequenceNumber: dto.sequenceNumber,
      drafterId: dto.drafterId,
      drafterType: dto.drafterType,
      draftableType: dto.draftableType,
      draftableName: dto.draftableName,
    );
  }
}
