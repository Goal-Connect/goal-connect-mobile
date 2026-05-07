import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();
  @override
  List<Object?> get props => [];
}

class GetCommentsEvent extends CommentEvent {
  final String highlightId;
  const GetCommentsEvent(this.highlightId);
  @override
  List<Object?> get props => [highlightId];
}

class AddCommentEvent extends CommentEvent {
  final String highlightId;
  final String text;
  final String? parentCommentId;

  const AddCommentEvent({
    required this.highlightId,
    required this.text,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [highlightId, text, parentCommentId];
}

class DeleteCommentEvent extends CommentEvent {
  final String highlightId;
  final String commentId;
  const DeleteCommentEvent({
    required this.highlightId,
    required this.commentId,
  });
  @override
  List<Object?> get props => [highlightId, commentId];
}

class ToggleCommentLikeEvent extends CommentEvent {
  final String highlightId;
  final String commentId;

  const ToggleCommentLikeEvent({
    required this.highlightId,
    required this.commentId,
  });

  @override
  List<Object?> get props => [highlightId, commentId];
}
