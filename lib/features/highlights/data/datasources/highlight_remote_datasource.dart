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

  final List<String> mockVideos = [
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4",
  ];

  MockHighlightRemoteDataSource() {
    final List<String> captions = [
      "Ball control drills in Addis 🇪🇹 #FutureStar",
      "Cone work on a Sunday morning ⚽",
      "Fast feet, faster dreams. #Agility",
      "Scouting day in Ethiopia! 🇪🇹",
      "Dribbling masterclass by our Forward.",
      "Young talent showing off skills 🎯",
      "Warm-up before the big match.",
      "Focus. Determination. Football. #Drills",
      "Elite footwork from the academy ⚽🔥",
      "Keep grinding, the world is watching 🌍",
    ];

    for (int i = 0; i < mockVideos.length; i++) {
      _highlights.add(
        HighlightModel(
          id: i.toString(),
          player: User(
            id: "player${i % 10}",
            email: "player${i % 10}@test.com",
            role: "player",
            username: "EthioStar_${i % 10}",
            profileImage: "https://i.pravatar.cc/150?u=player${i % 10}",
            position: i % 2 == 0 ? "Forward" : "Midfielder",
            age: 15 + (i % 4),
            country: "Ethiopia",
          ),
          videoUrl: mockVideos[i],
          caption: captions[i % captions.length],
          likes: (i * 15) + 10,
          createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
        ),
      );
    }
  }

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

    _highlights.insert(0, highlight);
    return highlight;
  }

  @override
  Future<void> deleteHighlight(String highlightId) async {
    _highlights.removeWhere((h) => h.id == highlightId);
  }

  @override
  Future<List<HighlightModel>> getHighlightsFeed() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _highlights;
  }

  @override
  Future<List<HighlightModel>> getPlayerHighlights(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _highlights.where((h) => h.player.id == playerId).toList();
  }
}
