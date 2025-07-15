// @path: lib/screens/message_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/message_provider.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final String jid;
  const MessageScreen({super.key, required this.jid});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final msgsAsync = ref.watch(messageProvider(widget.jid));
    return Scaffold(
      appBar: AppBar(title: Text(widget.jid)),
      body: Column(
        children: [
          Expanded(
            child: msgsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (msgs) => ListView.builder(
                reverse: true,
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  final fromMe = m.fromMe;
                  return Align(
                    alignment:
                        fromMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: fromMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(m.body ?? '[Media]'), // Changed from m.text
                            if (fromMe)
                              Text(m.status,
                                  style: Theme.of(context).textTheme.bodySmall),
                            if (m.reactions.isNotEmpty)
                              Text('Reacciones: ${m.reactions}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'Escribir…'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _ctrl.text.trim();
                      if (text.isNotEmpty) {
                        ref
                            .read(messageProvider(widget.jid).notifier)
                            .send(text);
                        _ctrl.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}