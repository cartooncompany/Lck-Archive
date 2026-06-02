import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../bloc/session_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/login_sections.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);

    return AuthPageScaffold(
      hero: LoginHeroSection(
        onBack: () {
          session.showLanding();
          context.go(AppRoutePaths.landing);
        },
        onGuest: () {
          session.continueAsGuest();
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
        onGuest: () {
          session.continueAsGuest();
          context.go(AppRoutePaths.home);
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

    final errorMessage = session.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
