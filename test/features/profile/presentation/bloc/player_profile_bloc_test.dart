import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/profile/domain/entities/player_profile.dart';
import 'package:goal_connect/features/profile/domain/entities/player_stats.dart';
import 'package:goal_connect/features/profile/domain/usecases/get_player_profile_usecase.dart';
import 'package:goal_connect/features/profile/domain/usecases/toggle_follow_usecase.dart';
import 'package:goal_connect/features/profile/presentation/bloc/player_profile_bloc.dart';
import 'package:goal_connect/features/profile/presentation/bloc/player_profile_event.dart';
import 'package:goal_connect/features/profile/presentation/bloc/player_profile_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPlayerProfileUsecase extends Mock
    implements GetPlayerProfileUsecase {}

class MockToggleFollowUsecase extends Mock implements ToggleFollowUsecase {}

void main() {
  late MockGetPlayerProfileUsecase mockGetProfile;
  late MockToggleFollowUsecase mockToggleFollow;

  setUp(() {
    mockGetProfile = MockGetPlayerProfileUsecase();
    mockToggleFollow = MockToggleFollowUsecase();
  });

  PlayerProfileBloc buildBloc() => PlayerProfileBloc(
        getPlayerProfile: mockGetProfile,
        toggleFollow: mockToggleFollow,
      );

  final tStats = PlayerStats(
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
  );

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
    stats: tStats,
  );

  final tProfileFollowing = PlayerProfile(
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
    followersCount: 201,
    followingCount: 50,
    totalLikes: 500,
    isFollowing: true,
    stats: tStats,
  );

  group('LoadPlayerProfileEvent', () {
    test('emits [Loading, Loaded] on success', () async {
      when(() => mockGetProfile(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => Right(tProfile));

      final bloc = buildBloc();
      final states = <PlayerProfileState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadPlayerProfileEvent('player_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [
        isA<PlayerProfileLoading>(),
        isA<PlayerProfileLoaded>(),
      ]);
      expect((states[1] as PlayerProfileLoaded).profile.id, 'player_1');

      await sub.cancel();
      await bloc.close();
    });

    test('emits [Loading, Error] on failure', () async {
      when(() => mockGetProfile(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <PlayerProfileState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadPlayerProfileEvent('player_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [
        isA<PlayerProfileLoading>(),
        isA<PlayerProfileError>(),
      ]);
      expect(
        (states[1] as PlayerProfileError).message,
        'Failed to load profile',
      );

      await sub.cancel();
      await bloc.close();
    });
  });

  group('ToggleFollowEvent', () {
    test(
        'emits FollowToggling and calls toggleFollow on success',
        () async {
      when(() => mockGetProfile(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => Right(tProfile));
      when(() => mockToggleFollow(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => const Right(true));

      final bloc = buildBloc();
      final states = <PlayerProfileState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadPlayerProfileEvent('player_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      states.clear();

      // Prevent the refresh getPlayerProfile from completing so the
      // unawaited fold callback never calls emit after the handler exits.
      final completer = Completer<Either<Failure, PlayerProfile>>();
      when(() => mockGetProfile(playerId: any(named: 'playerId')))
          .thenAnswer((_) => completer.future);

      bloc.add(const ToggleFollowEvent('player_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.first, isA<FollowToggling>());
      verify(() => mockToggleFollow(playerId: 'player_1')).called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('reverts to previous profile on toggle failure', () async {
      when(() => mockGetProfile(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => Right(tProfile));
      when(() => mockToggleFollow(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <PlayerProfileState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadPlayerProfileEvent('player_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      states.clear();

      bloc.add(const ToggleFollowEvent('player_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [
        isA<FollowToggling>(),
        isA<PlayerProfileLoaded>(),
      ]);
      expect(
        (states[1] as PlayerProfileLoaded).profile.isFollowing,
        false,
      );

      await sub.cancel();
      await bloc.close();
    });

    test('does nothing when state is not PlayerProfileLoaded', () async {
      final bloc = buildBloc();
      final states = <PlayerProfileState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ToggleFollowEvent('player_1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, isEmpty);
      verifyNever(() => mockToggleFollow(playerId: any(named: 'playerId')));

      await sub.cancel();
      await bloc.close();
    });
  });
}
