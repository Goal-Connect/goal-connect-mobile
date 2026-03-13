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
  final String userId;
  final String username;
  final String? profileImage;
  final String text;

  const AddCommentEvent({
    required this.highlightId,
    required this.userId,
    required this.username,
    this.profileImage,
    required this.text,
  });

  @override
  List<Object?> get props => [highlightId, userId, text];
}

class DeleteCommentEvent extends CommentEvent {
  final String commentId;
  const DeleteCommentEvent(this.commentId);
  @override
  List<Object?> get props => [commentId];
}
