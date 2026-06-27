import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/features/auth/presentation/bloc/session_controller.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_shell.dart';
import 'package:frontend/features/auth/presentation/widgets/landing_sections.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);

    return AuthPageScaffold(
      heroFlex: 12,
      panelFlex: 10,
      hero: LandingHeroSection(
        onStart: () {
          session.showLogin();
          context.go(AppRoutePaths.login);
        },
        onSignUp: () {
          session.showSignUp();
          context.go(AppRoutePaths.signup);
        },
      ),
      panel: const LandingDashboardPreviewSection(),
    );
  }
}
