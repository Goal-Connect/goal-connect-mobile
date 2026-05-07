import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/toggle_comment_like_usecase.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUsecase getComments;
  final AddCommentUsecase addComment;
  final DeleteCommentUsecase deleteComment;
  final ToggleCommentLikeUsecase toggleCommentLike;

  CommentBloc({
    required this.getComments,
    required this.addComment,
    required this.deleteComment,
    required this.toggleCommentLike,
  }) : super(CommentInitial()) {
    on<GetCommentsEvent>(_onGetComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<ToggleCommentLikeEvent>(_onToggleCommentLike);
  }

  Future<void> _onGetComments(
    GetCommentsEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final result = await getComments(event.highlightId);
    result.fold(
      (failure) => emit(const CommentError('Failed to load comments')),
      (comments) => emit(
        CommentsLoaded(comments: comments, highlightId: event.highlightId),
      ),
    );
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentPosting(
      highlightId: event.highlightId,
    ));
    final result = await addComment(
      highlightId: event.highlightId,
      text: event.text,
      parentCommentId: event.parentCommentId,
    );
    result.fold(
      (failure) => emit(const CommentError('Failed to post comment')),
      (_) => add(GetCommentsEvent(event.highlightId)),
    );
  }

  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    final result = await deleteComment(
      highlightId: event.highlightId,
      commentId: event.commentId,
    );
    result.fold(
      (failure) => emit(const CommentError('Failed to delete comment')),
      (_) => add(GetCommentsEvent(event.highlightId)),
    );
  }

  Future<void> _onToggleCommentLike(
    ToggleCommentLikeEvent event,
    Emitter<CommentState> emit,
  ) async {
    final result = await toggleCommentLike(
      highlightId: event.highlightId,
      commentId: event.commentId,
    );
    result.fold(
      (failure) => emit(const CommentError('Could not update like')),
      (_) => add(GetCommentsEvent(event.highlightId)),
    );
  }
}
