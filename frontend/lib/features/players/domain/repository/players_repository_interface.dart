import '../../../../shared/models/player_profile.dart';

abstract class IPlayersRepository {
  Future<List<PlayerProfile>> getPlayers({
    String? keyword,
    String? position,
    String? teamId,
    int limit = 100,
  });
  Future<PlayerProfile> getPlayer(String id);
  Future<PlayerProfile?> findPlayerByTag(String tag);
}
