import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/highlights/domain/repositories/highlight_repository.dart';
import 'package:goal_connect/features/highlights/domain/entities/toggle_like_result.dart';
import 'package:goal_connect/features/highlights/domain/usecases/toggle_like_highlight_usecase.dart';

class MockHighlightRepository extends Mock implements HighlightRepository {}

void main() {
  late ToggleLikeHighlightUsecase usecase;
  late MockHighlightRepository mockRepository;

  setUp(() {
    mockRepository = MockHighlightRepository();
    usecase = ToggleLikeHighlightUsecase(mockRepository);
  });

  const tHighlightId = 'highlight123';

  final tResult = const ToggleLikeResult(
    likesCount: 5,
    likedUserIds: ['user1'],
  );

  test('should return ToggleLikeResult when toggle succeeds', () async {
    when(() => mockRepository.toggleLike(highlightId: any(named: 'highlightId')))
        .thenAnswer((_) async => Right(tResult));

    final result = await usecase(highlightId: tHighlightId);

    expect(result, Right(tResult));
    verify(() => mockRepository.toggleLike(highlightId: tHighlightId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when toggle fails', () async {
    when(() => mockRepository.toggleLike(highlightId: any(named: 'highlightId')))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(highlightId: tHighlightId);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
  });
}
