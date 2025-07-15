// @path: lib/providers/message_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart'; // Importación necesaria para Value()
import 'package:wa_mi_flutter/db/app_database.dart';
import 'package:wa_mi_flutter/models/message.dart' as api_message; // Alias para el mensaje de la API
import 'package:wa_mi_flutter/providers/session_provider.dart';
import 'package:wa_mi_flutter/api/api_service.dart';
import 'package:wa_mi_flutter/providers/database_provider.dart';

final messageProvider = StateNotifierProvider.family<
    MessageController, AsyncValue<List<Message>>, String>(
  (ref, jid) => MessageController(ref, jid),
);

class MessageController extends StateNotifier<AsyncValue<List<Message>>> {
  final Ref _ref;
  final String _jid;
  final _uuid = const Uuid();
  MessageController(this._ref, this._jid)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    final db = _ref.read(databaseProvider);
    // local
    final local = await db.getMessagesFor(_jid);
    state = AsyncValue.data(local);
    // remoto
    final sid = _ref.read(sessionProvider).sessionId;
    if (sid == null) return;
    try {
      final api = _ref.read(apiProvider);
      final List<api_message.Message> fresh = await api.fetchMessages(sid, _jid);
      await db.clearMessagesFor(_jid);

      // Conversión manual del modelo de API a MessagesCompanion
      final companions = fresh.map((m) => MessagesCompanion(
        id: Value(m.id),
        fromMe: Value(m.fromMe),
        body: Value(m.body),
        timestamp: Value(m.timestamp),
        jid: Value(m.jid),
        reactions: Value(m.reactions),
        status: Value(m.status.name),
      )).toList();
      
      await db.upsertMessages(companions);
      final updated = await db.getMessagesFor(_jid);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> send(String text) async {
    final sid = _ref.read(sessionProvider).sessionId;
    if (sid == null) return;
    final db = _ref.read(databaseProvider);

    // optimista
    final temp = Message(
      id: _uuid.v4(),
      fromMe: true,
      body: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      jid: _jid,
      reactions: '',
      status: 'sending',
    );
    await db.upsertMessages([temp.toCompanion(true)]);
    state = AsyncValue.data(await db.getMessagesFor(_jid));

    final ok = await _ref.read(apiProvider).sendMessage(sid, _jid, text);
    final finalMsg = Message(
      id: temp.id,
      fromMe: true,
      body: temp.body,
      timestamp: temp.timestamp,
      jid: temp.jid,
      reactions: temp.reactions,
      status: ok ? 'sent' : 'failed',
    );
    await db.upsertMessages([finalMsg.toCompanion(true)]);
    state = AsyncValue.data(await db.getMessagesFor(_jid));
  }
}