import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/highlights/domain/entities/comment.dart';
import 'package:goal_connect/features/highlights/domain/usecases/get_comments_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/add_comment_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/delete_comment_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/comment_bloc.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/comment_event.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/comment_state.dart';

class MockGetCommentsUsecase extends Mock implements GetCommentsUsecase {}

class MockAddCommentUsecase extends Mock implements AddCommentUsecase {}

class MockDeleteCommentUsecase extends Mock implements DeleteCommentUsecase {}

class MockToggleCommentLikeUsecase extends Mock
    implements ToggleCommentLikeUsecase {}

void main() {
  late MockGetCommentsUsecase mockGetComments;
  late MockAddCommentUsecase mockAddComment;
  late MockDeleteCommentUsecase mockDeleteComment;
  late MockToggleCommentLikeUsecase mockToggleCommentLike;

  setUp(() {
    mockGetComments = MockGetCommentsUsecase();
    mockAddComment = MockAddCommentUsecase();
    mockDeleteComment = MockDeleteCommentUsecase();
    mockToggleCommentLike = MockToggleCommentLikeUsecase();
  });

  CommentBloc buildBloc() => CommentBloc(
        getComments: mockGetComments,
        addComment: mockAddComment,
        deleteComment: mockDeleteComment,
        toggleCommentLike: mockToggleCommentLike,
      );

  final tComments = [
    Comment(
      id: 'c1',
      userId: 'u1',
      username: 'user1',
      text: 'Nice!',
      createdAt: DateTime(2026, 1, 1),
    ),
    Comment(
      id: 'c2',
      userId: 'u2',
      username: 'user2',
      text: 'Amazing!',
      createdAt: DateTime(2026, 1, 2),
    ),
  ];

  final tNewComment = Comment(
    id: 'c3',
    userId: 'u1',
    username: 'user1',
    text: 'New comment',
    createdAt: DateTime(2026, 1, 3),
  );

  const tHighlightId = 'highlight1';

  group('GetCommentsEvent', () {
    test('emits [CommentLoading, CommentsLoaded] on success', () async {
      when(() => mockGetComments(any()))
          .thenAnswer((_) async => Right(tComments));

      final bloc = buildBloc();
      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetCommentsEvent(tHighlightId));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<CommentLoading>(), isA<CommentsLoaded>()]);
      final loaded = states[1] as CommentsLoaded;
      expect(loaded.comments, tComments);
      expect(loaded.highlightId, tHighlightId);
      await sub.cancel();
      await bloc.close();
    });

    test('emits [CommentLoading, CommentError] on failure', () async {
      when(() => mockGetComments(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetCommentsEvent(tHighlightId));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<CommentLoading>(), isA<CommentError>()]);
      expect((states[1] as CommentError).message, 'Failed to load comments');
      await sub.cancel();
      await bloc.close();
    });
  });

  group('AddCommentEvent', () {
    test('reloads comments after successful post', () async {
      when(() => mockAddComment(
            highlightId: any(named: 'highlightId'),
            text: any(named: 'text'),
            parentCommentId: any(named: 'parentCommentId'),
          )).thenAnswer((_) async => Right(tNewComment));

      final updated = [tNewComment, ...tComments];
      var call = 0;
      when(() => mockGetComments(any())).thenAnswer((_) async {
        call++;
        if (call >= 2) {
          return Right(updated);
        }
        return Right(tComments);
      });

      final bloc = buildBloc();
      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetCommentsEvent(tHighlightId));
      await Future.delayed(const Duration(milliseconds: 100));
      states.clear();

      bloc.add(const AddCommentEvent(
        highlightId: tHighlightId,
        text: 'New comment',
      ));
      await Future.delayed(const Duration(milliseconds: 150));

      expect(states.first, isA<CommentPosting>());
      expect(states.last, isA<CommentsLoaded>());
      final loaded = states.last as CommentsLoaded;
      expect(loaded.comments.length, 3);
      await sub.cancel();
      await bloc.close();
    });

    test('emits [CommentPosting, CommentError] on failure', () async {
      when(() => mockGetComments(any()))
          .thenAnswer((_) async => Right(tComments));
      when(() => mockAddComment(
            highlightId: any(named: 'highlightId'),
            text: any(named: 'text'),
            parentCommentId: any(named: 'parentCommentId'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetCommentsEvent(tHighlightId));
      await Future.delayed(const Duration(milliseconds: 100));
      states.clear();

      bloc.add(const AddCommentEvent(
        highlightId: tHighlightId,
        text: 'Failing comment',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<CommentPosting>(), isA<CommentError>()]);
      expect((states[1] as CommentError).message, 'Failed to post comment');
      await sub.cancel();
      await bloc.close();
    });
  });

  group('DeleteCommentEvent', () {
    test('reloads comments after successful delete', () async {
      var call = 0;
      when(() => mockGetComments(any())).thenAnswer((_) async {
        call++;
        if (call >= 2) {
          return Right([tComments[1]]);
        }
        return Right(tComments);
      });
      when(() => mockDeleteComment(
            highlightId: any(named: 'highlightId'),
            commentId: any(named: 'commentId'),
          )).thenAnswer((_) async => const Right(null));

      final bloc = buildBloc();
      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetCommentsEvent(tHighlightId));
      await Future.delayed(const Duration(milliseconds: 100));
      states.clear();

      bloc.add(const DeleteCommentEvent(
        highlightId: tHighlightId,
        commentId: 'c1',
      ));
      await Future.delayed(const Duration(milliseconds: 150));

      expect(states, [isA<CommentLoading>(), isA<CommentsLoaded>()]);
      final loaded = states[1] as CommentsLoaded;
      expect(loaded.comments.length, 1);
      expect(loaded.comments.every((c) => c.id != 'c1'), isTrue);
      await sub.cancel();
      await bloc.close();
    });

    test('emits [CommentError] when deletion fails', () async {
      when(() => mockGetComments(any()))
          .thenAnswer((_) async => Right(tComments));
      when(() => mockDeleteComment(
            highlightId: any(named: 'highlightId'),
            commentId: any(named: 'commentId'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <CommentState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetCommentsEvent(tHighlightId));
      await Future.delayed(const Duration(milliseconds: 100));
      states.clear();

      bloc.add(const DeleteCommentEvent(
        highlightId: tHighlightId,
        commentId: 'c1',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<CommentError>()]);
      expect((states[0] as CommentError).message, 'Failed to delete comment');
      await sub.cancel();
      await bloc.close();
    });
  });
}
