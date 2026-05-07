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

  const tVideoId = 'video123';
  const tCommentId = 'comment123';

  test('should call repository deleteComment and return Right(void) on success',
      () async {
    when(() => mockRepository.deleteComment(
          highlightId: any(named: 'highlightId'),
          commentId: any(named: 'commentId'),
        )).thenAnswer((_) async => const Right(null));

    final result = await usecase(
      highlightId: tVideoId,
      commentId: tCommentId,
    );

    expect(result, const Right(null));
    verify(() => mockRepository.deleteComment(
          highlightId: tVideoId,
          commentId: tCommentId,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when deletion fails', () async {
    when(() => mockRepository.deleteComment(
          highlightId: any(named: 'highlightId'),
          commentId: any(named: 'commentId'),
        )).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(
      highlightId: tVideoId,
      commentId: tCommentId,
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
  });
}
