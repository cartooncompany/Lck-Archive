import 'package:flutter/material.dart';

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
        onBack: session.showLanding,
        onGuest: session.continueAsGuest,
        onSignUp: session.showSignUp,
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
        onShowSignUp: session.showSignUp,
        onGuest: session.continueAsGuest,
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

    if (success || !mounted) {
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
