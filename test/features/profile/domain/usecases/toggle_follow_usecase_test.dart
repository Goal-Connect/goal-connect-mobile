import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/profile/domain/repositories/player_profile_repository.dart';
import 'package:goal_connect/features/profile/domain/usecases/toggle_follow_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late ToggleFollowUsecase usecase;
  late MockPlayerProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerProfileRepository();
    usecase = ToggleFollowUsecase(mockRepository);
  });

  test('should return true (now following) on successful toggle', () async {
    when(() => mockRepository.toggleFollow(playerId: any(named: 'playerId')))
        .thenAnswer((_) async => const Right(true));

    final result = await usecase(playerId: 'player_1');

    expect(result, const Right(true));
    verify(() => mockRepository.toggleFollow(playerId: 'player_1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return false (unfollowed) on successful toggle', () async {
    when(() => mockRepository.toggleFollow(playerId: any(named: 'playerId')))
        .thenAnswer((_) async => const Right(false));

    final result = await usecase(playerId: 'player_1');

    expect(result, const Right(false));
    verify(() => mockRepository.toggleFollow(playerId: 'player_1')).called(1);
  });

  test('should return ServerFailure when toggle fails', () async {
    when(() => mockRepository.toggleFollow(playerId: any(named: 'playerId')))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(playerId: 'player_1');

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
