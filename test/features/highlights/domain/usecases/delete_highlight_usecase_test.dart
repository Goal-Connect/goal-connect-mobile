import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/highlights/domain/repositories/highlight_repository.dart';
import 'package:goal_connect/features/highlights/domain/usecases/delete_highlight_usecase.dart';

class MockHighlightRepository extends Mock implements HighlightRepository {}

void main() {
  late DeleteHighlightUsecase usecase;
  late MockHighlightRepository mockRepository;

  setUp(() {
    mockRepository = MockHighlightRepository();
    usecase = DeleteHighlightUsecase(mockRepository);
  });

  const tHighlightId = 'highlight123';

  test('should call repository deleteHighlight and return Right(void) on success', () async {
    when(() => mockRepository.deleteHighlight(highlightId: any(named: 'highlightId')))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(highlightId: tHighlightId);

    expect(result, const Right(null));
    verify(() => mockRepository.deleteHighlight(highlightId: tHighlightId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when deletion fails', () async {
    when(() => mockRepository.deleteHighlight(highlightId: any(named: 'highlightId')))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(highlightId: tHighlightId);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
  });

  test('should pass the correct highlightId to the repository', () async {
    when(() => mockRepository.deleteHighlight(highlightId: any(named: 'highlightId')))
        .thenAnswer((_) async => const Right(null));

    await usecase(highlightId: 'anotherHighlight');

    verify(() => mockRepository.deleteHighlight(highlightId: 'anotherHighlight')).called(1);
  });
}
