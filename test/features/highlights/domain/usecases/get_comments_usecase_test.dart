import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/highlights/domain/entities/comment.dart';
import 'package:goal_connect/features/highlights/domain/repositories/comment_repository.dart';
import 'package:goal_connect/features/highlights/domain/usecases/get_comments_usecase.dart';

class MockCommentRepository extends Mock implements CommentRepository {}

void main() {
  late GetCommentsUsecase usecase;
  late MockCommentRepository mockRepository;

  setUp(() {
    mockRepository = MockCommentRepository();
    usecase = GetCommentsUsecase(mockRepository);
  });

  const tHighlightId = 'highlight1';

  final tComments = [
    Comment(
      id: 'c1',
      userId: 'u1',
      username: 'user1',
      text: 'Great highlight!',
      createdAt: DateTime(2026, 1, 1),
    ),
    Comment(
      id: 'c2',
      userId: 'u2',
      username: 'user2',
      profileImage: 'https://example.com/avatar.jpg',
      text: 'Amazing skills!',
      createdAt: DateTime(2026, 1, 2),
      likes: 5,
    ),
  ];

  test('should return list of comments on success', () async {
    when(() => mockRepository.getComments(any()))
        .thenAnswer((_) async => Right(tComments));

    final result = await usecase(tHighlightId);

    expect(result, Right(tComments));
    verify(() => mockRepository.getComments(tHighlightId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    when(() => mockRepository.getComments(any()))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(tHighlightId);

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
  });

  test('should return empty list when no comments exist', () async {
    when(() => mockRepository.getComments(any()))
        .thenAnswer((_) async => const Right([]));

    final result = await usecase(tHighlightId);

    expect(result, const Right(<Comment>[]));
  });
}
