import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/core/error/app_failure.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/core/utils/mock_lck_data.dart';
import 'package:frontend/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repository/auth_repository.dart';
import 'package:frontend/features/auth/presentation/bloc/session_controller.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/features/settings/presentation/pages/settings_page.dart';

void main() {
  testWidgets('shows delete account action for signed-in users', (
    tester,
  ) async {
    final apiClient = _FakeApiClient();
    final harness = await _pumpSettingsPage(
      tester,
      signedIn: true,
      apiClient: apiClient,
    );

    expect(find.text('회원탈퇴'), findsOneWidget);
    expect(find.text('계정과 저장된 인증 정보를 삭제합니다.'), findsOneWidget);

    await tester.tap(find.text('회원탈퇴'));
    await tester.pumpAndSettle();

    expect(apiClient.deleteAccountCallCount, 1);
    expect(harness.sessionController.isSignedIn, isFalse);
    expect(harness.sessionController.stage, SessionStage.landing);
    expect(find.text('회원탈퇴가 완료되었습니다.'), findsOneWidget);
  });

  testWidgets('hides delete account action for guests', (tester) async {
    await _pumpSettingsPage(tester, signedIn: false);

    expect(find.text('회원탈퇴'), findsNothing);
  });

  testWidgets('keeps session when delete account request fails', (
    tester,
  ) async {
    final apiClient = _FakeApiClient(
      deleteAccountFailure: const AppFailure(
        'Database connection failed',
        statusCode: 503,
      ),
    );
    final harness = await _pumpSettingsPage(
      tester,
      signedIn: true,
      apiClient: apiClient,
    );

    await tester.tap(find.text('회원탈퇴'));
    await tester.pumpAndSettle();

    expect(apiClient.deleteAccountCallCount, 1);
    expect(harness.sessionController.isSignedIn, isTrue);
    expect(find.text('Database connection failed'), findsOneWidget);
  });
}

Future<_SettingsPageHarness> _pumpSettingsPage(
  WidgetTester tester, {
  required bool signedIn,
  _FakeApiClient? apiClient,
}) async {
  final favoriteTeamController = FavoriteTeamController(
    initialTeam: MockLckData.defaultFavoriteTeam,
  );
  final resolvedApiClient = apiClient ?? _FakeApiClient();
  final authRepository = AuthRepository(
    remoteDataSource: AuthRemoteDataSource(resolvedApiClient),
    localStorage: _MemoryLocalStorage(),
  );
  final sessionController = SessionController(authRepository: authRepository);

  addTearDown(favoriteTeamController.dispose);
  addTearDown(sessionController.dispose);

  if (signedIn) {
    final didSignIn = await sessionController.signIn(
      email: 'tester@lckarchive.app',
      password: 'password123',
    );
    expect(didSignIn, isTrue);
  } else {
    sessionController.continueAsGuest();
  }

  await tester.pumpWidget(
    FavoriteTeamScope(
      controller: favoriteTeamController,
      child: SessionScope(
        controller: sessionController,
        child: MaterialApp(theme: AppTheme.dark(), home: const SettingsPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _SettingsPageHarness(sessionController: sessionController);
}

class _FakeApiClient implements ApiClient {
  _FakeApiClient({this.deleteAccountFailure});

  final AppFailure? deleteAccountFailure;
  int deleteAccountCallCount = 0;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) async {
    switch (path) {
      case '/users/me':
        return decoder(<String, dynamic>{
          'nickname': '테스터',
          'email': 'tester@lckarchive.app',
        });
    }

    throw UnimplementedError('Unhandled GET path: $path');
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) async {
    switch (path) {
      case '/auth/login':
        return decoder(<String, dynamic>{
          'user': <String, dynamic>{
            'nickname': '테스터',
            'email': 'tester@lckarchive.app',
          },
          'accessToken': 'access-token',
          'accessTokenExpiresAt': DateTime.utc(2099).toIso8601String(),
          'refreshToken': 'refresh-token',
          'refreshTokenExpiresAt': DateTime.utc(2099, 1, 2).toIso8601String(),
        });
    }

    throw UnimplementedError('Unhandled POST path: $path');
  }

  @override
  Future<void> postVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    throw UnimplementedError('Unhandled POST VOID path: $path');
  }

  @override
  Future<void> deleteVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    switch (path) {
      case '/users/me':
        deleteAccountCallCount += 1;
        final failure = deleteAccountFailure;
        if (failure != null) {
          throw failure;
        }
        return;
    }

    throw UnimplementedError('Unhandled DELETE path: $path');
  }
}

class _MemoryLocalStorage implements LocalStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> readString(String key) async {
    return _values[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }
}

class _SettingsPageHarness {
  const _SettingsPageHarness({required this.sessionController});

  final SessionController sessionController;
}
