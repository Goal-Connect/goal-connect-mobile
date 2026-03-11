import 'package:goal_connect/features/auth/domain/entities/user.dart';
import '../models/highlight_model.dart';

abstract class HighlightRemoteDataSource {
  Future<HighlightModel> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  });

  Future<void> deleteHighlight(String highlightId);

  Future<List<HighlightModel>> getHighlightsFeed();

  Future<List<HighlightModel>> getPlayerHighlights(String playerId);
}


class MockHighlightRemoteDataSource implements HighlightRemoteDataSource {

  final List<HighlightModel> _highlights = [];

  @override
  Future<HighlightModel> uploadHighlight({
    required String playerId,
    required String videoPath,
    required String caption,
  }) async {
    final highlight = HighlightModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      player: User(
        id: playerId,
        email: "player@test.com",
        role: "player",
        username: "yafet10",
        profileImage: "https://example.com/profile.jpg",
        position: "Forward",
        age: 19,
        country: "Ethiopia",
      ),
      videoUrl: videoPath,
      caption: caption,
      likes: 0,
      createdAt: DateTime.now(),
    );

    _highlights.add(highlight);

    return highlight;
  }

  @override
  Future<void> deleteHighlight(String highlightId) async {
    _highlights.removeWhere((h) => h.id == highlightId);
  }

  @override
  Future<List<HighlightModel>> getHighlightsFeed() async {
    return _highlights;
  }

  @override
  Future<List<HighlightModel>> getPlayerHighlights(String playerId) async {
    return _highlights.where((h) => h.player.id == playerId).toList();
  }
}
