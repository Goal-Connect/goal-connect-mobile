import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/highlights/data/datasources/highlight_remote_datasource.dart';
import 'package:goal_connect/features/highlights/data/models/highlight_model.dart';
import 'package:goal_connect/features/highlights/data/repositories/highlight_repository_impl.dart';

class MockHighlightRemoteDataSource extends Mock
    implements HighlightRemoteDataSource {}

void main() {
  late HighlightRepositoryImpl repository;
  late MockHighlightRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHighlightRemoteDataSource();
    repository = HighlightRepositoryImpl(remoteDataSource: mockDataSource);
  });

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

  final tHighlightModel = HighlightModel(
    id: '1',
    player: tUser,
    videoUrl: 'https://example.com/video.mp4',
    caption: 'Great goal!',
    likes: 10,
    createdAt: DateTime(2026, 1, 1),
  );

  final tHighlightModels = [tHighlightModel];

  group('getHighlightsFeed', () {
    test('should return list of highlights when datasource succeeds', () async {
      when(() => mockDataSource.getHighlightsFeed())
          .thenAnswer((_) async => tHighlightModels);

      final result = await repository.getHighlightsFeed();

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected a Right'),
        (highlights) => expect(highlights, tHighlightModels),
      );
      verify(() => mockDataSource.getHighlightsFeed()).called(1);
    });

    test('should return ServerFailure when datasource throws', () async {
      when(() => mockDataSource.getHighlightsFeed()).thenThrow(Exception('Server error'));

      final result = await repository.getHighlightsFeed();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });
  });

  group('uploadHighlight', () {
    test('should return highlight when upload succeeds', () async {
      when(() => mockDataSource.uploadHighlight(
            playerId: any(named: 'playerId'),
            videoPath: any(named: 'videoPath'),
            caption: any(named: 'caption'),
          )).thenAnswer((_) async => tHighlightModel);

      final result = await repository.uploadHighlight(
        playerId: 'p1',
        videoPath: '/path/to/video.mp4',
        caption: 'Great goal!',
      );

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected a Right'),
        (highlight) => expect(highlight, tHighlightModel),
      );
    });

    test('should return ServerFailure when upload throws', () async {
      when(() => mockDataSource.uploadHighlight(
            playerId: any(named: 'playerId'),
            videoPath: any(named: 'videoPath'),
            caption: any(named: 'caption'),
          )).thenThrow(Exception('Upload error'));

      final result = await repository.uploadHighlight(
        playerId: 'p1',
        videoPath: '/path/to/video.mp4',
        caption: 'Great goal!',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });
  });

  group('deleteHighlight', () {
    test('should return Right(void) when deletion succeeds', () async {
      when(() => mockDataSource.deleteHighlight(any()))
          .thenAnswer((_) async {});

      final result = await repository.deleteHighlight(highlightId: '1');

      expect(result, const Right(null));
      verify(() => mockDataSource.deleteHighlight('1')).called(1);
    });

    test('should return ServerFailure when deletion throws', () async {
      when(() => mockDataSource.deleteHighlight(any()))
          .thenThrow(Exception('Delete error'));

      final result = await repository.deleteHighlight(highlightId: '1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });
  });

  group('getPlayerHighlights', () {
    test('should return list of player highlights on success', () async {
      when(() => mockDataSource.getPlayerHighlights(any()))
          .thenAnswer((_) async => tHighlightModels);

      final result = await repository.getPlayerHighlights(playerId: 'p1');

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('Expected a Right'),
        (highlights) => expect(highlights, tHighlightModels),
      );
      verify(() => mockDataSource.getPlayerHighlights('p1')).called(1);
    });

    test('should return ServerFailure when datasource throws', () async {
      when(() => mockDataSource.getPlayerHighlights(any()))
          .thenThrow(Exception('Fetch error'));

      final result = await repository.getPlayerHighlights(playerId: 'p1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });
  });

  group('toggleLike', () {
    test('should return true when like is toggled on', () async {
      when(() => mockDataSource.toggleLike(any()))
          .thenAnswer((_) async => true);

      final result = await repository.toggleLike(highlightId: '1');

      expect(result, const Right(true));
      verify(() => mockDataSource.toggleLike('1')).called(1);
    });

    test('should return false when like is toggled off', () async {
      when(() => mockDataSource.toggleLike(any()))
          .thenAnswer((_) async => false);

      final result = await repository.toggleLike(highlightId: '1');

      expect(result, const Right(false));
    });

    test('should return ServerFailure when toggle throws', () async {
      when(() => mockDataSource.toggleLike(any()))
          .thenThrow(Exception('Toggle error'));

      final result = await repository.toggleLike(highlightId: '1');

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected a Left'),
      );
    });
  });
}
