import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:goal_connect/core/services/local_notifications_service.dart';
import 'package:goal_connect/features/notifications/domain/entities/announcement.dart';
import 'package:goal_connect/features/notifications/domain/usecases/get_broadcasts_usecase.dart';
import 'package:goal_connect/features/notifications/presentation/bloc/announcements_bloc.dart';

/// HTTP polling for broadcast announcements.
///
/// Runs [GetBroadcastsUsecase] on a fixed interval (default 30s) while
/// [start] is active. On each tick:
///  1. Compares the fetched ids against the previous fetch.
///  2. For every **new and unread** broadcast, fires an OS notification via
///     [LocalNotificationsService].
///  3. Dispatches `AnnouncementsRefreshRequested` to [bloc] so the in-app
///     red dot + list pick up the change.
///
/// Pause via [stop] when the app is backgrounded to save battery.
class AnnouncementsPoller {
  final GetBroadcastsUsecase getBroadcasts;
  final LocalNotificationsService notifier;
  final Duration interval;

  /// Resolves the active [AnnouncementsBloc] lazily. The bloc lives in the
  /// widget tree (BlocProvider) while the poller lives in GetIt, so this
  /// getter lets the host pass `() => context.read<AnnouncementsBloc>()`.
  AnnouncementsBloc? Function()? blocResolver;

  AnnouncementsPoller({
    required this.getBroadcasts,
    required this.notifier,
    this.interval = const Duration(seconds: 30),
  });

  Timer? _timer;
  bool _running = false;
  // Tracks every id we've ever seen so we only notify for *genuinely new*
  // broadcasts — not items that were unread the moment polling started.
  final Set<String> _knownIds = <String>{};
  bool _seedDone = false;

  /// Start polling immediately and at every [interval] thereafter.
  /// Safe to call repeatedly — no-op if already running.
  void start() {
    if (_running) return;
    _running = true;
    // Fire once immediately so the badge shows up before the first interval.
    unawaited(_tick());
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  /// Drop all known-id state. Call on logout so a fresh login can re-seed.
  void reset() {
    _knownIds.clear();
    _seedDone = false;
  }

  Future<void> _tick() async {
    final result = await getBroadcasts();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '[AnnouncementsPoller] fetch failed: '
            '${failure.runtimeType}',
          );
        }
      },
      (items) => _onFetched(items),
    );
  }

  void _onFetched(List<Announcement> items) {
    final currentIds = items.map((a) => a.id).toSet();

    // First successful fetch: seed the known set so we don't surface
    // existing-unread items as "new" notifications. They're already shown
    // in-app via the bell dot.
    if (!_seedDone) {
      _knownIds.addAll(currentIds);
      _seedDone = true;
      _refreshBloc();
      return;
    }

    final newIds = currentIds.difference(_knownIds);
    if (newIds.isEmpty) {
      _refreshBloc();
      return;
    }

    for (final a in items) {
      if (!newIds.contains(a.id)) continue;
      if (a.isRead) continue; // skip pre-read items
      unawaited(notifier.showBroadcast(
        id: _idHash(a.id),
        title: a.title.isNotEmpty ? a.title : 'Announcement',
        body: a.body,
      ));
    }
    _knownIds.addAll(currentIds);
    _refreshBloc();
  }

  void _refreshBloc() {
    final bloc = blocResolver?.call();
    if (bloc == null || bloc.isClosed) return;
    bloc.add(const AnnouncementsRefreshRequested());
  }

  /// Stable 32-bit int derived from the Mongo ObjectId so duplicate
  /// notifications collapse instead of stacking.
  static int _idHash(String id) {
    // Strip to 31 bits to stay inside Android's int notification id range.
    return id.hashCode & 0x7fffffff;
  }
}
