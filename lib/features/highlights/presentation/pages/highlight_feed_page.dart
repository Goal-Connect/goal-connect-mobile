import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/highlight_event.dart';
import '../bloc/highlight_state.dart';
import '../../domain/entities/highlight.dart';
import '../widgets/video_feed_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/domain/entities/scout_preference.dart';
import '../../../profile/domain/usecases/get_scout_preference_usecase.dart';

class HighlightFeedPage extends StatefulWidget {
  const HighlightFeedPage({super.key});
  @override
  State<HighlightFeedPage> createState() => _HighlightFeedPageState();
}

class _HighlightFeedPageState extends State<HighlightFeedPage> {
  /// Last successful feed result. Kept so transient bloc states
  /// (HighlightUploaded / HighlightDeleted / HighlightUploading) don't blank
  /// out the screen while a re-fetch is in flight.
  List<Highlight>? _cachedHighlights;

  /// Last scout preference we observed. Used to detect when the user has
  /// changed their preferences in settings so the feed refetches automatically
  /// when they pop back to this page.
  ScoutPreference? _lastAppliedPreference;

  @override
  void initState() {
    super.initState();
    _dispatchFetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // After returning from the Scout Preferences page, refetch if the
    // saved preference has changed.
    _maybeRefetchIfPreferenceChanged();
  }

  Future<ScoutPreference?> _loadPreference() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated ||
        auth.user.role.toLowerCase() != 'scout') {
      return null;
    }
    final result = await sl<GetScoutPreferenceUsecase>().call();
    return result.fold((_) => null, (pref) => pref);
  }

  Future<void> _dispatchFetch() async {
    final pref = await _loadPreference();
    if (!mounted) return;
    _lastAppliedPreference = pref;
    context.read<HighlightBloc>().add(
          GetHighlightsFeedEvent(
            position: pref?.firstPosition,
            region: pref?.firstRegion,
            minAge: pref?.minAge,
            maxAge: pref?.maxAge,
          ),
        );
  }

  Future<void> _maybeRefetchIfPreferenceChanged() async {
    final pref = await _loadPreference();
    if (!mounted) return;
    if (_prefEquals(pref, _lastAppliedPreference)) return;
    _lastAppliedPreference = pref;
    context.read<HighlightBloc>().add(
          GetHighlightsFeedEvent(
            position: pref?.firstPosition,
            region: pref?.firstRegion,
            minAge: pref?.minAge,
            maxAge: pref?.maxAge,
          ),
        );
  }

  bool _prefEquals(ScoutPreference? a, ScoutPreference? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return _listEquals(a.positions, b.positions) &&
        _listEquals(a.regions, b.regions) &&
        a.minAge == b.minAge &&
        a.maxAge == b.maxAge;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _refetch() {
    final pref = _lastAppliedPreference;
    context.read<HighlightBloc>().add(
          GetHighlightsFeedEvent(
            position: pref?.firstPosition,
            region: pref?.firstRegion,
            minAge: pref?.minAge,
            maxAge: pref?.maxAge,
          ),
        );
  }

  bool _refreshing = false;
  double _pullDistance = 0;
  static const double _pullThreshold = 80;

  void _handlePullStart() {
    if (_refreshing) return;
    setState(() => _pullDistance = 0);
  }

  void _handlePullUpdate(double delta) {
    if (_refreshing) return;
    final next = (_pullDistance + delta).clamp(0.0, _pullThreshold * 1.5);
    if (next == _pullDistance) return;
    setState(() => _pullDistance = next);
  }

  Widget _buildPullToRefresh({required Widget child}) {
    final progress = (_pullDistance / _pullThreshold).clamp(0.0, 1.0);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _handlePullStart();
        } else if (notification is OverscrollNotification &&
            notification.metrics.axis == Axis.vertical &&
            notification.overscroll < 0) {
          // Only pull-down (negative overscroll at top) counts.
          _handlePullUpdate(-notification.overscroll);
        } else if (notification is ScrollEndNotification) {
          _handlePullEnd();
        }
        return false;
      },
      child: Stack(
        children: [
          child,
          if (_pullDistance > 0 || _refreshing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: _refreshing ? 1.0 : progress,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: _refreshing
                          ? const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.primaryGreen,
                            )
                          : CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.primaryGreen,
                              value: progress,
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handlePullEnd() async {
    if (_refreshing) {
      return;
    }
    if (_pullDistance >= _pullThreshold) {
      setState(() {
        _refreshing = true;
        _pullDistance = _pullThreshold;
      });
      _refetch();
      // The bloc emits HighlightLoaded/HighlightError; reset when state arrives.
      await context
          .read<HighlightBloc>()
          .stream
          .firstWhere((s) => s is HighlightLoaded || s is HighlightError);
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _pullDistance = 0;
      });
    } else {
      setState(() => _pullDistance = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<HighlightBloc, HighlightState>(
        listener: (context, state) {
          developer.log('feed state: ${state.runtimeType}', name: 'highlights');
          if (state is HighlightLoaded) {
            _cachedHighlights = state.highlights;
          } else if (state is HighlightUploaded || state is HighlightDeleted) {
            // Triggered by the profile page on this shared bloc — refetch
            // so the feed comes back to HighlightLoaded.
            _refetch();
          } else if (state is HighlightError) {
            developer.log('feed error: ${state.message}', name: 'highlights');
          }
        },
        builder: (context, state) {
          // Use the freshest loaded list, or fall back to the last good one
          // so the feed stays visible during refetches.
          final highlights = state is HighlightLoaded
              ? state.highlights
              : _cachedHighlights;

          if (highlights != null && highlights.isNotEmpty) {
            return _buildPullToRefresh(
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: highlights.length,
                itemBuilder: (context, index) => VideoFeedItem(
                  highlight: highlights[index],
                  onVideoChanged: _refetch,
                ),
              ),
            );
          }

          if (state is HighlightError) {
            return _ErrorState(message: state.message, onRetry: _refetch);
          }

          if (state is HighlightLoaded && state.highlights.isEmpty) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) {
              return const LoginPage();
            }
            return const _EmptyState();
          }

          // HighlightInitial / HighlightLoading / HighlightUploading
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_rounded,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).highlightsNoHighlightsYet,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: Colors.white.withOpacity(0.5), size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text(
                AppLocalizations.of(context).commonTryAgain,
                style: const TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
