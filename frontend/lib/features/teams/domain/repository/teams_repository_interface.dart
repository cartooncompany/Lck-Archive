import 'package:frontend/shared/models/team_summary.dart';

abstract class ITeamsRepository {
  Future<List<TeamSummary>> getTeams({String? keyword, int limit = 100});
  Future<TeamSummary?> getInitialFavoriteTeam();
  Future<void> saveFavoriteTeamId(String? teamId);
  Future<TeamSummary> getTeam(String id);
  Future<TeamSummary?> findTeamByTag(String tag);
}
