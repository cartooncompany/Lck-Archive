import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/session_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _savePreference = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 780;

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF060A16),
                  AppColors.background,
                  Color(0xFF111C35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                const _LoginBackdrop(),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _LoginIntro(
                                      onBack: session.showLanding,
                                      onGuest: session.continueAsGuest,
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _LoginFormPanel(
                                      formKey: _formKey,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      savePreference: _savePreference,
                                      onTogglePassword: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      onSavePreferenceChanged: (value) {
                                        setState(() {
                                          _savePreference = value;
                                        });
                                      },
                                      onSubmit: _submit,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _LoginIntro(
                                    onBack: session.showLanding,
                                    onGuest: session.continueAsGuest,
                                  ),
                                  const SizedBox(height: 24),
                                  _LoginFormPanel(
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    savePreference: _savePreference,
                                    onTogglePassword: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    onSavePreferenceChanged: (value) {
                                      setState(() {
                                        _savePreference = value;
                                      });
                                    },
                                    onSubmit: _submit,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    SessionScope.of(context).signIn(email: _emailController.text);
  }
}

class _LoginIntro extends StatelessWidget {
  const _LoginIntro({required this.onBack, required this.onGuest});

  final VoidCallback onBack;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('랜딩으로 돌아가기'),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'SIGN IN',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppStrings.appName,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '아카이브 로그인',
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.4,
              height: 1.06,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              '응원팀 기준 개인화를 유지하려면 이메일로 진입하세요. 아직 계정이 없다면 데모처럼 게스트로 바로 들어가도 됩니다.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const _IntroPoint(
            label: 'PERSONAL HOME',
            body: '응원팀을 바꾸면 홈과 뉴스 구성이 같이 바뀝니다.',
          ),
          const SizedBox(height: 16),
          const _IntroPoint(
            label: 'MATCH MEMORY',
            body: '최근 경기와 키플레이어 흐름을 같은 화면에서 연결합니다.',
          ),
          const SizedBox(height: 16),
          const _IntroPoint(
            label: 'FAST ENTRY',
            body: '랜딩, 로그인, 메인 전환을 한 세션 컨트롤러로 정리했습니다.',
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: onGuest,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
            child: const Text('게스트로 바로 입장'),
          ),
        ],
      ),
    );
  }
}

class _IntroPoint extends StatelessWidget {
  const _IntroPoint({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginFormPanel extends StatelessWidget {
  const _LoginFormPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.savePreference,
    required this.onTogglePassword,
    required this.onSavePreferenceChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool savePreference;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool> onSavePreferenceChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '계정 정보',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '간단한 데모 로그인 폼입니다. 유효성 검사를 통과하면 메인 화면으로 이동합니다.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'fan@lckarchive.app',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
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
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '6자 이상 입력',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => onSubmit(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: savePreference,
                    onChanged: (value) =>
                        onSavePreferenceChanged(value ?? false),
                    activeColor: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '다음 실행에서도 응원팀 개인화 유지',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text('아카이브 입장'),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.black.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '데모 흐름 점검용이라 서버 호출은 연결하지 않았습니다. 이메일과 비밀번호 형식만 확인한 뒤 바로 메인 쉘로 전환됩니다.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -80,
            top: 80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentStrong.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            right: -100,
            bottom: -20,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
