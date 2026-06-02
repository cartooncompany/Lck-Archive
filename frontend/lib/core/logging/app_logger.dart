import 'dart:convert';

import 'package:flutter/foundation.dart';

final class AppLogger {
  const AppLogger._();

  static const int _maxValueLength = 4000;

  static void debug(String message, {String tag = 'APP', Object? data}) {
    _write('DEBUG', tag, message, data: data);
  }

  static void info(String message, {String tag = 'APP', Object? data}) {
    _write('INFO', tag, message, data: data);
  }

  static void warning(String message, {String tag = 'APP', Object? data}) {
    _write('WARN', tag, message, data: data);
  }

  static void error(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    if (!kDebugMode) {
      return;
    }

    _write('ERROR', tag, message, data: data);
    if (error != null) {
      debugPrint('[LCK][ERROR][$tag] error: $error');
    }
    if (stackTrace != null) {
      debugPrint('[LCK][ERROR][$tag] stack:\n$stackTrace');
    }
  }

  static void _write(String level, String tag, String message, {Object? data}) {
    if (!kDebugMode) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[LCK][$level][$tag][$timestamp] $message');

    if (data != null) {
      debugPrint('[LCK][$level][$tag] data: ${_stringify(data)}');
    }
  }

  static String _stringify(Object value) {
    final text = _tryJsonEncode(value) ?? value.toString();
    if (text.length <= _maxValueLength) {
      return text;
    }

    return '${text.substring(0, _maxValueLength)}... <truncated>';
  }

  static String? _tryJsonEncode(Object value) {
    if (value is! Map && value is! Iterable) {
      return null;
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return null;
    }
  }
}
