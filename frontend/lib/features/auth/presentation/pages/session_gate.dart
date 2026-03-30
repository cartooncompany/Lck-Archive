import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_shell.dart';
import '../bloc/session_controller.dart';
import 'landing_page.dart';
import 'login_page.dart';

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = SessionScope.of(context).stage;

    return ColoredBox(
      color: Colors.black,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        reverseDuration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(animation);
          final scaleAnimation = Tween<double>(
            begin: 0.985,
            end: 1,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            ),
          );
        },
        child: switch (stage) {
          SessionStage.landing => const LandingPage(
            key: ValueKey(SessionStage.landing),
          ),
          SessionStage.login => const LoginPage(
            key: ValueKey(SessionStage.login),
          ),
          SessionStage.authenticated => const AppShell(
            key: ValueKey(SessionStage.authenticated),
          ),
        },
      ),
    );
  }
}
