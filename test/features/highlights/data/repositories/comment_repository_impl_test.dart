import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/data/datasources/auth_user_local_datasource.dart';
import 'package:goal_connect/features/highlights/data/datasources/comment_remote_datasource.dart';
import 'package:goal_connect/features/highlights/data/models/comment_model.dart';
import 'package:goal_connect/features/highlights/data/repositories/comment_repository_impl.dart';

class MockCommentRemoteDataSource extends Mock
    implements CommentRemoteDataSource {}

class MockAuthUserLocalDataSource extends Mock
    implements AuthUserLocalDataSource {}

void main() {
  late CommentRepositoryImpl repository;
  late MockCommentRemoteDataSource mockDataSource;
  late MockAuthUserLocalDataSource mockUserCache;

  setUp(() {
    mockDataSource = MockCommentRemoteDataSource();
    mockUserCache = MockAuthUserLocalDataSource();
    when(() => mockUserCache.readCachedUser()).thenAnswer((_) async => null);
    repository = CommentRepositoryImpl(
      remoteDataSource: mockDataSource,
      userCache: mockUserCache,
    );
  });

  final tCommentModel = CommentModel(
    id: 'c1',
    userId: 'u1',
    username: 'testuser',
    profileImage: 'https://example.com/avatar.jpg',
    text: 'Great highlight!',
    createdAt: DateTime(2026, 1, 1),
    likes: 5,
  );

  final tCommentModels = [tCommentModel];

  group('getComments', () {
    test('should return list of comments when datasource succeeds', () async {
      when(() => mockDataSource.getComments(any(),
          currentUserId: any(named: 'currentUserId')))
          .thenAnswer((_) async => tCommentModels);

      final result = await repository.getComments('highlight1');

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected a Right'),
        (comments) => expect(comments, tCommentModels),
      );
      verify(() => mockDataSource.getComments('highlight1',
          currentUserId: any(named: 'currentUserId'))).called(1);
    });

    test('should return ServerFailure when datasource throws', () async {
      when(() => mockDataSource.getComments(any(),
          currentUserId: any(named: 'currentUserId')))
          .thenThrow(Exception('Server error'));

      final result = await repository.getComments('highlight1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });

    test('should return empty list when no comments exist', () async {
      when(() => mockDataSource.getComments(any(),
          currentUserId: any(named: 'currentUserId')))
          .thenAnswer((_) async => <CommentModel>[]);

      final result = await repository.getComments('highlight1');

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected a Right'),
        (comments) => expect(comments, isEmpty),
      );
    });
  });

  group('addComment', () {
    test('should return created comment on success', () async {
      when(() => mockDataSource.addComment(
            videoId: any(named: 'videoId'),
            text: any(named: 'text'),
            parentCommentId: any(named: 'parentCommentId'),
          )).thenAnswer((_) async => tCommentModel);

      final result = await repository.addComment(
        highlightId: 'h1',
        text: 'Great highlight!',
      );

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected a Right'),
        (comment) => expect(comment, tCommentModel),
      );
    });

    test('should return ServerFailure when adding throws', () async {
      when(() => mockDataSource.addComment(
            videoId: any(named: 'videoId'),
            text: any(named: 'text'),
            parentCommentId: any(named: 'parentCommentId'),
          )).thenThrow(Exception('Add error'));

      final result = await repository.addComment(
        highlightId: 'h1',
        text: 'Test comment',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });
  });

  group('deleteComment', () {
    test('should return Right(void) when deletion succeeds', () async {
      when(() => mockDataSource.deleteComment(
            videoId: any(named: 'videoId'),
            commentId: any(named: 'commentId'),
          )).thenAnswer((_) async {});

      final result = await repository.deleteComment(
        highlightId: 'h1',
        commentId: 'c1',
      );

      expect(result, const Right(null));
      verify(() => mockDataSource.deleteComment(
            videoId: 'h1',
            commentId: 'c1',
          )).called(1);
    });

    test('should return ServerFailure when deletion throws', () async {
      when(() => mockDataSource.deleteComment(
            videoId: any(named: 'videoId'),
            commentId: any(named: 'commentId'),
          )).thenThrow(Exception('Delete error'));

      final result = await repository.deleteComment(
        highlightId: 'h1',
        commentId: 'c1',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });
  });
}
