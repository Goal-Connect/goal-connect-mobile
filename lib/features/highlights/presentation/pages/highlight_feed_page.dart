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
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<HighlightBloc>().add(GetHighlightsFeedEvent());
  }

  void _refetch() {
    context.read<HighlightBloc>().add(GetHighlightsFeedEvent());
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
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: highlights.length,
              itemBuilder: (context, index) => VideoFeedItem(
                highlight: highlights[index],
                onVideoChanged: _refetch,
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
