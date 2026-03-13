import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';

abstract class CommentState extends Equatable {
  const CommentState();
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentsLoaded extends CommentState {
  final List<Comment> comments;
  final String highlightId;
  const CommentsLoaded({required this.comments, required this.highlightId});
  @override
  List<Object?> get props => [comments, highlightId];
}

class CommentPosting extends CommentState {
  final List<Comment> currentComments;
  final String highlightId;
  const CommentPosting(
      {required this.currentComments, required this.highlightId});
  @override
  List<Object?> get props => [currentComments, highlightId];
}

class CommentError extends CommentState {
  final String message;
  const CommentError(this.message);
  @override
  List<Object?> get props => [message];
}
