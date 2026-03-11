import 'package:equatable/equatable.dart';

abstract class HighlightEvent extends Equatable {
  const HighlightEvent();

  @override
  List<Object?> get props => [];
}

class GetHighlightsFeedEvent extends HighlightEvent {}

class GetPlayerHighlightsEvent extends HighlightEvent {
  final String playerId;

  const GetPlayerHighlightsEvent(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class UploadHighlightEvent extends HighlightEvent {
  final String playerId;
  final String videoPath;
  final String caption;

  const UploadHighlightEvent({
    required this.playerId,
    required this.videoPath,
    required this.caption,
  });

  @override
  List<Object?> get props => [playerId, videoPath, caption];
}

class DeleteHighlightEvent extends HighlightEvent {
  final String highlightId;

  const DeleteHighlightEvent(this.highlightId);

  @override
  List<Object?> get props => [highlightId];
}
