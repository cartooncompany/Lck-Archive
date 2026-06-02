import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String resolveApiBaseUrl() {
  // 테스트 환경 등에서 DotEnv가 로드되지 않았을 경우에 대비한 방어 코드
  bool isInitialized = false;
  try {
    isInitialized = dotenv.isInitialized;
  } catch (_) {
    isInitialized = false;
  }

  if (kIsWeb) {
    if (isInitialized) {
      final webUrl = dotenv.env['API_BASE_URL'];
      if (webUrl != null && webUrl.trim().isNotEmpty) {
        return webUrl.trim();
      }
    }
    return 'http://localhost:3000/api';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      if (isInitialized) {
        final androidUrl =
            dotenv.env['API_BASE_URL_ANDROID'] ?? dotenv.env['API_BASE_URL'];
        if (androidUrl != null && androidUrl.trim().isNotEmpty) {
          return androidUrl.trim();
        }
      }
      return 'http://10.0.2.2:3000/api';
    case TargetPlatform.iOS:
      if (isInitialized) {
        final iosUrl =
            dotenv.env['API_BASE_URL_IOS'] ?? dotenv.env['API_BASE_URL'];
        if (iosUrl != null && iosUrl.trim().isNotEmpty) {
          return iosUrl.trim();
        }
      }
      return 'http://127.0.0.1:3000/api';
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      if (isInitialized) {
        final defaultUrl = dotenv.env['API_BASE_URL'];
        if (defaultUrl != null && defaultUrl.trim().isNotEmpty) {
          return defaultUrl.trim();
        }
      }
      return 'http://localhost:3000/api';
  }
}
