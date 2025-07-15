// @path: lib/providers/chat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart'; // Importación necesaria para Value()
import 'package:wa_mi_flutter/db/app_database.dart';
import 'package:wa_mi_flutter/models/chat.dart' as api_chat; // Alias para el chat de la API
import 'package:wa_mi_flutter/providers/session_provider.dart';
import 'package:wa_mi_flutter/providers/database_provider.dart';
import 'package:wa_mi_flutter/api/api_service.dart';

final chatProvider =
    StateNotifierProvider<ChatController, AsyncValue<List<Chat>>>(
  (ref) => ChatController(ref),
);

class ChatController extends StateNotifier<AsyncValue<List<Chat>>> {
  final Ref _ref;
  ChatController(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    final db = _ref.read(databaseProvider);
    // 1) local
    final local = await db.getAllChats();
    state = AsyncValue.data(local);
    // 2) remoto
    final sid = _ref.read(sessionProvider).sessionId;
    if (sid == null) return;
    try {
      final api = _ref.read(apiProvider);
      final List<api_chat.Chat> fresh = await api.fetchChats(sid);
      
      // Conversión manual del modelo de API a ChatsCompanion
      final companions = fresh.map((c) => ChatsCompanion(
        jid: Value(c.jid),
        name: Value(c.name),
      )).toList();

      await db.upsertChats(companions);
      final updated = await db.getAllChats();
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();
}