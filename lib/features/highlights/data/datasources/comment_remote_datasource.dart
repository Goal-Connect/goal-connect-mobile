import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(String highlightId);
  Future<CommentModel> addComment({
    required String highlightId,
    required String userId,
    required String username,
    required String? profileImage,
    required String text,
  });
  Future<void> deleteComment(String commentId);
}

class MockCommentRemoteDataSource implements CommentRemoteDataSource {
  final Map<String, List<CommentModel>> _commentsByHighlight = {};

  final List<Map<String, dynamic>> _baseComments = [
    {
      'userId': 'u1',
      'username': 'AbebeTekeste',
      'profileImage': 'https://ui-avatars.com/api/?name=abebe&background=00D084&color=000&size=150',
      'text': 'Incredible footwork! This kid has a real future 🔥',
      'likes': 47,
      'hoursAgo': 2,
    },
    {
      'userId': 'u2',
      'username': 'ScoutEthiopia_FA',
      'profileImage': 'https://ui-avatars.com/api/?name=scout1&background=00D084&color=000&size=150',
      'text': 'We have been watching you. Expect a call soon! 📞',
      'likes': 120,
      'hoursAgo': 3,
    },
    {
      'userId': 'u3',
      'username': 'AlemayehuG',
      'profileImage': 'https://ui-avatars.com/api/?name=alemayehu&background=00D084&color=000&size=150',
      'text': 'Those cone drills are elite level. Keep grinding brother 💪',
      'likes': 33,
      'hoursAgo': 4,
    },
    {
      'userId': 'u4',
      'username': 'HailuBekele',
      'profileImage': 'https://ui-avatars.com/api/?name=hailu&background=00D084&color=000&size=150',
      'text': 'Best young midfielder I have seen from Ethiopia this year!',
      'likes': 88,
      'hoursAgo': 5,
    },
    {
      'userId': 'u5',
      'username': 'YohannesT',
      'profileImage': 'https://ui-avatars.com/api/?name=yohannes&background=00D084&color=000&size=150',
      'text': 'The way you turn with the ball is like a pro! 🇪🇹⚽',
      'likes': 22,
      'hoursAgo': 6,
    },
    {
      'userId': 'u6',
      'username': 'NairoAcademyCoach',
      'profileImage': 'https://ui-avatars.com/api/?name=nairo&background=00D084&color=000&size=150',
      'text': 'Sent this to our head of recruitment. Amazing talent.',
      'likes': 65,
      'hoursAgo': 8,
    },
    {
      'userId': 'u7',
      'username': 'FikerteM',
      'profileImage': 'https://ui-avatars.com/api/?name=fikerte&background=00D084&color=000&size=150',
      'text': 'Shared this with my whole team. Everyone is impressed! 🙌',
      'likes': 14,
      'hoursAgo': 10,
    },
    {
      'userId': 'u8',
      'username': 'EthioFootballDaily',
      'profileImage': 'https://ui-avatars.com/api/?name=efball&background=00D084&color=000&size=150',
      'text': 'We will feature you in our next weekly recap! Great clip.',
      'likes': 91,
      'hoursAgo': 12,
    },
    {
      'userId': 'u9',
      'username': 'DerbeHaile',
      'profileImage': 'https://ui-avatars.com/api/?name=derbe&background=00D084&color=000&size=150',
      'text': 'Same energy I saw from Zeray Hagos back in the day. Future star!',
      'likes': 55,
      'hoursAgo': 14,
    },
    {
      'userId': 'u10',
      'username': 'AddisBallerFC',
      'profileImage': 'https://ui-avatars.com/api/?name=addis&background=00D084&color=000&size=150',
      'text': 'Dribbling past 3 defenders like that at 16? 😤 Respect',
      'likes': 39,
      'hoursAgo': 16,
    },
    {
      'userId': 'u11',
      'username': 'CAFYouthScout',
      'profileImage': 'https://ui-avatars.com/api/?name=caf&background=00D084&color=000&size=150',
      'text': 'CAF Youth Development has your name on the list. Keep it up ⭐',
      'likes': 143,
      'hoursAgo': 20,
    },
    {
      'userId': 'u12',
      'username': 'SamrawiB',
      'profileImage': 'https://ui-avatars.com/api/?name=samrawi&background=00D084&color=000&size=150',
      'text': 'Your balance and change of direction are unreal. Stay focused 🙏',
      'likes': 27,
      'hoursAgo': 24,
    },
  ];

  List<CommentModel> _buildCommentsForHighlight(String highlightId) {
    final seed = highlightId.hashCode.abs() % _baseComments.length;
    final shuffled = [
      ..._baseComments.sublist(seed),
      ..._baseComments.sublist(0, seed),
    ];
    return shuffled.asMap().entries.map((entry) {
      final i = entry.key;
      final c = entry.value;
      return CommentModel(
        id: 'comment_${highlightId}_$i',
        userId: c['userId'] as String,
        username: c['username'] as String,
        profileImage: c['profileImage'] as String?,
        text: c['text'] as String,
        createdAt: DateTime.now().subtract(Duration(hours: c['hoursAgo'] as int)),
        likes: c['likes'] as int,
      );
    }).toList();
  }

  @override
  Future<List<CommentModel>> getComments(String highlightId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _commentsByHighlight.putIfAbsent(
        highlightId, () => _buildCommentsForHighlight(highlightId));
    return _commentsByHighlight[highlightId]!;
  }

  @override
  Future<CommentModel> addComment({
    required String highlightId,
    required String userId,
    required String username,
    required String? profileImage,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final comment = CommentModel(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      username: username,
      profileImage: profileImage,
      text: text,
      createdAt: DateTime.now(),
      likes: 0,
    );
    _commentsByHighlight.putIfAbsent(
        highlightId, () => _buildCommentsForHighlight(highlightId));
    _commentsByHighlight[highlightId]!.insert(0, comment);
    return comment;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final list in _commentsByHighlight.values) {
      list.removeWhere((c) => c.id == commentId);
    }
  }
}
