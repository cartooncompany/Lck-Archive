import 'package:flutter/foundation.dart';

String resolveApiBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:3000/api';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:3000/api';
    case TargetPlatform.iOS:
      return 'http://127.0.0.1:3000/api';
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return 'http://localhost:3000/api';
    case TargetPlatform.fuchsia:
      return 'http://localhost:3000/api';
  }
}
