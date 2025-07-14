// lib/models/chat.dart
class Chat {
  final String jid;
  final String name;

  Chat({required this.jid, required this.name});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        jid: json['jid'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'jid': jid,
        'name': name,
      };
}
