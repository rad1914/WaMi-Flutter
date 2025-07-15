// @path: lib/models/message.dart
enum MessageStatus { sending, sent, failed }

class Message {
  final String id;
  final bool fromMe;
  final String? body; // Changed from text
  final int timestamp;
  final String jid;
  final String reactions;
  final MessageStatus status;
  Message({
    required this.id,
    required this.fromMe,
    this.body, // Changed from text
    required this.timestamp,
    required this.jid,
    this.reactions = '',
    this.status = MessageStatus.sent,
  });
  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        fromMe: json['fromMe'],
        body: json['body'], // Changed from text
        timestamp: json['timestamp'],
        jid: json['jid'],
        reactions: json['reactions'] ?? '',
        status: MessageStatus.values.firstWhere(
            (e) => e.name == (json['status'] as String),
            orElse: () => MessageStatus.sent),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'fromMe': fromMe,
        'body': body, // Changed from text
        'timestamp': timestamp,
        'jid': jid,
        'reactions': reactions,
        'status': status.name,
      };
}