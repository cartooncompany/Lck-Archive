import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppLogger.error(
          'Flutter framework error.',
          tag: 'FLUTTER',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppLogger.error(
          'Uncaught platform error.',
          tag: 'FLUTTER',
          error: error,
          stackTrace: stackTrace,
        );
        return false;
      };

      AppLogger.info('Application bootstrap started.', tag: 'BOOT');
      await dotenv.load(fileName: '.env', isOptional: true);
      AppLogger.info(
        '.env loaded.',
        tag: 'BOOT',
        data: {'keys': dotenv.env.keys.toList()},
      );

      runApp(const LckArchiveApp());
    },
    (error, stackTrace) {
      AppLogger.error(
        'Uncaught zone error.',
        tag: 'FLUTTER',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
