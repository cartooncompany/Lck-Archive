import 'package:flutter/material.dart';

import '../bloc/session_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/landing_sections.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);

    return AuthPageScaffold(
      heroFlex: 12,
      panelFlex: 10,
      hero: LandingHeroSection(
        onStart: session.showLogin,
        onGuest: session.continueAsGuest,
        onSignUp: session.showSignUp,
      ),
      panel: const LandingDashboardPreviewSection(),
    );
  }
}
