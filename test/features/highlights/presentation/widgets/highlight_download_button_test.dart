import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_connect/core/services/video_downloader.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/highlights/domain/entities/highlight.dart';
import 'package:goal_connect/features/highlights/presentation/widgets/video_overlay_content.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';

User _user() => User(
      id: 'u1',
      email: 'a@b.c',
      role: 'player',
      username: 'alice',
      profileImage: '',
      position: 'forward',
      age: 19,
      country: 'ET',
    );

Highlight _highlight({String videoUrl = 'https://example.com/v.mp4'}) =>
    Highlight(
      id: 'h1',
      player: _user(),
      videoUrl: videoUrl,
      caption: 'caption',
      likes: 0,
      createdAt: DateTime(2026, 5, 24),
    );

/// Downloader stub that lets the test drive progress and decide when to
/// resolve.
class FakeDownloader implements VideoDownloader {
  void Function(double)? _onProgress;
  bool started = false;

  Completer<void>? _completer;

  @override
  Future<void> downloadToGallery(
    String url, {
    String? album,
    DownloadProgressCallback? onProgress,
  }) {
    started = true;
    _onProgress = onProgress;
    _completer = Completer<void>();
    return _completer!.future;
  }

  void emitProgress(double p) => _onProgress?.call(p);
  void finish() => _completer?.complete();
}

Future<void> _pump(WidgetTester tester, Widget body) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: Center(child: body)),
    ),
  );
}

void main() {
  group('HighlightDownloadButton', () {
    testWidgets('shows no label when idle', (tester) async {
      final fake = FakeDownloader();
      await _pump(
        tester,
        HighlightDownloadButton(highlight: _highlight(), downloader: fake),
      );

      // Idle label is the empty string; "0%" should not be rendered yet.
      expect(find.text('0%'), findsNothing);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byIcon(Icons.downloading_rounded), findsNothing);
    });

    testWidgets('renders 0% on tap and updates with onProgress callbacks',
        (tester) async {
      final fake = FakeDownloader();
      await _pump(
        tester,
        HighlightDownloadButton(highlight: _highlight(), downloader: fake),
      );

      await tester.tap(find.byIcon(Icons.download_rounded));
      await tester.pump();

      expect(fake.started, isTrue);
      expect(find.byIcon(Icons.downloading_rounded), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);

      fake.emitProgress(0.42);
      await tester.pump();
      expect(find.text('42%'), findsOneWidget);

      fake.emitProgress(1.0);
      await tester.pump();
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('returns to idle (no percentage) after the download completes',
        (tester) async {
      final fake = FakeDownloader();
      await _pump(
        tester,
        HighlightDownloadButton(highlight: _highlight(), downloader: fake),
      );

      await tester.tap(find.byIcon(Icons.download_rounded));
      await tester.pump();
      fake.emitProgress(0.5);
      await tester.pump();
      expect(find.text('50%'), findsOneWidget);

      fake.finish();
      // Pump the queued microtasks then the snackbar animation frame.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byIcon(Icons.downloading_rounded), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('does not start a download when the video URL is empty',
        (tester) async {
      final fake = FakeDownloader();
      await _pump(
        tester,
        HighlightDownloadButton(
          highlight: _highlight(videoUrl: ''),
          downloader: fake,
        ),
      );

      await tester.tap(find.byIcon(Icons.download_rounded));
      await tester.pump();

      expect(fake.started, isFalse);
      expect(find.byIcon(Icons.downloading_rounded), findsNothing);
    });
  });
}
