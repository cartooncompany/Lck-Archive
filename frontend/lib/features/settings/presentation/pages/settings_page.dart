import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                border: const Border(
                  bottom: BorderSide(
                    color: AppColors.glassBorderMuted,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
      padding: const EdgeInsets.only(top: 24, bottom: 120),
      children: [
        ResponsivePageContainer(
          maxWidth: 920,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '응원팀과 세션 상태를 함께 관리합니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 설정 메뉴 그룹 (글래스모피즘 패널)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.glassBorderMuted),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _HoverSettingsTile(
                          leading: favoriteTeam != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: favoriteTeam.color.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: TeamLogo(
                                    initials: favoriteTeam.initials,
                                    logoUrl: favoriteTeam.logoUrl,
                                    size: 32,
                                    foregroundColor: favoriteTeam.color,
                                    borderRadius: 999,
                                  ),
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
                        const Divider(height: 1, color: AppColors.divider),
                        _HoverSettingsTile(
                          enabled: !session.isBusy,
                          leading: Icon(
                            session.isSignedIn
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                          ),
                          title: Text(
                            session.isSignedIn ? '로그아웃' : '로그인 / 회원가입',
                          ),
                          subtitle: Text(
                            session.isBusy
                                ? '처리 중...'
                                : session.isSignedIn
                                ? '저장된 토큰을 삭제하고 랜딩으로 돌아갑니다.'
                                : '서버 계정으로 내 프로필과 세션을 유지합니다.',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: session.isBusy
                              ? null
                              : () => session.isSignedIn
                                    ? _signOut(context, session)
                                    : _moveToLogin(context, session),
                        ),
                        if (session.isSignedIn) ...[
                          const Divider(height: 1, color: AppColors.divider),
                          _HoverSettingsTile(
                            enabled: !session.isBusy,
                            isDanger: true,
                            leading: const Icon(Icons.person_remove_rounded),
                            title: const Text('회원탈퇴'),
                            subtitle: Text(
                              session.isBusy
                                  ? '회원탈퇴를 처리하고 있습니다.'
                                  : '계정과 저장된 인증 정보를 삭제합니다.',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: session.isBusy
                                ? null
                                : () => _deleteAccount(context, session),
                          ),
                        ],
                        const Divider(height: 1, color: AppColors.divider),
                        const _HoverSettingsTile(
                          leading: Icon(Icons.info_outline_rounded),
                          title: Text('앱 정보'),
                          subtitle: Text('LCK Archive 1.0.0'),
                          trailing: null,
                          onTap: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 개인화 안내 패널
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.glassBorderMuted),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 사이버네틱 인포 데코레이션 바
                        Container(
                          width: 4,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: AppColors.neonGlow(
                              color: AppColors.accent,
                              blurRadius: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '개인화 안내',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                favoriteTeam == null
                                    ? '응원팀을 선택하면 홈의 팀 카드, 최근 경기, 주요 선수, 관련 뉴스 노출 순서가 개인화됩니다.'
                                    : session.isSignedIn
                                    ? '응원팀을 바꾸면 홈의 팀 카드, 최근 경기, 주요 선수, 관련 뉴스 노출 순서가 로컬 기준으로 함께 바뀝니다. 현재 서버에는 응원팀 수정 API가 없어 앱 로컬 상태로 유지합니다.'
                                    : '응원팀을 변경하면 홈의 팀 카드, 최근 경기, 주요 선수, 관련 뉴스 노출 순서가 함께 바뀝니다.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
    await session.signOut();
    if (!context.mounted) {
      return;
    }
    context.go(AppRoutePaths.landing);
  }

  void _moveToLogin(BuildContext context, SessionController session) {
    session.showLogin();
    context.go(AppRoutePaths.login);
  }

  Future<void> _deleteAccount(
    BuildContext context,
    SessionController session,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await session.deleteAccount();
    if (!context.mounted) {
      return;
    }

    if (success) {
      context.go(AppRoutePaths.landing);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('회원탈퇴가 완료되었습니다.')));
      return;
    }

    if (!session.isSignedIn) {
      context.go(AppRoutePaths.landing);
    }

    final errorMessage = session.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}

// 프리미엄 사이버네틱 무드를 위한 인터랙티브 호버 타일
class _HoverSettingsTile extends StatefulWidget {
  const _HoverSettingsTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDanger = false,
    this.enabled = true,
  });

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDanger;
  final bool enabled;

  @override
  State<_HoverSettingsTile> createState() => _HoverSettingsTileState();
}

class _HoverSettingsTileState extends State<_HoverSettingsTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isDanger ? AppColors.danger : AppColors.accent;
    final splashColor = activeColor.withValues(alpha: 0.1);
    final isClickable = widget.enabled && widget.onTap != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = isClickable),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? activeColor.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border.all(
            color: _isHovered
                ? activeColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: _isHovered
              ? AppColors.neonGlow(color: activeColor, blurRadius: 6)
              : null,
        ),
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          splashColor: splashColor,
          hoverColor: Colors.transparent,
          highlightColor: activeColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Leading Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? activeColor.withValues(alpha: 0.1)
                        : AppColors.surfaceElevated.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isHovered
                          ? activeColor.withValues(alpha: 0.25)
                          : AppColors.divider,
                      width: 1.2,
                    ),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: _isHovered
                          ? activeColor
                          : (widget.isDanger
                                ? AppColors.danger
                                : AppColors.textSecondary),
                      size: 22,
                    ),
                    child: Center(child: widget.leading),
                  ),
                ),
                const SizedBox(width: 18),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w800,
                              color: widget.isDanger
                                  ? AppColors.danger
                                  : AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                        child: widget.title,
                      ),
                      const SizedBox(height: 4),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        child: widget.subtitle,
                      ),
                    ],
                  ),
                ),
                // Trailing
                if (widget.trailing != null) ...[
                  const SizedBox(width: 12),
                  IconTheme(
                    data: IconThemeData(
                      color: _isHovered ? activeColor : AppColors.textSecondary,
                      size: 20,
                    ),
                    child: widget.trailing!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
