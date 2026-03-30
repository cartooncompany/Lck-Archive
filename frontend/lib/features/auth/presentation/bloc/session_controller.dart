import 'package:flutter/widgets.dart';

enum SessionStage { landing, login, authenticated }

class SessionController extends ChangeNotifier {
  SessionController({SessionStage initialStage = SessionStage.landing})
    : _stage = initialStage;

  SessionStage _stage;
  String? _userEmail;

  SessionStage get stage => _stage;
  String? get userEmail => _userEmail;

  void showLanding() {
    _setStage(SessionStage.landing);
  }

  void showLogin() {
    _setStage(SessionStage.login);
  }

  void signIn({required String email}) {
    _userEmail = email.trim();
    _setStage(SessionStage.authenticated);
  }

  void continueAsGuest() {
    _userEmail = 'guest@lckarchive.app';
    _setStage(SessionStage.authenticated);
  }

  void signOut() {
    _userEmail = null;
    _setStage(SessionStage.landing);
  }

  void _setStage(SessionStage nextStage) {
    if (_stage == nextStage) {
      return;
    }
    _stage = nextStage;
    notifyListeners();
  }
}

class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    required SessionController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope is not available in the tree.');
    return scope!.notifier!;
  }
}
