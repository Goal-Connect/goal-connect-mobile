import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:goal_connect/core/error/fialures.dart';
import 'package:goal_connect/features/auth/domain/entities/user.dart';
import 'package:goal_connect/features/highlights/domain/entities/highlight.dart';
import 'package:goal_connect/features/highlights/domain/repositories/highlight_repository.dart';
import 'package:goal_connect/features/highlights/domain/usecases/get_highlights_feed_usecase.dart';

class MockHighlightRepository extends Mock implements HighlightRepository {}

void main() {
  late GetHighlightsFeedUsecase usecase;
  late MockHighlightRepository mockRepository;

  setUp(() {
    mockRepository = MockHighlightRepository();
    usecase = GetHighlightsFeedUsecase(mockRepository);
  });

  final tHighlights = [
    Highlight(
      id: '1',
      player: User(
        id: 'p1',
        email: 'p1@test.com',
        role: 'player',
        username: 'player1',
        profileImage: 'https://example.com/img.jpg',
        position: 'Forward',
        age: 18,
        country: 'Ethiopia',
      ),
      videoUrl: 'https://example.com/video.mp4',
      caption: 'Great goal!',
      likes: 10,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  test('should return list of highlights from the repository on success', () async {
    when(() => mockRepository.getHighlightsFeed())
        .thenAnswer((_) async => Right(tHighlights));

    final result = await usecase();

    expect(result, Right(tHighlights));
    verify(() => mockRepository.getHighlightsFeed()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    when(() => mockRepository.getHighlightsFeed())
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase();

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Expected a Left'),
    );
    verify(() => mockRepository.getHighlightsFeed()).called(1);
  });

  test('should return empty list when no highlights exist', () async {
    when(() => mockRepository.getHighlightsFeed())
        .thenAnswer((_) async => const Right([]));

    final result = await usecase();

    expect(result, const Right(<Highlight>[]));
    verify(() => mockRepository.getHighlightsFeed()).called(1);
  });
}
