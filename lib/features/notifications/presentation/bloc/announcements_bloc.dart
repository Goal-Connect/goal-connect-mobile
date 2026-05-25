import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/error/fialures.dart' as fail;
import 'package:goal_connect/features/notifications/domain/entities/announcement.dart';
import 'package:goal_connect/features/notifications/domain/usecases/get_broadcasts_usecase.dart';
import 'package:goal_connect/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────

abstract class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();
  @override
  List<Object?> get props => [];
}

class AnnouncementsRequested extends AnnouncementsEvent {
  const AnnouncementsRequested();
}

class AnnouncementsRefreshRequested extends AnnouncementsEvent {
  const AnnouncementsRefreshRequested();
}

/// Mark a single broadcast as read (e.g. user opened/tapped it). Keeps the
/// item in the list but flips `isRead` so the unread dot disappears.
class AnnouncementRead extends AnnouncementsEvent {
  final String id;
  const AnnouncementRead(this.id);
  @override
  List<Object?> get props => [id];
}

/// Dismiss a broadcast banner — same endpoint as [AnnouncementRead], but the
/// item is removed from the list locally.
class AnnouncementDismissed extends AnnouncementsEvent {
  final String id;
  const AnnouncementDismissed(this.id);
  @override
  List<Object?> get props => [id];
}

// ── State ─────────────────────────────────────────────────────────────────

enum AnnouncementsStatus { initial, loading, refreshing, ready, failure }

class AnnouncementsState extends Equatable {
  final AnnouncementsStatus status;
  final List<Announcement> items;
  final String? errorMessage;

  const AnnouncementsState({
    this.status = AnnouncementsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  int get unreadCount => items.where((a) => !a.isRead).length;
  bool get hasUnread => unreadCount > 0;

  AnnouncementsState copyWith({
    AnnouncementsStatus? status,
    List<Announcement>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnnouncementsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}

// ── Bloc ──────────────────────────────────────────────────────────────────

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final GetBroadcastsUsecase getBroadcasts;
  final MarkNotificationReadUsecase markRead;

  AnnouncementsBloc({
    required this.getBroadcasts,
    required this.markRead,
  }) : super(const AnnouncementsState()) {
    on<AnnouncementsRequested>(_onRequested);
    on<AnnouncementsRefreshRequested>(_onRefresh);
    on<AnnouncementRead>(_onRead);
    on<AnnouncementDismissed>(_onDismissed);
  }

  Future<void> _onRequested(
    AnnouncementsRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.copyWith(
      status: state.items.isEmpty
          ? AnnouncementsStatus.loading
          : AnnouncementsStatus.refreshing,
      clearError: true,
    ));
    await _load(emit);
  }

  Future<void> _onRefresh(
    AnnouncementsRefreshRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.copyWith(
      status: AnnouncementsStatus.refreshing,
      clearError: true,
    ));
    await _load(emit);
  }

  Future<void> _onRead(
    AnnouncementRead event,
    Emitter<AnnouncementsState> emit,
  ) async {
    final original = state.items;
    final idx = original.indexWhere((a) => a.id == event.id);
    if (idx == -1) return;
    final target = original[idx];
    // Already read — nothing to do, avoids a redundant PUT.
    if (target.isRead) return;

    // Optimistic flip.
    final optimistic = List<Announcement>.from(original);
    optimistic[idx] = target.copyWith(isRead: true);
    emit(state.copyWith(items: optimistic, clearError: true));

    final result = await markRead(event.id);
    result.fold(
      (failure) {
        // Roll back to the pre-PUT list and surface the error.
        emit(state.copyWith(
          items: original,
          errorMessage: _messageFor(failure),
        ));
      },
      (_) {/* server confirmed; optimistic state stands */},
    );
  }

  Future<void> _onDismissed(
    AnnouncementDismissed event,
    Emitter<AnnouncementsState> emit,
  ) async {
    final original = state.items;
    final idx = original.indexWhere((a) => a.id == event.id);
    if (idx == -1) return;

    // Optimistic removal.
    final optimistic = List<Announcement>.from(original)..removeAt(idx);
    emit(state.copyWith(items: optimistic, clearError: true));

    final result = await markRead(event.id);
    result.fold(
      (failure) {
        emit(state.copyWith(
          items: original,
          errorMessage: _messageFor(failure),
        ));
      },
      (_) {/* server confirmed */},
    );
  }

  Future<void> _load(Emitter<AnnouncementsState> emit) async {
    final result = await getBroadcasts();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AnnouncementsStatus.failure,
        errorMessage: _messageFor(failure),
      )),
      (items) => emit(state.copyWith(
        status: AnnouncementsStatus.ready,
        items: items,
        clearError: true,
      )),
    );
  }

  String _messageFor(fail.Failure failure) {
    if (failure is fail.AuthFailure && (failure.message ?? '').isNotEmpty) {
      return failure.message!;
    }
    return 'Could not load notifications';
  }
}
