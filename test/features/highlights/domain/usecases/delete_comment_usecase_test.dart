import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/highlights/domain/repositories/comment_repository.dart';
import 'package:goal_connect/features/highlights/domain/usecases/delete_comment_usecase.dart';

class MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  late DeleteCommentUsecase usecase;
  late MockCommentRepository mockRepository;

  setUp(() {
    mockRepository = MockCommentRepository();
    usecase = DeleteCommentUsecase(mockRepository);
  });

  const tCommentId = 'comment123';

  test('should call repository deleteComment and return Right(void) on success', () async {
    when(() => mockRepository.deleteComment(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(tCommentId);

    expect(result, const Right(null));
    verify(() => mockRepository.deleteComment(tCommentId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when deletion fails', () async {
    when(() => mockRepository.deleteComment(any()))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(tCommentId);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
  });

  test('should pass the exact commentId to the repository', () async {
    when(() => mockRepository.deleteComment(any()))
        .thenAnswer((_) async => const Right(null));

    await usecase('specificComment456');

    verify(() => mockRepository.deleteComment('specificComment456')).called(1);
  });
}
