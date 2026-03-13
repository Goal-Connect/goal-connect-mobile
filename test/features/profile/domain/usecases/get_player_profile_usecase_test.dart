import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/profile/domain/entities/player_profile.dart';
import 'package:goal_connect/features/profile/domain/entities/player_stats.dart';
import 'package:goal_connect/features/profile/domain/repositories/player_profile_repository.dart';
import 'package:goal_connect/features/profile/domain/usecases/get_player_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late GetPlayerProfileUsecase usecase;
  late MockPlayerProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerProfileRepository();
    usecase = GetPlayerProfileUsecase(mockRepository);
  });

  final tProfile = PlayerProfile(
    id: 'player_1',
    username: 'EthioStar',
    email: 'ethiostar@goalconnect.com',
    role: 'player',
    profileImage: 'https://example.com/avatar.png',
    position: 'Forward',
    age: 17,
    country: 'Ethiopia',
    bio: 'Young forward from Addis Ababa',
    highlightsCount: 12,
    followersCount: 200,
    followingCount: 50,
    totalLikes: 500,
    isFollowing: false,
    stats: PlayerStats(
      pace: 80,
      shooting: 75,
      passing: 70,
      dribbling: 85,
      defending: 40,
      physical: 65,
      preferredFoot: 'Right',
      heightCm: 175,
      weightKg: 68,
      currentClub: 'Addis Ababa FC',
      matchesPlayed: 30,
      goals: 15,
      assists: 8,
    ),
  );

  test('should return player profile on success', () async {
    when(() => mockRepository.getPlayerProfile(playerId: any(named: 'playerId')))
        .thenAnswer((_) async => Right(tProfile));

    final result = await usecase(playerId: 'player_1');

    expect(result, Right(tProfile));
    verify(() => mockRepository.getPlayerProfile(playerId: 'player_1'))
        .called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    when(() => mockRepository.getPlayerProfile(playerId: any(named: 'playerId')))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(playerId: 'player_1');

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('should pass the correct playerId to the repository', () async {
    when(() => mockRepository.getPlayerProfile(playerId: any(named: 'playerId')))
        .thenAnswer((_) async => Right(tProfile));

    await usecase(playerId: 'custom_id_42');

    verify(() => mockRepository.getPlayerProfile(playerId: 'custom_id_42'))
        .called(1);
  });
}
