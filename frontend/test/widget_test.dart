import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:frontend/app/app.dart';
import 'package:frontend/features/auth/presentation/pages/splash_page.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_shared_widgets.dart';

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
  int get contentLength => 0;

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

  testWidgets('shows auth entry flow on app launch', (
    WidgetTester tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const LckArchiveApp());

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    expect(find.text('LCK 경기 기록을\n빠르게 확인하세요.'), findsOneWidget);
    expect(find.text('기록 탐색하기'), findsOneWidget);
    expect(find.text('회원가입'), findsOneWidget);

    await tester.tap(find.text('로그인'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('로그인'), findsWidgets);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.widgetWithText(AuthPrimaryButton, '로그인'), findsOneWidget);
  });
}
