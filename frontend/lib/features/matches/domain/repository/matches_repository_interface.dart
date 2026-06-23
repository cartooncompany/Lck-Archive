import '../../../../shared/models/lck_match_detail.dart';
import '../../../../shared/models/lck_scheduled_match.dart';

abstract class IMatchesRepository {
  Future<List<LckScheduledMatch>> getScheduledMatches({
    required DateTime from,
    DateTime? to,
  });
  Future<List<LckMatchDetail>> getRecentResults({int limit = 5});
  Future<void> requestLckSync();
  Future<LckMatchDetail> getMatchDetail(String id);
  Future<String> requestMatchAiSummary(String id);
  Future<Map<String, dynamic>> requestMatchAiPrediction(String id);
}
