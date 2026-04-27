import 'package:flutter/material.dart';

import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/team_logo.dart';
import 'auth_shell.dart';

class SignupHeroSection extends StatelessWidget {
  const SignupHeroSection({
    required this.onBack,
    required this.onGuest,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onBack,
          style: TextButton.styleFrom(
            foregroundColor: AuthUiColors.heroMuted,
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('로그인으로 돌아가기'),
        ),
        const SizedBox(height: 18),
        AuthGlassPanel(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthSectionBadge(label: '회원가입'),
              const SizedBox(height: 18),
              Text(
                '가입 후 바로\n응원팀 기준 홈이 열립니다.',
                style: textTheme.headlineLarge?.copyWith(
                  color: AuthUiColors.heroText,
                  fontSize: 40,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '닉네임, 이메일, 비밀번호와 응원팀만 입력하면 됩니다. 가입이 끝나면 홈, 일정, 뉴스가 선택한 팀 기준으로 바로 정리됩니다.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AuthUiColors.heroMuted,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),
              const AuthBulletPoint(
                title: '가입 직후 개인화 적용',
                description: '선택한 응원팀을 기준으로 홈 카드, 팀 흐름, 관련 뉴스 노출 기준이 바로 맞춰집니다.',
              ),
              const SizedBox(height: 16),
              const AuthBulletPoint(
                title: '응원팀은 나중에도 변경 가능',
                description:
                    '설정 화면에서 다시 바꿀 수 있으니 지금은 가장 자주 보는 팀을 기준으로 선택하면 됩니다.',
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: onGuest,
                style: TextButton.styleFrom(
                  foregroundColor: AuthUiColors.heroMuted,
                ),
                child: const Text('게스트로 먼저 둘러보기'),
              ),
            ],
          ),
        ),
      ],
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

    return Form(
      key: formKey,
      child: AuthPhoneFrame(
        header: Row(
          children: [
            IconButton(
              onPressed: isBusy ? null : onShowLogin,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(foregroundColor: Colors.white),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
            ),
            const Expanded(
              child: Text(
                '회원가입',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
        body: AuthFormCard(
          errorMessage: errorMessage,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          footer: Column(
            children: [
              const SizedBox(height: 2),
              Text(
                '이미 계정이 있나요?',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AuthUiColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: isBusy ? null : onShowLogin,
                child: const Text('로그인'),
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
                hintText: '예: t1 archive',
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
                suffixIcon: IconButton(
                  onPressed: isBusy ? null : onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
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
              onPressed: isBusy ? null : onSubmit,
            ),
          ],
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
    final selectedColor = selectedTeam?.color ?? AuthUiColors.ink;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '응원팀',
              style: textTheme.labelMedium?.copyWith(
                color: AuthUiColors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (selectedTeam != null)
                  TeamLogo(
                    initials: selectedTeam!.initials,
                    logoUrl: selectedTeam!.logoUrl,
                    size: 30,
                    backgroundColor: const Color(0xFFF3F1ED),
                    foregroundColor: selectedTeam!.color,
                    borderRadius: 10,
                  )
                else
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F1ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: AuthUiColors.inkSoft,
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
                          color: AuthUiColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedTeam?.rankLabel ?? '가입 후 홈 개인화 기준으로 사용됩니다.',
                        style: textTheme.bodySmall?.copyWith(
                          color: selectedTeam != null
                              ? selectedColor
                              : AuthUiColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AuthUiColors.inkSoft,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: AuthUiColors.line),
          ],
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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 30,
                offset: const Offset(0, 16),
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AuthUiColors.lineStrong,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '응원팀 선택',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AuthUiColors.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '선택한 팀은 가입 직후 홈 개인화 기준으로 사용됩니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AuthUiColors.muted,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: ListView.separated(
                      itemCount: teams.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
                                  ? team.color.withValues(alpha: 0.10)
                                  : const Color(0xFFF9F7F4),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? team.color.withValues(alpha: 0.60)
                                    : AuthUiColors.line,
                              ),
                            ),
                            child: Row(
                              children: [
                                TeamLogo(
                                  initials: team.initials,
                                  logoUrl: team.logoUrl,
                                  size: 40,
                                  backgroundColor: Colors.white,
                                  foregroundColor: team.color,
                                  borderColor: AuthUiColors.line,
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
                                              color: AuthUiColors.ink,
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
                                              color: AuthUiColors.muted,
                                              height: 1.45,
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
                                                  : AuthUiColors.muted,
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
                                      : AuthUiColors.inkSoft,
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
    );
  }
}
