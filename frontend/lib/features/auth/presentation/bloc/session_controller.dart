import 'package:flutter/widgets.dart';

import 'package:frontend/core/error/app_failure.dart';
import 'package:frontend/features/auth/data/models/auth_session.dart';
import 'package:frontend/features/auth/domain/repository/auth_repository_interface.dart';

enum SessionStage { loading, landing, login, signUp, authenticated }

class SessionController extends ChangeNotifier {
  SessionController({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  SessionStage _stage = SessionStage.loading;
  AuthSession? _session;
  bool _isBusy = false;
  String? _errorMessage;

  SessionStage get stage => _stage;
  AuthSession? get session => _session;
  bool get isBusy => _isBusy;
  bool get isSignedIn => _session != null;
  bool get isAuthenticated => _stage == SessionStage.authenticated;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _session?.user.email;
  String? get userNickname => _session?.user.nickname;

  Future<void> initialize() async {
    _stage = SessionStage.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authRepository.restoreSession();
      _stage = _session != null
          ? SessionStage.authenticated
          : SessionStage.landing;
    } catch (error) {
      _session = null;
      _stage = SessionStage.landing;
      _errorMessage = _messageFromError(error);
    }

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void showLanding() {
    _clearError();
    _setStage(SessionStage.landing);
  }

  void showLogin() {
    _clearError();
    _setStage(SessionStage.login);
  }

  void showSignUp() {
    _clearError();
    _setStage(SessionStage.signUp);
  }

  Future<bool> signIn({required String email, required String password}) {
    return _runAuthTask(() async {
      final session = await _authRepository.login(
        email: email,
        password: password,
      );
      _session = session;
      _stage = SessionStage.authenticated;
    });
  }

  Future<bool> signUp({
    required String nickname,
    required String email,
    required String password,
    required String favoriteTeamId,
  }) {
    return _runAuthTask(() async {
      final session = await _authRepository.signUp(
        nickname: nickname,
        email: email,
        password: password,
        favoriteTeamId: favoriteTeamId,
      );
      _session = session;
      _stage = SessionStage.authenticated;
    });
  }

  Future<void> refreshProfile() async {
    if (_session == null) {
      return;
    }

    try {
      final user = await _authRepository.getMyProfile();
      _session = _session!.copyWith(user: user);
      _clearError();
      notifyListeners();
    } catch (error) {
      _errorMessage = _messageFromError(error);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _setBusy(true);
    try {
      await _authRepository.signOut();
      _session = null;
      _errorMessage = null;
      _stage = SessionStage.landing;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    _setBusy(true);
    _clearError();
    try {
      await _authRepository.deleteAccount();
      _session = null;
      _stage = SessionStage.landing;
      return true;
    } catch (error) {
      if (error is AppFailure && error.isUnauthorized) {
        _session = null;
        _stage = SessionStage.landing;
      }
      _errorMessage = _messageFromError(error);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> _runAuthTask(Future<void> Function() action) async {
    _setBusy(true);
    _clearError();
    try {
      await action();
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFromError(error);
      notifyListeners();
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _messageFromError(Object error) {
    if (error is AppFailure && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return '인증을 처리하는 과정에서 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setBusy(bool value) {
    if (_isBusy == value) {
      return;
    }
    _isBusy = value;
    notifyListeners();
  }

  void _setStage(SessionStage nextStage) {
    if (_stage == nextStage) {
      notifyListeners();
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

  static SessionController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;
  }
}
