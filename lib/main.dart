// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() {
  runApp(const ProviderScope(child: WaMiApp()));
}

class WaMiApp extends StatelessWidget {
  const WaMiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WaMi',
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}
