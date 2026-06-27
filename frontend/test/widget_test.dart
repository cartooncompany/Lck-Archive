import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:frontend/app/app.dart';
import 'package:frontend/features/auth/presentation/pages/splash_page.dart';
import 'package:frontend/shared/widgets/app_shell.dart';
import 'package:frontend/shared/widgets/app_bottom_nav_bar.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    if (name.contains('Url') || name.contains('open')) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    if (name.contains('headers')) {
      return _MockHttpHeaders();
    }
    if (name.contains('close')) {
      return Future.value(_MockHttpClientResponse());
    }
    if (name.contains('method')) {
      return 'GET';
    }
    if (name.contains('persistentConnection') ||
        name.contains('followRedirects') ||
        name.contains('bufferOutput')) {
      return false;
    }
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void forEach(void Function(String name, List<String> values) f) {
    f('content-type', const ['application/json; charset=utf-8']);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    if (name.contains('forEach')) {
      final f =
          invocation.positionalArguments.first
              as void Function(String name, List<String> values);
      f('content-type', const ['application/json; charset=utf-8']);
      return null;
    }
    if (invocation.memberName == #[] || name.contains('[]')) {
      final String headerName = invocation.positionalArguments.first as String;
      if (headerName.toLowerCase() == 'content-type') {
        return const ['application/json; charset=utf-8'];
      }
    }
    if (name.contains('value')) {
      final String headerName = invocation.positionalArguments.first as String;
      if (headerName.toLowerCase() == 'content-type') {
        return 'application/json; charset=utf-8';
      }
    }
    if (name.contains('contentType')) {
      return ContentType.json;
    }
    return null;
  }
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  int get contentLength => -1;

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    if (name.contains('statusCode')) {
      return 200;
    }
    if (name.contains('reasonPhrase')) {
      return 'OK';
    }
    if (name.contains('headers')) {
      return _MockHttpHeaders();
    }
    if (name.contains('isRedirect') || name.contains('persistentConnection')) {
      return false;
    }
    if (name.contains('redirects')) {
      return const <RedirectInfo>[];
    }
    if (name.contains('cookies')) {
      return const <Cookie>[];
    }
    return null;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final stream = Stream<List<int>>.fromIterable([
      utf8.encode(
        jsonEncode(<String, dynamic>{
          'items': <dynamic>[],
          'meta': <String, dynamic>{
            'totalItems': 0,
            'itemCount': 0,
            'itemsPerPage': 10,
            'totalPages': 1,
            'currentPage': 1,
          },
        }),
      ),
    ]);
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('launches into the home shell without requiring login', (
    WidgetTester tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const LckArchiveApp());

    // 부트스트랩이 완료되기 전에는 스플래시가 먼저 표시된다.
    expect(find.byType(SplashPage), findsOneWidget);

    // 부트스트랩 완료 후, 게스트 모드 없이 곧바로 홈 셸로 진입한다.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);

    // 하단 네비게이션의 주요 탭이 노출된다.
    expect(find.text('홈'), findsWidgets);
    expect(find.text('팀'), findsWidgets);
    expect(find.text('마이페이지'), findsWidgets);

    // 반복 애니메이션/백그라운드 로딩 타이머를 정리하기 위해 트리를 비운다.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
