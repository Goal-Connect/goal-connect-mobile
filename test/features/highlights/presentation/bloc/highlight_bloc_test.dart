import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/highlights/domain/entities/highlight.dart';
import 'package:goal_connect/features/highlights/domain/usecases/get_highlights_feed_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/get_player_highlights_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/upload_highlight_usecase.dart';
import 'package:goal_connect/features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_bloc.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_event.dart';
import 'package:goal_connect/features/highlights/presentation/bloc/highlight_state.dart';

class MockGetHighlightsFeedUsecase extends Mock
    implements GetHighlightsFeedUsecase {}

class MockGetPlayerHighlightsUsecase extends Mock
    implements GetPlayerHighlightsUsecase {}

class MockUploadHighlightUsecase extends Mock
    implements UploadHighlightUsecase {}

class MockDeleteHighlightUsecase extends Mock
    implements DeleteHighlightUsecase {}

void main() {
  late MockGetHighlightsFeedUsecase mockGetFeed;
  late MockGetPlayerHighlightsUsecase mockGetPlayerHighlights;
  late MockUploadHighlightUsecase mockUpload;
  late MockDeleteHighlightUsecase mockDelete;

  setUp(() {
    mockGetFeed = MockGetHighlightsFeedUsecase();
    mockGetPlayerHighlights = MockGetPlayerHighlightsUsecase();
    mockUpload = MockUploadHighlightUsecase();
    mockDelete = MockDeleteHighlightUsecase();
  });

  HighlightBloc buildBloc() => HighlightBloc(
        getHighlightsFeed: mockGetFeed,
        getPlayerHighlights: mockGetPlayerHighlights,
        uploadHighlight: mockUpload,
        deleteHighlight: mockDelete,
      );

  final tUser = User(
    id: 'p1',
    email: 'p1@test.com',
    role: 'player',
    username: 'player1',
    profileImage: 'https://example.com/img.jpg',
    position: 'Forward',
    age: 18,
    country: 'Ethiopia',
  );

  final tHighlights = [
    Highlight(
      id: '1',
      player: tUser,
      videoUrl: 'https://example.com/video.mp4',
      caption: 'Great goal!',
      likes: 10,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  final tHighlight = tHighlights.first;

  group('GetHighlightsFeedEvent', () {
    test('emits [HighlightLoading, HighlightLoaded] on success', () async {
      when(() => mockGetFeed()).thenAnswer((_) async => Right(tHighlights));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(GetHighlightsFeedEvent());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightLoading>(), isA<HighlightLoaded>()]);
      expect((states[1] as HighlightLoaded).highlights, tHighlights);
      await sub.cancel();
      await bloc.close();
    });

    test('emits [HighlightLoading, HighlightError] on failure', () async {
      when(() => mockGetFeed()).thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(GetHighlightsFeedEvent());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightLoading>(), isA<HighlightError>()]);
      expect((states[1] as HighlightError).message, 'Failed to load highlights');
      await sub.cancel();
      await bloc.close();
    });
  });

  group('GetPlayerHighlightsEvent', () {
    test('emits [HighlightLoading, HighlightLoaded] on success', () async {
      when(() => mockGetPlayerHighlights(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => Right(tHighlights));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetPlayerHighlightsEvent('p1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightLoading>(), isA<HighlightLoaded>()]);
      await sub.cancel();
      await bloc.close();
    });

    test('emits [HighlightLoading, HighlightError] on failure', () async {
      when(() => mockGetPlayerHighlights(playerId: any(named: 'playerId')))
          .thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetPlayerHighlightsEvent('p1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightLoading>(), isA<HighlightError>()]);
      expect(
          (states[1] as HighlightError).message, 'Failed to load player highlights');
      await sub.cancel();
      await bloc.close();
    });
  });

  group('UploadHighlightEvent', () {
    test('emits [HighlightUploading, HighlightUploaded] on success', () async {
      when(() => mockUpload(
            playerId: any(named: 'playerId'),
            videoPath: any(named: 'videoPath'),
            caption: any(named: 'caption'),
          )).thenAnswer((_) async => Right(tHighlight));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const UploadHighlightEvent(
        playerId: 'p1',
        videoPath: '/path/to/video.mp4',
        caption: 'Great goal!',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightUploading>(), isA<HighlightUploaded>()]);
      await sub.cancel();
      await bloc.close();
    });

    test('emits [HighlightUploading, HighlightError] on failure', () async {
      when(() => mockUpload(
            playerId: any(named: 'playerId'),
            videoPath: any(named: 'videoPath'),
            caption: any(named: 'caption'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const UploadHighlightEvent(
        playerId: 'p1',
        videoPath: '/path/to/video.mp4',
        caption: 'Great goal!',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightUploading>(), isA<HighlightError>()]);
      expect((states[1] as HighlightError).message, 'Upload failed');
      await sub.cancel();
      await bloc.close();
    });
  });

  group('DeleteHighlightEvent', () {
    test('emits [HighlightDeleted] on success', () async {
      when(() => mockDelete(highlightId: any(named: 'highlightId')))
          .thenAnswer((_) async => const Right(null));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DeleteHighlightEvent('1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightDeleted>()]);
      await sub.cancel();
      await bloc.close();
    });

    test('emits [HighlightError] on failure', () async {
      when(() => mockDelete(highlightId: any(named: 'highlightId')))
          .thenAnswer((_) async => Left(ServerFailure()));

      final bloc = buildBloc();
      final states = <HighlightState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DeleteHighlightEvent('1'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [isA<HighlightError>()]);
      expect((states[0] as HighlightError).message, 'Delete failed');
      await sub.cancel();
      await bloc.close();
    });
  });
}
