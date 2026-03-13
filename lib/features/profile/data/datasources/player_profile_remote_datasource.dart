import '../models/player_profile_model.dart';
import '../models/player_stats_model.dart';

abstract class PlayerProfileRemoteDataSource {
  Future<PlayerProfileModel> getPlayerProfile(String playerId);
  Future<bool> toggleFollow(String playerId);
}

class MockPlayerProfileRemoteDataSource implements PlayerProfileRemoteDataSource {
  final Map<String, bool> _followState = {};

  final _mockProfiles = <String, PlayerProfileModel>{};

  MockPlayerProfileRemoteDataSource() {
    final names = [
      'EthioStar_0', 'EthioStar_1', 'EthioStar_2', 'EthioStar_3',
      'EthioStar_4', 'EthioStar_5', 'EthioStar_6', 'EthioStar_7',
      'EthioStar_8', 'EthioStar_9',
    ];

    final bios = [
      'Young forward from Addis Ababa. Dream: top European leagues.',
      'Creative midfielder with elite vision and passing range.',
      'Explosive winger who loves to take on defenders 1v1.',
      'Box-to-box midfielder with incredible stamina.',
      'Clinical striker. Goals are my language.',
      'Defensive rock from the Ethiopian youth academy.',
      'Playmaker with silky dribbling skills.',
      'Versatile attacker comfortable across the front line.',
      'Speed demon on the wing. Nobody catches me.',
      'Captain material. Leader on and off the pitch.',
    ];

    final clubs = [
      'Addis Ababa FC', 'Ethiopian Coffee SC', 'St. George SA',
      'Hawassa Kenema', 'Fasil Kenema', 'Mekelle Kenema',
      'Jimma Aba Jifar', 'Wolaita Dicha', 'Sidama Bunna', 'Dire Dawa FC',
    ];

    for (int i = 0; i < 10; i++) {
      final id = 'player$i';
      final isForward = i % 2 == 0;

      _mockProfiles[id] = PlayerProfileModel(
        id: id,
        username: names[i],
        email: '${names[i].toLowerCase()}@goalconnect.com',
        role: 'player',
        profileImage:
            'https://ui-avatars.com/api/?name=${names[i]}&background=00D084&color=000&size=150',
        position: isForward ? 'Forward' : 'Midfielder',
        age: 15 + (i % 4),
        country: 'Ethiopia',
        bio: bios[i],
        highlightsCount: 8 + (i * 3),
        followersCount: 120 + (i * 47),
        followingCount: 30 + (i * 8),
        totalLikes: 348 + (i * 123),
        isFollowing: false,
        stats: PlayerStatsModel(
          pace: 65 + (i * 3) % 30,
          shooting: 60 + (i * 5) % 30,
          passing: 55 + (i * 4) % 35,
          dribbling: 70 + (i * 2) % 25,
          defending: isForward ? 30 + (i * 3) % 20 : 60 + (i * 3) % 25,
          physical: 55 + (i * 3) % 30,
          preferredFoot: i % 3 == 0 ? 'Left' : 'Right',
          heightCm: 165 + (i * 3) % 20,
          weightKg: 60 + (i * 2) % 15,
          currentClub: clubs[i],
          matchesPlayed: 20 + (i * 7),
          goals: isForward ? 8 + (i * 3) : 2 + i,
          assists: isForward ? 3 + i : 5 + (i * 2),
        ),
      );
    }
  }

  @override
  Future<PlayerProfileModel> getPlayerProfile(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final profile = _mockProfiles[playerId];
    if (profile == null) throw Exception('Player not found');

    final isFollowing = _followState[playerId] ?? false;

    return PlayerProfileModel(
      id: profile.id,
      username: profile.username,
      email: profile.email,
      role: profile.role,
      profileImage: profile.profileImage,
      position: profile.position,
      age: profile.age,
      country: profile.country,
      bio: profile.bio,
      highlightsCount: profile.highlightsCount,
      followersCount: profile.followersCount + (isFollowing ? 1 : 0),
      followingCount: profile.followingCount,
      totalLikes: profile.totalLikes,
      isFollowing: isFollowing,
      stats: profile.stats,
    );
  }

  @override
  Future<bool> toggleFollow(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final current = _followState[playerId] ?? false;
    _followState[playerId] = !current;
    return !current;
  }
}
