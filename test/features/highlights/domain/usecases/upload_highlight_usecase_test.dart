import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/highlights/domain/entities/highlight.dart';
import 'package:goal_connect/features/highlights/domain/repositories/highlight_repository.dart';
import 'package:goal_connect/features/highlights/domain/usecases/upload_highlight_usecase.dart';

class MockHighlightRepository extends Mock implements HighlightRepository {}

void main() {
  late UploadHighlightUsecase usecase;
  late MockHighlightRepository mockRepository;

  setUp(() {
    mockRepository = MockHighlightRepository();
    usecase = UploadHighlightUsecase(mockRepository);
  });

  const tPlayerId = 'player1';
  const tVideoPath = '/path/to/video.mp4';
  const tCaption = 'Amazing skills!';

  final tHighlight = Highlight(
    id: '1',
    player: User(
      id: tPlayerId,
      email: 'p1@test.com',
      role: 'player',
      username: 'player1',
      profileImage: 'https://example.com/img.jpg',
      position: 'Forward',
      age: 18,
      country: 'Ethiopia',
    ),
    videoUrl: 'https://example.com/video.mp4',
    caption: tCaption,
    likes: 0,
    createdAt: DateTime(2026, 1, 1),
  );

  test('should return uploaded highlight on success', () async {
    when(() => mockRepository.uploadHighlight(
          playerId: any(named: 'playerId'),
          videoPath: any(named: 'videoPath'),
          caption: any(named: 'caption'),
        )).thenAnswer((_) async => Right(tHighlight));

    final result = await usecase(
      playerId: tPlayerId,
      videoPath: tVideoPath,
      caption: tCaption,
    );

    expect(result, Right(tHighlight));
    verify(() => mockRepository.uploadHighlight(
          playerId: tPlayerId,
          videoPath: tVideoPath,
          caption: tCaption,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when upload fails', () async {
    when(() => mockRepository.uploadHighlight(
          playerId: any(named: 'playerId'),
          videoPath: any(named: 'videoPath'),
          caption: any(named: 'caption'),
        )).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(
      playerId: tPlayerId,
      videoPath: tVideoPath,
      caption: tCaption,
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
  });

  test('should forward exact parameters to the repository', () async {
    when(() => mockRepository.uploadHighlight(
          playerId: any(named: 'playerId'),
          videoPath: any(named: 'videoPath'),
          caption: any(named: 'caption'),
        )).thenAnswer((_) async => Right(tHighlight));

    await usecase(
      playerId: 'specificPlayer',
      videoPath: '/specific/path.mp4',
      caption: 'Specific caption',
    );

    verify(() => mockRepository.uploadHighlight(
          playerId: 'specificPlayer',
          videoPath: '/specific/path.mp4',
          caption: 'Specific caption',
        )).called(1);
  });
}
