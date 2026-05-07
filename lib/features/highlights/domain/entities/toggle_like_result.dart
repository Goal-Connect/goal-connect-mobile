/// Server response from `POST /videos/{id}/like` (toggle).
class ToggleLikeResult {
  final int likesCount;
  final List<String> likedUserIds;

  const ToggleLikeResult({
    required this.likesCount,
    required this.likedUserIds,
  });
}

/// Server response from `POST /videos/{id}/comments/{commentId}/like`.
class CommentLikeToggleResult {
  final int likesCount;
  final List<String> likedUserIds;

  const CommentLikeToggleResult({
    required this.likesCount,
    required this.likedUserIds,
  });
}
