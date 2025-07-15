// @path: lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'db/app_database.dart';
import 'providers/database_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Código modernizado para inicializar la DB
  final dbFolder = await getApplicationDocumentsDirectory();
  final path = p.join(dbFolder.path, 'wami.sqlite');
  final db = AppDatabase(
    NativeDatabase(File(path), logStatements: true),
  );

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const WaMiApp(),
    ),
  );
}

class WaMiApp extends StatelessWidget {
  const WaMiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WaMi',
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}