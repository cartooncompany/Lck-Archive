import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/session_controller.dart';
import '../../../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../../../features/favorite_team/presentation/widgets/favorite_team_picker_sheet.dart';
import '../../../../shared/widgets/responsive_page_container.dart';
import '../../../../shared/widgets/team_logo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;
    final session = SessionScope.of(context);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      children: [
        ResponsivePageContainer(
          maxWidth: 920,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '응원팀과 세션 상태를 함께 관리합니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: favoriteTeam != null
                          ? TeamLogo(
                              initials: favoriteTeam.initials,
                              logoUrl: favoriteTeam.logoUrl,
                              size: 40,
                              foregroundColor: favoriteTeam.color,
                              borderRadius: 999,
                            )
                          : const Icon(Icons.shield_outlined),
                      title: const Text('응원팀 변경'),
                      subtitle: Text(
                        favoriteTeam == null
                            ? session.isSignedIn
                                  ? '아직 선택한 응원팀이 없습니다. 선택 후 앱 로컬 개인화 기준이 적용됩니다.'
                                  : '아직 선택한 응원팀이 없습니다.'
                            : session.isSignedIn
                            ? '현재 ${favoriteTeam.name} 선택됨 · 앱 로컬 개인화 기준'
                            : '현재 ${favoriteTeam.name} 선택됨',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showPicker(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      enabled: !session.isBusy,
                      leading: Icon(
                        session.isSignedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                      ),
                      title: Text(session.isSignedIn ? '로그아웃' : '로그인 / 회원가입'),
                      subtitle: Text(
                        session.isSignedIn
                            ? '저장된 토큰을 삭제하고 랜딩으로 돌아갑니다.'
                            : '서버 계정으로 내 프로필과 세션을 유지합니다.',
                      ),
                      onTap: session.isBusy
                          ? null
                          : () => session.isSignedIn
                                ? _signOut(context, session)
                                : _moveToLogin(context, session),
                    ),
                    if (session.isSignedIn) ...[
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        enabled: !session.isBusy,
                        leading: const Icon(
                          Icons.person_remove_rounded,
                          color: AppColors.danger,
                        ),
                        title: Text(
                          '회원탈퇴',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.danger),
                        ),
                        subtitle: Text(
                          session.isBusy
                              ? '회원탈퇴를 처리하고 있습니다.'
                              : '계정과 저장된 인증 정보를 삭제합니다.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        onTap: session.isBusy
                            ? null
                            : () => _deleteAccount(context, session),
                      ),
                    ],
                    const Divider(height: 1),
                    const ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text('앱 정보'),
                      subtitle: Text('LCK Archive 1.0.0'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '개인화 안내',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      favoriteTeam == null
                          ? '응원팀을 선택하면 홈의 팀 카드, 최근 경기, 주요 선수, 관련 뉴스 노출 순서가 개인화됩니다.'
                          : session.isSignedIn
                          ? '응원팀을 바꾸면 홈의 팀 카드, 최근 경기, 주요 선수, 관련 뉴스 노출 순서가 로컬 기준으로 함께 바뀝니다. 현재 서버에는 응원팀 수정 API가 없어 앱 로컬 상태로 유지합니다.'
                          : '응원팀을 변경하면 홈의 팀 카드, 최근 경기, 주요 선수, 관련 뉴스 노출 순서가 함께 바뀝니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FavoriteTeamPickerSheet(),
    );
  }

  Future<void> _signOut(BuildContext context, SessionController session) async {
    final navigator = Navigator.of(context);
    await session.signOut();
    navigator.popUntil((route) => route.isFirst);
  }

  void _moveToLogin(BuildContext context, SessionController session) {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    session.showLogin();
  }

  Future<void> _deleteAccount(
    BuildContext context,
    SessionController session,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await session.deleteAccount();
    if (!context.mounted) {
      return;
    }

    if (success) {
      navigator.popUntil((route) => route.isFirst);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('회원탈퇴가 완료되었습니다.')));
      return;
    }

    if (!session.isSignedIn) {
      navigator.popUntil((route) => route.isFirst);
    }

    final errorMessage = session.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
