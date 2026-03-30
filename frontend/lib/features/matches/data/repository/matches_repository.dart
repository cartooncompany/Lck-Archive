import '../../../../shared/models/lck_scheduled_match.dart';
import '../../../teams/data/dto/team_match_dto.dart';
import '../datasource/matches_remote_data_source.dart';

class MatchesRepository {
  MatchesRepository({required MatchesRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final MatchesRemoteDataSource _remoteDataSource;

  Future<List<LckScheduledMatch>> getScheduledMatches({
    required DateTime from,
  }) async {
    final response = await _remoteDataSource.getScheduledMatches(from: from);
    return response.items.map(_mapScheduledMatch).toList();
  }

  Future<void> requestLckSync() {
    return _remoteDataSource.requestLckSync();
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
}
