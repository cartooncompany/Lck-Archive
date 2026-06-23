import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../shared/models/team_summary.dart';
import '../../domain/usecases/toggle_favorite_team_usecase.dart';

class FavoriteTeamController extends ChangeNotifier {
  FavoriteTeamController({
    TeamSummary? initialTeam,
    required ToggleFavoriteTeamUseCase toggleFavoriteTeamUseCase,
  }) : _favoriteTeam = initialTeam,
       _toggleFavoriteTeamUseCase = toggleFavoriteTeamUseCase;

  TeamSummary? _favoriteTeam;
  final ToggleFavoriteTeamUseCase _toggleFavoriteTeamUseCase;

  TeamSummary? get favoriteTeam => _favoriteTeam;

  Future<void> selectTeam(TeamSummary? team) async {
    if (_favoriteTeam?.id == team?.id) {
      return;
    }

    _favoriteTeam = team;
    notifyListeners();
    try {
      await _toggleFavoriteTeamUseCase(team);
    } catch (_) {
      // 에러 롤백 혹은 로깅 정책 처리 가능
    }
  }
}

class FavoriteTeamScope extends InheritedNotifier<FavoriteTeamController> {
  const FavoriteTeamScope({
    required FavoriteTeamController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static FavoriteTeamController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<FavoriteTeamScope>();
    assert(scope != null, 'FavoriteTeamScope is not available in the tree.');
    return scope!.notifier!;
  }
}
