import 'package:equatable/equatable.dart';

abstract class HighlightEvent extends Equatable {
  const HighlightEvent();

  @override
  List<Object?> get props => [];
}

class GetHighlightsFeedEvent extends HighlightEvent {
  final List<String>? positions;
  final List<String>? regions;
  final int? minAge;
  final int? maxAge;

  const GetHighlightsFeedEvent({
    this.positions,
    this.regions,
    this.minAge,
    this.maxAge,
  });

  @override
  List<Object?> get props => [positions, regions, minAge, maxAge];
}

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
