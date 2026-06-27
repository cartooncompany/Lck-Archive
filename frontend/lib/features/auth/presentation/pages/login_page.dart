import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/features/auth/presentation/bloc/session_controller.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_shell.dart';
import 'package:frontend/features/auth/presentation/widgets/login_sections.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({this.fromSettings = false, super.key});

  final bool fromSettings;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearErrorOnChange);
    _passwordController.addListener(_clearErrorOnChange);
  }

  void _clearErrorOnChange() {
    final session = SessionScope.maybeOf(context);
    if (session?.errorMessage != null) {
      session!.clearError();
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearErrorOnChange);
    _passwordController.removeListener(_clearErrorOnChange);
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);

    return AuthPageScaffold(
      hero: LoginHeroSection(
        showBackButton: !widget.fromSettings,
        onBack: () {
          session.showLanding();
          context.go(AppRoutePaths.home);
        },
        onSignUp: () {
          session.showSignUp();
          context.go(AppRoutePaths.signup);
        },
      ),
      panel: LoginFormPanel(
        formKey: _formKey,
        emailController: _emailController,
        passwordController: _passwordController,
        passwordFocusNode: _passwordFocusNode,
        obscurePassword: _obscurePassword,
        isBusy: session.isBusy,
        errorMessage: session.errorMessage,
        onTogglePassword: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        onSubmit: _submit,
        onShowSignUp: () {
          session.showSignUp();
          context.go(AppRoutePaths.signup);
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final session = SessionScope.of(context);
    final success = await session.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(AppRoutePaths.home);
      return;
    }


  }
}
