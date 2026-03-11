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
    "https://assets.mixkit.co/videos/preview/mixkit-soccer-player-doing-tricks-with-a-ball-437-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-football-player-running-with-the-ball-in-the-grass-501-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-soccer-player-kicking-a-ball-in-slow-motion-438-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-professional-soccer-player-practicing-dribbling-491-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-slow-motion-of-a-soccer-ball-passing-through-a-net-2234-small.mp4",

    "https://samplelib.com/lib/preview/mp4/sample-5s.mp4",
    "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4",
    "https://www.w3schools.com/html/mov_bbb.mp4",
    "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4",
    "https://v.redd.it/0w36msc8p9z61/DASH_240.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-man-doing-agility-drills-on-a-field-23584-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-young-man-doing-running-drills-in-an-open-field-23583-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-athlete-training-on-the-staircase-of-a-stadium-40209-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-man-running-on-a-track-field-40210-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-athlete-preparing-to-run-a-race-40208-small.mp4",

    "https://res.cloudinary.com/demo/video/upload/v1603125211/dance-2.mp4",
    "https://res.cloudinary.com/demo/video/upload/e_trim:0:5/dog.mp4",
    "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHJueW94bm96Y3R6OHR6OHR6OHR6OHR6OHR6OHR6OHR6OHR6OHR6JmVwPXYxX2ludGVybmFsX2dpZl9ieV9pZCZjdD12/3o7TKMGpxx1BQ1U5dm/video.mp4",
    "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHJueW94bm96Y3R6OHR6OHR6OHR6OHR6OHR6OHR6OHR6OHR6OHR6JmVwPXYxX2ludGVybmFsX2dpZl9ieV9pZCZjdD12/l0HlPtbhe3oR29P2w/video.mp4",

    "https://assets.mixkit.co/videos/preview/mixkit-basketball-player-dribbling-the-ball-in-the-court-23592-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-teenage-boy-practicing-basketball-skills-23593-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-man-doing-parkour-jumps-in-the-city-23597-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-martial-arts-expert-training-in-the-park-23596-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-runner-jogging-through-the-forest-trails-23599-small.mp4",

    "https://assets.mixkit.co/videos/preview/mixkit-soccer-player-kicking-the-ball-into-the-goal-40214-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-athlete-performing-a-bicycle-kick-in-the-stadium-40212-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-man-juggling-a-soccer-ball-in-the-middle-of-the-street-4530-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-soccer-ball-in-the-middle-of-a-grass-field-492-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-young-man-training-with-a-soccer-ball-in-the-field-23580-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-fit-man-doing-extreme-training-on-the-beach-23581-small.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-athlete-doing-push-ups-in-the-morning-sun-23600-small.mp4",
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
      "Keep grinding, the world is watching. 🌍",
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
    return _highlights;
  }

  @override
  Future<List<HighlightModel>> getPlayerHighlights(String playerId) async {
    return _highlights.where((h) => h.player.id == playerId).toList();
  }
}
