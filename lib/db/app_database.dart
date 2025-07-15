// @path: lib/db/app_database.dart
import 'package:drift/drift.dart';

// Se eliminó la siguiente línea porque ya no se usa:
// import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Chats extends Table {
  TextColumn get jid => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {jid};
}

class Messages extends Table {
  TextColumn get id => text().customConstraint('UNIQUE NOT NULL')();
  BoolColumn get fromMe => boolean().withDefault(const Constant(false))();
  TextColumn get body => text().nullable()();
  IntColumn get timestamp => integer()();
  TextColumn get jid => text()();
  TextColumn get reactions => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('sent'))();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Chats, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);
  @override
  int get schemaVersion => 1;

  Future<List<Chat>> getAllChats() => select(chats).get();
  
  Future<void> upsertChats(List<ChatsCompanion> list) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(chats, list);
    });
  }

  Future<void> clearChats() => delete(chats).go();

  Future<List<Message>> getMessagesFor(String jidFilter) =>
      (select(messages)
            ..where((m) => m.jid.equals(jidFilter))
            ..orderBy([
              (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
            ]))
          .get();
          
  Future<void> upsertMessages(List<MessagesCompanion> list) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(messages, list);
    });
  }

  Future<void> clearMessagesFor(String jidFilter) =>
      (delete(messages)..where((m) => m.jid.equals(jidFilter))).go();
}