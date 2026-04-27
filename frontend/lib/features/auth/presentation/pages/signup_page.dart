import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../shared/models/team_summary.dart';
import '../../../favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../bloc/session_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/signup_sections.dart';

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

    return AuthPageScaffold(
      hero: SignupHeroSection(
        onBack: session.showLogin,
        onGuest: session.continueAsGuest,
      ),
      panel: SignupFormPanel(
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
        onShowLogin: session.showLogin,
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
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => SignupTeamPickerSheet(
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
      nickname: _nicknameController.text.trim(),
      email: _emailController.text.trim(),
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
