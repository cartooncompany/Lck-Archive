import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_shell.dart';
import '../bloc/session_controller.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'splash_page.dart';
import 'signup_page.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _requestedInitialization = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionController = SessionScope.of(context);
    if (_requestedInitialization ||
        sessionController.stage != SessionStage.loading) {
      return;
    }

    _requestedInitialization = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      sessionController.initialize();
    });
  }

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
          SessionStage.loading => const SplashPage(
            key: ValueKey(SessionStage.loading),
          ),
          SessionStage.landing => const LandingPage(
            key: ValueKey(SessionStage.landing),
          ),
          SessionStage.login => const LoginPage(
            key: ValueKey(SessionStage.login),
          ),
          SessionStage.signUp => const SignupPage(
            key: ValueKey(SessionStage.signUp),
          ),
          SessionStage.authenticated => const AppShell(
            key: ValueKey(SessionStage.authenticated),
          ),
        },
      ),
    );
  }
}
