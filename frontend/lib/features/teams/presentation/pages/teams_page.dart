import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/app/app_dependencies_scope.dart';
import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/shared/widgets/app_search_field.dart';
import 'package:frontend/shared/widgets/responsive_page_container.dart';
import 'package:frontend/features/teams/presentation/widgets/team_list_card.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  static const _kDebounce = Duration(milliseconds: 350);

  String _query = '';
  Future<List<TeamSummary>>? _teamsFuture;
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _teamsFuture ??= _loadTeams();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeamSummary>>(
      future: _teamsFuture,
      builder: (context, snapshot) {
        final teams = snapshot.data ?? const <TeamSummary>[];

        return ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 120),
          children: [
            ResponsivePageContainer(
              maxWidth: 960,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LCK 팀',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '순위, 전적, 최근 흐름을 빠르게 비교할 수 있습니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppSearchField(
                    hintText: '팀명으로 검색',
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(_kDebounce, () {
                        if (!mounted) return;
                        setState(() {
                          _query = value.trim();
                          _teamsFuture = _loadTeams();
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      teams.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (teams.isEmpty)
                    _TeamsMessage(message: '검색 결과가 없습니다.')
                  else ...[
                    if (_query.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${teams.length}개 팀',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ...teams.map(
                      (team) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TeamListCard(
                          team: team,
                          onTap: () => _openTeam(context, team),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<TeamSummary>> _loadTeams() {
    return AppDependenciesScope.of(
      context,
    ).teamsRepository.getTeams(keyword: _query);
  }

  void _openTeam(BuildContext context, TeamSummary team) {
    context.pushNamed(AppRouteNames.teamDetail, extra: team);
  }
}

class _TeamsMessage extends StatelessWidget {
  const _TeamsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
