import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../shared/models/team_summary.dart';

class FavoriteTeamController extends ChangeNotifier {
  FavoriteTeamController({
    TeamSummary? initialTeam,
    Future<void> Function(TeamSummary team)? onChanged,
  }) : _favoriteTeam = initialTeam,
       _onChanged = onChanged;

  TeamSummary? _favoriteTeam;
  final Future<void> Function(TeamSummary team)? _onChanged;

  TeamSummary? get favoriteTeam => _favoriteTeam;

  Future<void> selectTeam(TeamSummary team) async {
    if (_favoriteTeam?.id == team.id) {
      return;
    }

    _favoriteTeam = team;
    notifyListeners();
    final onChanged = _onChanged;
    if (onChanged != null) {
      unawaited(onChanged(team));
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
