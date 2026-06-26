import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
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

/// 쫀득한 버튼 스케일 바운스 효과
class _BounceAction extends StatefulWidget {
  const _BounceAction({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_BounceAction> createState() => _BounceActionState();
}

class _BounceActionState extends State<_BounceAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({
    required this.onBack,
    required this.onGuest,
    required this.onSignUp,
    this.showBackButton = true,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onGuest;
  final VoidCallback onSignUp;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FormFadeTransition(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 뒤로가기 버튼 리디자인
          if (showBackButton) ...[
            TextButton.icon(
              onPressed: onBack,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text(
                '랜딩으로 돌아가기',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 18),
          ],
          AuthGlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthSectionBadge(label: '로그인'),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    '계정으로\n이어서 봅니다.',
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
                  'LCK 아카이브 회원 계정으로 로그인하여 나만의 응원팀 성적과 정밀한 기록 수치들을 계속 탐색하세요.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // 회원가입 버튼 (글래스 아웃라인 스타일)
                    _BounceAction(
                      onTap: onSignUp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          '회원가입',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    // 게스트로 둘러보기 (텍스트 버튼)
                    _BounceAction(
                      onTap: onGuest,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Text(
                          '게스트로 둘러보기',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.textSecondary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginFormPanel extends StatelessWidget {
  const LoginFormPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
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
  final FocusNode passwordFocusNode;
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

    return _FormFadeTransition(
      child: Form(
        key: formKey,
        child: AuthPhoneFrame(
          header: const AuthLogoMark(),
          body: AuthFormCard(
            title: '로그인',
            description: '계정의 이메일과 비밀번호를 입력하세요.',
            errorMessage: errorMessage,
            footer: Column(
              children: [
                Row(
                  children: [
                    // 회원가입 아웃라인 버튼
                    Expanded(
                      child: _BounceAction(
                        onTap: isBusy ? () {} : onShowSignUp,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '회원가입',
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 게스트 버튼
                    Expanded(
                      child: _BounceAction(
                        onTap: isBusy ? () {} : onGuest,
                        child: Container(
                          height: 48,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            '게스트',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              // 이메일 필드
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
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(passwordFocusNode),
              ),
              const SizedBox(height: 16),
              // 비밀번호 필드
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
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
              const SizedBox(height: 28),
              // 로그인 버튼 (AuthPrimaryButton 활용)
              AuthPrimaryButton(
                label: isBusy ? '로그인 중...' : '로그인',
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
