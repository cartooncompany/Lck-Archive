import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../../shared/widgets/team_logo.dart';
import '../../../favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../bloc/session_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _initialized = false;
  late Future<List<TeamSummary>> _teamsFuture;
  TeamSummary? _selectedTeam;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    _selectedTeam = FavoriteTeamScope.of(context).favoriteTeam;
    _teamsFuture = AppDependenciesScope.of(context).teamsRepository.getTeams();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
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
                  Color(0xFF070C1A),
                  AppColors.background,
                  Color(0xFF0C1D32),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                const _SignupBackdrop(),
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
                                    child: _SignupIntro(
                                      onBack: session.showLogin,
                                      onGuest: session.continueAsGuest,
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _SignupFormPanel(
                                      formKey: _formKey,
                                      nicknameController: _nicknameController,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      selectedTeam: _selectedTeam,
                                      obscurePassword: _obscurePassword,
                                      isBusy: session.isBusy,
                                      errorMessage: session.errorMessage,
                                      onTogglePassword: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      onPickTeam: _pickTeam,
                                      onSubmit: _submit,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SignupIntro(
                                    onBack: session.showLogin,
                                    onGuest: session.continueAsGuest,
                                  ),
                                  const SizedBox(height: 24),
                                  _SignupFormPanel(
                                    formKey: _formKey,
                                    nicknameController: _nicknameController,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    selectedTeam: _selectedTeam,
                                    obscurePassword: _obscurePassword,
                                    isBusy: session.isBusy,
                                    errorMessage: session.errorMessage,
                                    onTogglePassword: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    onPickTeam: _pickTeam,
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

  Future<void> _pickTeam() async {
    try {
      final teams = await _teamsFuture;
      if (!mounted) {
        return;
      }

      final selectedTeam = await showModalBottomSheet<TeamSummary>(
        context: context,
        backgroundColor: AppColors.background,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _SignupTeamPickerSheet(
          teams: teams,
          selectedTeamId: _selectedTeam?.id,
        ),
      );

      if (selectedTeam != null) {
        setState(() {
          _selectedTeam = selectedTeam;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('응원팀 목록을 불러오지 못했습니다.\n$error')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedTeam = _selectedTeam;
    if (selectedTeam == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('응원팀을 선택해 주세요.')));
      return;
    }

    final session = SessionScope.of(context);
    final favoriteTeamController = FavoriteTeamScope.of(context);
    final success = await session.signUp(
      nickname: _nicknameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      favoriteTeamId: selectedTeam.id,
    );

    if (success) {
      await favoriteTeamController.selectTeam(selectedTeam);
      return;
    }

    if (!mounted) {
      return;
    }

    final errorMessage = session.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}

class _SignupIntro extends StatelessWidget {
  const _SignupIntro({required this.onBack, required this.onGuest});

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
            label: const Text('로그인으로 돌아가기'),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'SIGN UP',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '개인 아카이브 시작',
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
              '회원가입 시 닉네임, 이메일, 비밀번호와 현재 응원팀을 함께 저장합니다. 응원팀은 홈 개인화 기준으로 바로 사용됩니다.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
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

class _SignupFormPanel extends StatelessWidget {
  const _SignupFormPanel({
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '회원가입 정보',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '서버 `/auth/signup` 스펙에 맞춰 닉네임, 이메일, 비밀번호, 응원팀을 함께 전송합니다.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 18),
              _SignupErrorBanner(message: errorMessage!),
            ],
            const SizedBox(height: 22),
            TextFormField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                hintText: 'faker archive',
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
            Text(
              '현재 응원팀',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: isBusy ? null : onPickTeam,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    if (selectedTeam != null)
                      TeamLogo(
                        initials: selectedTeam!.initials,
                        logoUrl: selectedTeam!.logoUrl,
                        size: 44,
                        foregroundColor: selectedTeam!.color,
                        borderRadius: 14,
                      )
                    else
                      const Icon(Icons.shield_outlined),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedTeam?.name ?? '응원팀 선택',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedTeam?.seasonRecord ?? '가입 시 서버로 함께 저장됩니다.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isBusy ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                child: Text(isBusy ? '가입 중...' : '회원가입하고 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupErrorBanner extends StatelessWidget {
  const _SignupErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.32)),
      ),
      child: Text(message),
    );
  }
}

class _SignupTeamPickerSheet extends StatelessWidget {
  const _SignupTeamPickerSheet({
    required this.teams,
    required this.selectedTeamId,
  });

  final List<TeamSummary> teams;
  final String? selectedTeamId;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('응원팀 선택', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '가입 시 이 팀 id가 서버로 함께 전송됩니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
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
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tileColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      onTap: () => Navigator.of(context).pop(team),
                      leading: TeamLogo(
                        initials: team.initials,
                        logoUrl: team.logoUrl,
                        size: 40,
                        foregroundColor: team.color,
                        borderRadius: 999,
                      ),
                      title: Text(team.name),
                      subtitle: Text(
                        '${team.rankLabel}  |  ${team.seasonRecord}',
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.accent,
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupBackdrop extends StatelessWidget {
  const _SignupBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -70,
            top: 60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            right: -110,
            bottom: -10,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentStrong.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
