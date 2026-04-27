import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/core/utils/mock_lck_data.dart';
import 'package:frontend/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repository/auth_repository.dart';
import 'package:frontend/features/auth/presentation/bloc/session_controller.dart';
import 'package:frontend/features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import 'package:frontend/features/my_page/presentation/pages/my_page_page.dart';

void main() {
  testWidgets('renders without overflow on a desktop-sized screen', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1440, 900));

    final favoriteTeamController = FavoriteTeamController(
      initialTeam: MockLckData.defaultFavoriteTeam,
    );
    final authRepository = AuthRepository(
      remoteDataSource: AuthRemoteDataSource(_NoopApiClient()),
      localStorage: _MemoryLocalStorage(),
    );
    final sessionController = SessionController(authRepository: authRepository)
      ..continueAsGuest();

    addTearDown(favoriteTeamController.dispose);
    addTearDown(sessionController.dispose);

    await tester.pumpWidget(
      FavoriteTeamScope(
        controller: favoriteTeamController,
        child: SessionScope(
          controller: sessionController,
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const Scaffold(body: MyPagePage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('마이페이지'), findsOneWidget);
    expect(find.text('로그인 / 회원가입으로 전환'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _NoopApiClient implements ApiClient {
  @override
  Future<void> deleteVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    required T Function(dynamic data) decoder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> postVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    throw UnimplementedError();
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
