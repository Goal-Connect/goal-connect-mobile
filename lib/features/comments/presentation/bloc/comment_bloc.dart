import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUsecase getComments;
  final AddCommentUsecase addComment;
  final DeleteCommentUsecase deleteComment;

  CommentBloc({
    required this.getComments,
    required this.addComment,
    required this.deleteComment,
  }) : super(CommentInitial()) {
    on<GetCommentsEvent>((event, emit) async {
      emit(CommentLoading());
      final result = await getComments(event.highlightId);
      result.fold(
        (failure) => emit(const CommentError('Failed to load comments')),
        (comments) => emit(
          CommentsLoaded(comments: comments, highlightId: event.highlightId),
        ),
      );
    });

    on<AddCommentEvent>((event, emit) async {
      final current = state;
      final currentComments =
          current is CommentsLoaded ? current.comments : [];

      emit(CommentPosting(
        currentComments: List.from(currentComments),
        highlightId: event.highlightId,
      ));

      final result = await addComment(
        highlightId: event.highlightId,
        userId: event.userId,
        username: event.username,
        profileImage: event.profileImage,
        text: event.text,
      );

      result.fold(
        (failure) => emit(const CommentError('Failed to post comment')),
        (newComment) {
          final updated = <Comment>[newComment, ...currentComments];
          emit(CommentsLoaded(
              comments: updated, highlightId: event.highlightId));
        },
      );
    });

    on<DeleteCommentEvent>((event, emit) async {
      final current = state;
      if (current is CommentsLoaded) {
        final result = await deleteComment(event.commentId);
        result.fold(
          (failure) => emit(const CommentError('Failed to delete comment')),
          (_) {
            final updated =
                current.comments.where((c) => c.id != event.commentId).toList();
            emit(CommentsLoaded(
                comments: updated, highlightId: current.highlightId));
          },
        );
      }
    });
  }
}
