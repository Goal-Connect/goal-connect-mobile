import 'package:equatable/equatable.dart';
import '../../domain/entities/highlight.dart';

abstract class HighlightState extends Equatable {
  const HighlightState();

  @override
  List<Object?> get props => [];
}

class HighlightInitial extends HighlightState {}

class HighlightLoading extends HighlightState {}

class HighlightLoaded extends HighlightState {
  final List<Highlight> highlights;

  const HighlightLoaded(this.highlights);

  @override
  List<Object?> get props => [highlights];
}

class HighlightUploading extends HighlightState {}

class HighlightUploaded extends HighlightState {}

class HighlightDeleted extends HighlightState {}

class HighlightError extends HighlightState {
  final String message;

  const HighlightError(this.message);

  @override
  List<Object?> get props => [message];
}
