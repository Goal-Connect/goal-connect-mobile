import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation_model.dart';

abstract class ConversationLocalDataSource {
  Future<List<ConversationModel>> loadThreads();

  Future<void> saveThreads(List<ConversationModel> threads);

  /// Adds or updates by peer user id; preserves existing display name when possible.
  Future<void> upsertThread({
    required String peerUserId,
    required String lastMessage,
    required DateTime updatedAt,
    String? participantName,
    String? participantImage,
    String? participantRole,
    int unreadDelta,
  });

  Future<void> clearAll();
}

class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  ConversationLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  static const _key = 'gc_chat_threads_v1';

  final SharedPreferences _prefs;

  @override
  Future<List<ConversationModel>> loadThreads() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list
          .whereType<Object>()
          .map((e) => ConversationModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveThreads(List<ConversationModel> threads) async {
    final encoded =
        jsonEncode(threads.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(_key, encoded);
  }

  @override
  Future<void> upsertThread({
    required String peerUserId,
    required String lastMessage,
    required DateTime updatedAt,
    String? participantName,
    String? participantImage,
    String? participantRole,
    int unreadDelta = 0,
  }) async {
    final threads = await loadThreads();
    final idx = threads.indexWhere((t) => t.id == peerUserId);
    if (idx < 0) {
      threads.add(
        ConversationModel(
          id: peerUserId,
          participantId: peerUserId,
          participantName: participantName ?? 'Member',
          participantImage: participantImage,
          participantRole: participantRole ?? 'member',
          lastMessage: lastMessage,
          updatedAt: updatedAt,
          unreadCount: unreadDelta > 0 ? unreadDelta : 0,
        ),
      );
    } else {
      final old = threads[idx];
      final name = (participantName != null &&
              participantName.isNotEmpty &&
              participantName != 'Member')
          ? participantName
          : old.participantName;
      threads[idx] = ConversationModel(
        id: peerUserId,
        participantId: peerUserId,
        participantName: name,
        participantImage: participantImage ?? old.participantImage,
        participantRole: participantRole ?? old.participantRole,
        lastMessage: lastMessage,
        updatedAt: updatedAt,
        unreadCount: (old.unreadCount + unreadDelta).clamp(0, 999),
      );
    }
    threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await saveThreads(threads);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_key);
  }
}
