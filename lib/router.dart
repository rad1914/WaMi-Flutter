import 'package:go_router/go_router.dart';
import 'screens/qr_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/message_screen.dart';

final router = GoRouter(
  initialLocation: '/qr',
  routes: [
    GoRoute(path: '/qr', builder: (_, __) => const QRScreen()),
    GoRoute(path: '/chats', builder: (_, __) => const ChatScreen()),
    GoRoute(
      path: '/chat/:jid',
      builder: (context, state) {
        final jid = state.pathParameters['jid']!;
        return MessageScreen(jid: jid);
      },
    ),
  ],
);
