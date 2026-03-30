import 'package:flutter/widgets.dart';

import '../../../../shared/models/team_summary.dart';

class FavoriteTeamController extends ChangeNotifier {
  FavoriteTeamController({required TeamSummary initialTeam})
    : _favoriteTeam = initialTeam;

  TeamSummary _favoriteTeam;

  TeamSummary get favoriteTeam => _favoriteTeam;

  void selectTeam(TeamSummary team) {
    _favoriteTeam = team;
    notifyListeners();
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
