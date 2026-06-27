import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:frontend/app/app_dependencies.dart';
import 'package:frontend/core/error/app_failure.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/shared/models/lck_match_detail.dart';
import 'package:frontend/shared/models/lck_scheduled_match.dart';
import 'package:frontend/shared/models/news_article.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/features/matches/presentation/utils/match_prediction_storage.dart';

/// 홈 화면이 표시할 데이터 묶음. (불변)
@immutable
class HomeState {
  const HomeState({
    this.team,
    this.standings = const <TeamSummary>[],
    this.featuredNews = const <NewsArticle>[],
    this.scheduledMatches = const <LckScheduledMatch>[],
    this.scheduleError,
    this.recentResults = const <LckMatchDetail>[],
    this.recentResultsError,
  });

  final TeamSummary? team;
  final List<TeamSummary> standings;
  final List<NewsArticle> featuredNews;
  final List<LckScheduledMatch> scheduledMatches;
  final String? scheduleError;
  final List<LckMatchDetail> recentResults;
  final String? recentResultsError;
}

/// 홈 화면의 데이터 로딩과 상태를 담당하는 ViewModel.
///
/// 위젯(`HomePage`)에서 `FutureBuilder` + `setState`로 흩어져 있던 데이터
/// 로딩, 일정 동기화, 승부 예측 저장 로직을 한곳에 모아 테스트와 재사용이
/// 쉬워지도록 분리했다.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AppDependencies dependencies,
    required LocalStorage localStorage,
  }) : _dependencies = dependencies,
       _localStorage = localStorage;

  final AppDependencies _dependencies;
  final LocalStorage _localStorage;

  HomeState _state = const HomeState();
  bool _isLoading = false;
  bool _isSyncingSchedule = false;
  bool _disposed = false;
  String? _loadedTeamId;
  Map<String, String> _matchPredictions = <String, String>{};

  HomeState get state => _state;
  bool get isLoading => _isLoading;
  bool get isSyncingSchedule => _isSyncingSchedule;
  Map<String, String> get matchPredictions => _matchPredictions;
  String? get loadedTeamId => _loadedTeamId;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// 응원팀이 바뀌었거나 아직 로드하지 않았으면 홈 데이터를 (재)로딩한다.
  ///
  /// `build` 도중 호출되어도 안전하도록, 재진입을 막기 위해 대상 팀 id를 즉시
  /// 기록하고 실제 로딩은 마이크로태스크로 미뤄 build 사이클 중 notify가
  /// 발생하지 않게 한다.
  void loadIfNeeded(TeamSummary? favoriteTeam) {
    if (_loadedTeamId == favoriteTeam?.id && (_state.team != null || _isLoading)) {
      return;
    }
    _loadedTeamId = favoriteTeam?.id;
    scheduleMicrotask(() => load(favoriteTeam));
  }

  Future<void> load(TeamSummary? favoriteTeam) async {
    _loadedTeamId = favoriteTeam?.id;
    _isLoading = true;
    _safeNotify();

    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = DateTime(now.year, now.month, now.day, 23, 59, 59)
        .add(Duration(days: 7 - now.weekday));

    // 독립적인 요청들을 병렬로 시작하되, 각각을 생성 즉시 에러 흡수 래퍼로
    // 감싸 어떤 요청이 먼저 실패해도 unhandled future 예외가 되지 않게 한다.
    final teamFuture = _guard<TeamSummary?>(
      favoriteTeam == null
          ? Future<TeamSummary?>.value(null)
          : _dependencies.teamsRepository.getTeam(favoriteTeam.id),
    );
    final standingsFuture = _guard<List<TeamSummary>>(
      _dependencies.teamsRepository.getTeams(),
    );
    final featuredNewsFuture = _guard<List<NewsArticle>>(
      favoriteTeam == null
          ? _dependencies.newsRepository
                .getNews(limit: 3)
                .then((response) => response.items)
          : _dependencies.newsRepository.getFeaturedNewsForTeam(
              teamName: favoriteTeam.name,
              shortName: favoriteTeam.initials,
              limit: 3,
            ),
    );
    final scheduledMatchesFuture = _guard<List<LckScheduledMatch>>(
      _dependencies.matchesRepository.getScheduledMatches(
        from: startOfWeek.toUtc(),
        to: endOfWeek.toUtc(),
      ),
    );
    final recentResultsFuture = _guard<List<LckMatchDetail>>(
      _dependencies.matchesRepository.getRecentResults(limit: 3),
    );

    final teamResult = await teamFuture;
    final TeamSummary? team = teamResult.value ?? favoriteTeam;

    final standingsResult = await standingsFuture;
    final standings = (standingsResult.value ?? const <TeamSummary>[])
      ..sort(_compareStandings);

    final featuredNewsResult = await featuredNewsFuture;
    final featuredNews = featuredNewsResult.value ?? const <NewsArticle>[];

    final scheduledResult = await scheduledMatchesFuture;
    final scheduledMatches =
        scheduledResult.value ?? const <LckScheduledMatch>[];
    final scheduleError = scheduledResult.value != null
        ? null
        : (scheduledResult.failureMessage ?? '경기 일정을 불러오지 못했습니다.');

    final recentResult = await recentResultsFuture;
    final recentResults = recentResult.value ?? const <LckMatchDetail>[];
    final recentResultsError = recentResult.value != null
        ? null
        : (recentResult.failureMessage ?? '최근 경기 결과를 불러오지 못했습니다.');

    _state = HomeState(
      team: team,
      standings: standings,
      featuredNews: featuredNews,
      scheduledMatches: scheduledMatches,
      scheduleError: scheduleError,
      recentResults: recentResults,
      recentResultsError: recentResultsError,
    );
    _isLoading = false;
    _safeNotify();
  }

  /// future를 즉시 감싸 에러를 흡수한다. 성공 시 값을, 실패 시 메시지를 담아
  /// 반환하므로 호출부에서 unhandled future 예외가 발생하지 않는다.
  Future<_Result<T>> _guard<T>(Future<T> future) {
    return future.then((value) => _Result<T>(value: value)).catchError(
      (Object error) {
        final message = error is AppFailure ? error.message : null;
        return _Result<T>(failureMessage: message);
      },
    );
  }

  /// LCK 일정 동기화를 서버에 요청하고 성공 시 홈 데이터를 새로고침한다.
  /// 반환값: 사용자에게 표시할 메시지 (성공/실패 모두)
  Future<String> requestScheduleSync(TeamSummary? favoriteTeam) async {
    if (_isSyncingSchedule) {
      return '이미 동기화를 요청했습니다.';
    }

    _isSyncingSchedule = true;
    _safeNotify();

    try {
      await _dependencies.matchesRepository.requestLckSync();
      await load(favoriteTeam);
      return 'LCK 일정 동기화를 요청했습니다. 잠시 후 새로고침해 주세요.';
    } on AppFailure catch (error) {
      return error.message;
    } catch (_) {
      return '동기화 요청 중 오류가 발생했습니다.';
    } finally {
      _isSyncingSchedule = false;
      _safeNotify();
    }
  }

  Future<void> refreshPredictions() async {
    final predictions = await loadMatchPredictions(_localStorage);
    _matchPredictions = predictions;
    _safeNotify();
  }

  Future<void> toggleMatchPrediction({
    required String matchId,
    required String teamId,
  }) async {
    final currentTeamId = _matchPredictions[matchId];
    final next = <String, String>{..._matchPredictions};
    if (currentTeamId == teamId) {
      next.remove(matchId);
    } else {
      next[matchId] = teamId;
    }

    _matchPredictions = next;
    _safeNotify();

    await saveMatchPredictions(_localStorage, next);
  }

  int _compareStandings(TeamSummary left, TeamSummary right) {
    if (left.rank == 0 && right.rank == 0) {
      return left.name.compareTo(right.name);
    }
    if (left.rank == 0) {
      return 1;
    }
    if (right.rank == 0) {
      return -1;
    }
    return left.rank.compareTo(right.rank);
  }
}

/// 비동기 요청의 결과를 안전하게 담는 래퍼. 성공 시 [value],
/// 실패 시 [failureMessage]가 설정된다. (둘 중 하나만 의미를 가짐)
@immutable
class _Result<T> {
  const _Result({this.value, this.failureMessage});

  final T? value;
  final String? failureMessage;
}
