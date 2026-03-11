import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_highlight_usecase.dart';
import '../../domain/usecases/delete_highlight_usecase.dart';
import '../../domain/usecases/get_highlights_feed_usecase.dart';
import '../../domain/usecases/get_player_highlights_usecase.dart';
import 'highlight_event.dart';
import 'highlight_state.dart';

class HighlightBloc extends Bloc<HighlightEvent, HighlightState> {
  final UploadHighlightUsecase uploadHighlight;
  final DeleteHighlightUsecase deleteHighlight;
  final GetHighlightsFeedUsecase getHighlightsFeed;
  final GetPlayerHighlightsUsecase getPlayerHighlights;

  HighlightBloc({
    required this.uploadHighlight,
    required this.deleteHighlight,
    required this.getHighlightsFeed,
    required this.getPlayerHighlights,
  }) : super(HighlightInitial()) {
    on<GetHighlightsFeedEvent>((event, emit) async {
      emit(HighlightLoading());

      final result = await getHighlightsFeed();

      result.fold(
        (failure) => emit(const HighlightError("Failed to load highlights")),
        (highlights) => emit(HighlightLoaded(highlights)),
      );
    });

    on<GetPlayerHighlightsEvent>((event, emit) async {
      emit(HighlightLoading());

      final result = await getPlayerHighlights(playerId: event.playerId);

      result.fold(
        (failure) =>
            emit(const HighlightError("Failed to load player highlights")),
        (highlights) => emit(HighlightLoaded(highlights)),
      );
    });

    on<UploadHighlightEvent>((event, emit) async {
      emit(HighlightUploading());

      final result = await uploadHighlight(
        playerId: event.playerId,
        videoPath: event.videoPath,
        caption: event.caption,
      );

      result.fold(
        (failure) => emit(const HighlightError("Upload failed")),
        (_) => emit(HighlightUploaded()),
      );
    });

    on<DeleteHighlightEvent>((event, emit) async {
      final result = await deleteHighlight(highlightId: event.highlightId);

      result.fold(
        (failure) => emit(const HighlightError("Delete failed")),
        (_) => emit(HighlightDeleted()),
      );
    });
  }
}
