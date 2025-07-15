class Chat {
  final String jid;
  final String name;

  Chat({required this.jid, required this.name});
  factory Chat.fromJson(Map<String, dynamic> json) =>
      Chat(jid: json['jid'], name: json['name']);
  Map<String, dynamic> toJson() => {'jid': jid, 'name': name};
}
