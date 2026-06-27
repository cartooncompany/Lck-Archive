import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/bloc/session_controller.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/shared/widgets/responsive_page_container.dart';
import 'package:frontend/shared/widgets/team_logo.dart';

class MyPagePage extends StatelessWidget {
  const MyPagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final favoriteTeam = session.isSignedIn ? FavoriteTeamScope.of(context).favoriteTeam : null;
    final nickname = session.userNickname ?? '로그인이 필요합니다';
    final email = session.userEmail ?? '로그인하지 않음';

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 120),
      children: [
        ResponsivePageContainer(
          maxWidth: 920,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackHeader = constraints.maxWidth < 640;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stackHeader) ...[
                    Row(
                      children: [
                        const Spacer(),
                        _SettingsButton(
                          onPressed: () =>
                              context.pushNamed(AppRouteNames.settings),
                        ),
                      ],
                    ),
                    Text(
                      '마이페이지',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.isSignedIn
                          ? '서버에서 가져온 내 프로필과 현재 응원팀 기준을 한 화면에서 확인합니다.'
                          : '로그인하면 내 프로필과 응원팀 기준이 저장됩니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '마이페이지',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                session.isSignedIn
                                    ? '서버에서 가져온 내 프로필과 현재 응원팀 기준을 한 화면에서 확인합니다.'
                                    : '로그인하면 내 프로필과 응원팀 기준이 저장됩니다.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SettingsButton(
                          onPressed: () =>
                              context.pushNamed(AppRouteNames.settings),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '내 정보',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: session.isSignedIn
                                        ? AppColors.success.withValues(
                                            alpha: 0.12,
                                          )
                                        : AppColors.warning.withValues(
                                            alpha: 0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: session.isSignedIn
                                          ? AppColors.success.withValues(
                                              alpha: 0.45,
                                            )
                                          : AppColors.warning.withValues(
                                              alpha: 0.45,
                                            ),
                                      width: 1.2,
                                    ),
                                    boxShadow: AppColors.neonGlow(
                                      color: session.isSignedIn
                                          ? AppColors.success
                                          : AppColors.warning,
                                      blurRadius: 4,
                                    ),
                                  ),
                                  child: Text(
                                    session.isSignedIn ? '로그인됨' : '비로그인',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: session.isSignedIn
                                              ? AppColors.success
                                              : AppColors.warning,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _ProfileField(
                              label: '닉네임',
                              value: nickname,
                              icon: Icons.person_outline_rounded,
                            ),
                            const Divider(height: 36),
                            _ProfileField(
                              label: '이메일',
                              value: email,
                              icon: Icons.mail_outline_rounded,
                            ),
                            const Divider(height: 36),
                            if (favoriteTeam != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: favoriteTeam.color.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: favoriteTeam.color.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: favoriteTeam.color.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: favoriteTeam.color
                                                .withValues(alpha: 0.25),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: TeamLogo(
                                        initials: favoriteTeam.initials,
                                        logoUrl: favoriteTeam.logoUrl,
                                        size: 48,
                                        foregroundColor: favoriteTeam.color,
                                        borderRadius: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '응원팀',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            favoriteTeam.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  shadows: [
                                                    Shadow(
                                                      color: favoriteTeam.color
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated.withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.glassBorderMuted,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.divider,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.shield_outlined,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '응원팀',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '응원 팀 없음',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (!session.isSignedIn) ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: AppColors.primaryGradient,
                                    ),
                                    boxShadow: AppColors.neonGlow(
                                      color: AppColors.accent,
                                      blurRadius: 10,
                                    ),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      session.showLogin();
                                      context.go(AppRoutePaths.login, extra: 'fromSettings');
                                    },
                                    icon: const Icon(
                                      Icons.login_rounded,
                                      color: AppColors.background,
                                    ),
                                    label: const Text(
                                      '로그인 / 회원가입으로 전환',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.background,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsButton extends StatefulWidget {
  const _SettingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.accent.withValues(alpha: 0.1)
              : AppColors.surface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? AppColors.accent.withValues(alpha: 0.45)
                : AppColors.glassBorderMuted,
            width: 1.2,
          ),
          boxShadow: _isHovered
              ? AppColors.neonGlow(color: AppColors.accent, blurRadius: 6)
              : null,
        ),
        child: IconButton(
          tooltip: '설정',
          onPressed: widget.onPressed,
          icon: AnimatedRotation(
            turns: _isHovered ? 30 / 360 : 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: Icon(
              Icons.settings_rounded,
              color: _isHovered ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
