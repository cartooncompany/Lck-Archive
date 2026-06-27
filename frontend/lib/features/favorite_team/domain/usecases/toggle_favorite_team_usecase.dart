import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/features/teams/domain/repository/teams_repository_interface.dart';

class ToggleFavoriteTeamUseCase {
  const ToggleFavoriteTeamUseCase(this.teamsRepository);

  final ITeamsRepository teamsRepository;

  Future<void> call(TeamSummary? team) async {
    await teamsRepository.saveFavoriteTeamId(team?.id);
  }
}
