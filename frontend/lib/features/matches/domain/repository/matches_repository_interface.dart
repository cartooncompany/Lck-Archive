import '../../../../shared/models/lck_match_detail.dart';
import '../../../../shared/models/lck_scheduled_match.dart';

abstract class IMatchesRepository {
  Future<List<LckScheduledMatch>> getScheduledMatches({
    required DateTime from,
    DateTime? to,
  });
  Future<void> requestLckSync();
  Future<LckMatchDetail> getMatchDetail(String id);
}
