import 'package:flutter/material.dart';

import 'auth_shell.dart';

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({
    required this.onBack,
    required this.onGuest,
    required this.onSignUp,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onGuest;
  final VoidCallback onSignUp;

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
          label: const Text('랜딩으로 돌아가기'),
        ),
        const SizedBox(height: 18),
        AuthGlassPanel(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthSectionBadge(label: '로그인'),
              const SizedBox(height: 18),
              Text(
                '내 계정으로 이어서\n바로 아카이브를 봅니다.',
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
                '로그인하면 프로필, 응원팀 기준, 저장된 세션이 그대로 이어집니다. 필요한 입력만 남겨 바로 홈으로 들어가도록 구성했습니다.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AuthUiColors.heroMuted,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),
              const AuthBulletPoint(
                title: '세션과 프로필 유지',
                description: '다시 들어와도 내 계정 상태와 프로필 정보를 이어서 사용할 수 있습니다.',
              ),
              const SizedBox(height: 16),
              const AuthBulletPoint(
                title: '게스트 진입도 유지',
                description:
                    '바로 가입하지 않아도 동일한 시작점에서 먼저 둘러본 뒤 나중에 계정을 연결할 수 있습니다.',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: onSignUp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AuthUiColors.heroText,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('회원가입'),
                  ),
                  TextButton(
                    onPressed: onGuest,
                    style: TextButton.styleFrom(
                      foregroundColor: AuthUiColors.heroMuted,
                    ),
                    child: const Text('게스트로 둘러보기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginFormPanel extends StatelessWidget {
  const LoginFormPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isBusy,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onShowSignUp,
    required this.onGuest,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isBusy;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onShowSignUp;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: AuthPhoneFrame(
        header: const AuthLogoMark(),
        body: AuthFormCard(
          title: '로그인',
          centerTitle: true,
          errorMessage: errorMessage,
          footer: Column(
            children: [
              const SizedBox(height: 2),
              Text(
                '계정이 없나요?',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AuthUiColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: isBusy ? null : onShowSignUp,
                    child: const Text('회원가입'),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: isBusy ? null : onGuest,
                    child: const Text('게스트'),
                  ),
                ],
              ),
            ],
          ),
          children: [
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
              autofillHints: const [AutofillHints.password],
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
            const SizedBox(height: 28),
            AuthPrimaryButton(
              label: isBusy ? '로그인 중...' : '로그인',
              onPressed: isBusy ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
