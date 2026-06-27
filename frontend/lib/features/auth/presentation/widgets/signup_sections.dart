import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/shared/models/team_summary.dart';
import 'package:frontend/shared/widgets/bounce_tap_target.dart';
import 'package:frontend/shared/widgets/team_logo.dart';
import 'auth_shell.dart';

/// 스무스하게 옆으로 미끄러지듯 나타나는 페이드 & 슬라이드 전환 애니메이션 위젯
class _FormFadeTransition extends StatefulWidget {
  const _FormFadeTransition({required this.child});

  final Widget child;

  @override
  State<_FormFadeTransition> createState() => _FormFadeTransitionState();
}

class _FormFadeTransitionState extends State<_FormFadeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.04, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}


class SignupHeroSection extends StatelessWidget {
  const SignupHeroSection({
    required this.onBack,
    super.key,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FormFadeTransition(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 뒤로가기 버튼 리디자인
          TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text(
              '로그인으로 돌아가기',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 18),
          AuthGlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthSectionBadge(label: '회원가입'),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    '응원팀 기준으로\n기록을 봅니다.',
                    style: textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '계정을 만들면 선택한 팀 기준을 다음 방문에도 유지하며, LCK 전적 아카이브의 맞춤형 대시보드를 바로 탐색하실 수 있습니다.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignupFormPanel extends StatelessWidget {
  const SignupFormPanel({
    required this.formKey,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.selectedTeam,
    required this.obscurePassword,
    required this.isBusy,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onPickTeam,
    required this.onSubmit,
    required this.onShowLogin,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TeamSummary? selectedTeam;
  final bool obscurePassword;
  final bool isBusy;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onPickTeam;
  final VoidCallback onSubmit;
  final VoidCallback onShowLogin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FormFadeTransition(
      child: Form(
        key: formKey,
        child: AuthPhoneFrame(
          header: Row(
            children: [
              IconButton(
                onPressed: isBusy ? null : onShowLogin,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
              const Expanded(
                child: Text(
                  '계정 만들기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
          body: AuthFormCard(
            title: '회원가입',
            description: '기본 정보와 응원팀을 선택해 주세요.',
            errorMessage: errorMessage,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            footer: Column(
              children: [
                Text(
                  '이미 계정이 있나요?',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                BounceTapTarget(
                  onTap: isBusy ? () {} : onShowLogin,
                  child: Text(
                    '로그인',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
            children: [
              TextFormField(
                controller: nicknameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.nickname],
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '예: archive t1',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return '닉네임을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'fan@lckarchive.app',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return '이메일을 입력해 주세요.';
                  }
                  if (!trimmed.contains('@')) {
                    return '올바른 이메일 형식을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '8자 이상 입력',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: isBusy ? null : onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').length < 8) {
                    return '비밀번호는 8자 이상이어야 합니다.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => onSubmit(),
              ),
              const SizedBox(height: 16),
              SignupTeamField(
                selectedTeam: selectedTeam,
                onTap: isBusy ? null : onPickTeam,
              ),
              const SizedBox(height: 28),
              AuthPrimaryButton(
                label: isBusy ? '가입 중...' : '회원가입',
                icon: Icons.arrow_forward_rounded,
                onPressed: isBusy ? null : onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupTeamField extends StatelessWidget {
  const SignupTeamField({
    required this.selectedTeam,
    required this.onTap,
    super.key,
  });

  final TeamSummary? selectedTeam;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedColor = selectedTeam?.color ?? AppColors.surfaceElevated;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedTeam == null
                  ? AppColors.glassBorder
                  : selectedColor.withValues(alpha: 0.65),
              width: selectedTeam == null ? 1.0 : 1.2,
            ),
          ),
          child: Row(
            children: [
              if (selectedTeam != null)
                TeamLogo(
                  initials: selectedTeam!.initials,
                  logoUrl: selectedTeam!.logoUrl,
                  size: 38,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: selectedTeam!.color,
                  borderColor: selectedTeam!.color.withValues(alpha: 0.4),
                  borderRadius: 12,
                )
              else
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedTeam?.name ?? '응원팀 선택',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedTeam?.rankLabel ?? '가입 후 홈 기준으로 사용됩니다.',
                      style: textTheme.bodySmall?.copyWith(
                        color: selectedTeam != null
                            ? selectedColor
                            : AppColors.textSecondary,
                        fontWeight: selectedTeam != null
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupTeamPickerSheet extends StatelessWidget {
  const SignupTeamPickerSheet({
    required this.teams,
    required this.selectedTeamId,
    super.key,
  });

  final List<TeamSummary> teams;
  final String? selectedTeamId;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.glassBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ).createShader(bounds),
                        child: Text(
                          '응원팀 선택',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '선택한 팀은 가입 직후 홈 개인화 기준으로 사용됩니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: teams.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final team = teams[index];
                            final isSelected = team.id == selectedTeamId;

                            return InkWell(
                              onTap: () => Navigator.of(context).pop(team),
                              borderRadius: BorderRadius.circular(18),
                              child: Ink(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? team.color.withValues(alpha: 0.12)
                                      : AppColors.surfaceElevated.withValues(
                                          alpha: 0.35,
                                        ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? team.color.withValues(alpha: 0.65)
                                        : AppColors.divider,
                                    width: isSelected ? 1.2 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    TeamLogo(
                                      initials: team.initials,
                                      logoUrl: team.logoUrl,
                                      size: 40,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      foregroundColor: team.color,
                                      borderColor: isSelected
                                          ? team.color.withValues(alpha: 0.4)
                                          : AppColors.divider,
                                      borderRadius: 14,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            team.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            team.summary,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  height: 1.45,
                                                  fontSize: 13,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${team.rankLabel}  |  ${team.seasonRecord}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: isSelected
                                                      ? team.color
                                                      : AppColors.textMuted,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w800
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.chevron_right_rounded,
                                      color: isSelected
                                          ? team.color
                                          : AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
