import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import 'package:go_router/go_router.dart';

class QRScreen extends ConsumerWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status == SessionStatus.authenticated) {
        context.go('/chats');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('WaMi - Scan QR')),
      body: Center(
        child: switch (session.status) {
          SessionStatus.loading => const CircularProgressIndicator(),
          SessionStatus.awaitingScan => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (session.qr != null)
                Image.memory(
                  base64Decode(session.qr!.split(',').last),
                  width: 250,
                  height: 250,
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Generando QR...'),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final id = await showDialog<String>(
                    context: context,
                    builder: (_) => _SessionIdDialog(),
                  );
                  if (id != null) {
                    ref.read(sessionProvider.notifier).loginWithId(id);
                  }
                },
                child: const Text('Login con ID'),
              ),
            ],
          ),
          SessionStatus.error => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.message ?? 'Error desconocido',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(sessionProvider.notifier).start(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _SessionIdDialog extends StatefulWidget {
  @override
  State<_SessionIdDialog> createState() => _SessionIdDialogState();
}

class _SessionIdDialogState extends State<_SessionIdDialog> {
  String input = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ingresa Session ID'),
      content: TextField(
        onChanged: (v) => setState(() => input = v),
        decoration: const InputDecoration(labelText: 'Session ID'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context, input), child: const Text('OK')),
      ],
    );
  }
}
