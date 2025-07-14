// lib/models/message.dart
enum MessageStatus { sending, sent, failed }

class Message {
  final String id;
  final bool fromMe;
  final String? text;
  final int timestamp;
  final String jid;
  final String reactions;
  final MessageStatus status;

  Message({
    required this.id,
    required this.fromMe,
    required this.text,
    required this.timestamp,
    required this.jid,
    this.reactions = '',
    this.status = MessageStatus.sent,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        fromMe: json['fromMe'] as bool,
        text: json['text'] as String?,
        timestamp: json['timestamp'] as int,
        jid: json['jid'] as String,
        reactions: json['reactions'] as String? ?? '',
        status: MessageStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (json['status'] as String),
            orElse: () => MessageStatus.sent),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromMe': fromMe,
        'text': text,
        'timestamp': timestamp,
        'jid': jid,
        'reactions': reactions,
        'status': status.toString().split('.').last,
      };
}
