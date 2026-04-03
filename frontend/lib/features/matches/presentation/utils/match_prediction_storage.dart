import 'dart:convert';

import '../../../../core/storage/local_storage.dart';

const String matchPredictionStorageKey = 'home_page.match_predictions.v1';

Future<Map<String, String>> loadMatchPredictions(LocalStorage storage) async {
  try {
    final rawValue = await storage.readString(matchPredictionStorageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return <String, String>{};
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! Map<String, dynamic>) {
      return <String, String>{};
    }

    return decoded.map((key, value) => MapEntry(key, value.toString()));
  } catch (_) {
    return <String, String>{};
  }
}

Future<void> saveMatchPredictions(
  LocalStorage storage,
  Map<String, String> predictions,
) async {
  await storage.writeString(matchPredictionStorageKey, jsonEncode(predictions));
}
