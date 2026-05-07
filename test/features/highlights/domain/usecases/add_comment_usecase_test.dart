import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/highlights/domain/entities/comment.dart';
import 'package:goal_connect/features/highlights/domain/repositories/comment_repository.dart';
import 'package:goal_connect/features/highlights/domain/usecases/add_comment_usecase.dart';

class MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  late AddCommentUsecase usecase;
  late MockCommentRepository mockRepository;

  setUp(() {
    mockRepository = MockCommentRepository();
    usecase = AddCommentUsecase(mockRepository);
  });

  final tComment = Comment(
    id: 'c1',
    userId: 'u1',
    username: 'testuser',
    profileImage: 'https://example.com/avatar.jpg',
    text: 'Nice highlight!',
    createdAt: DateTime(2026, 1, 1),
  );

  test('should return created comment on success', () async {
    when(() => mockRepository.addComment(
          highlightId: any(named: 'highlightId'),
          text: any(named: 'text'),
          parentCommentId: any(named: 'parentCommentId'),
        )).thenAnswer((_) async => Right(tComment));

    final result = await usecase(
      highlightId: 'h1',
      text: 'Nice highlight!',
    );

    expect(result, Right(tComment));
    verify(() => mockRepository.addComment(
          highlightId: 'h1',
          text: 'Nice highlight!',
          parentCommentId: null,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when adding comment fails', () async {
    when(() => mockRepository.addComment(
          highlightId: any(named: 'highlightId'),
          text: any(named: 'text'),
          parentCommentId: any(named: 'parentCommentId'),
        )).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(
      highlightId: 'h1',
      text: 'Test comment',
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
  });

  test('should pass parentCommentId when replying', () async {
    when(() => mockRepository.addComment(
          highlightId: any(named: 'highlightId'),
          text: any(named: 'text'),
          parentCommentId: any(named: 'parentCommentId'),
        )).thenAnswer((_) async => Right(tComment));

    await usecase(
      highlightId: 'h1',
      text: 'A reply',
      parentCommentId: 'parent1',
    );

    verify(() => mockRepository.addComment(
          highlightId: 'h1',
          text: 'A reply',
          parentCommentId: 'parent1',
        )).called(1);
  });
}
