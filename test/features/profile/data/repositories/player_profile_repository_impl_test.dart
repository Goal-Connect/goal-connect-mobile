import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/profile/data/datasources/player_profile_remote_datasource.dart';
import 'package:goal_connect/features/profile/data/models/player_profile_model.dart';
import 'package:goal_connect/features/profile/data/models/player_stats_model.dart';
import 'package:goal_connect/features/profile/data/repositories/player_profile_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockPlayerProfileRemoteDataSource extends Mock
    implements PlayerProfileRemoteDataSource {}

void main() {
  late PlayerProfileRepositoryImpl repository;
  late MockPlayerProfileRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPlayerProfileRemoteDataSource();
    repository =
        PlayerProfileRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final tProfileModel = PlayerProfileModel(
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
    stats: PlayerStatsModel(
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

  group('getPlayerProfile', () {
    test('should return Right with profile when datasource succeeds',
        () async {
      when(() => mockDataSource.getPlayerProfile(any()))
          .thenAnswer((_) async => tProfileModel);

      final result =
          await repository.getPlayerProfile(playerId: 'player_1');

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected Right'),
        (profile) {
          expect(profile.id, 'player_1');
          expect(profile.username, 'EthioStar');
          expect(profile.isPlayer, true);
        },
      );
      verify(() => mockDataSource.getPlayerProfile('player_1')).called(1);
    });

    test('should return Left(ServerFailure) when datasource throws',
        () async {
      when(() => mockDataSource.getPlayerProfile(any()))
          .thenThrow(Exception('Player not found'));

      final result =
          await repository.getPlayerProfile(playerId: 'invalid_id');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('toggleFollow', () {
    test('should return Right(true) when datasource returns true', () async {
      when(() => mockDataSource.toggleFollow(any()))
          .thenAnswer((_) async => true);

      final result = await repository.toggleFollow(playerId: 'player_1');

      expect(result, const Right(true));
      verify(() => mockDataSource.toggleFollow('player_1')).called(1);
    });

    test('should return Right(false) when datasource returns false',
        () async {
      when(() => mockDataSource.toggleFollow(any()))
          .thenAnswer((_) async => false);

      final result = await repository.toggleFollow(playerId: 'player_1');

      expect(result, const Right(false));
    });

    test('should return Left(ServerFailure) when datasource throws',
        () async {
      when(() => mockDataSource.toggleFollow(any()))
          .thenThrow(Exception('Network error'));

      final result = await repository.toggleFollow(playerId: 'player_1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
