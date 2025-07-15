import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../providers/chat_provider.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (chats) => ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final chat = chats[i];
            return ListTile(
              leading: CircleAvatar(child: Text(chat.name[0])),
              title: Text(chat.name),
              subtitle: Text(chat.jid),
              onTap: () => context.push('/chat/${chat.jid}'),
            );
          },
        ),
      ),
    );
  }
}
