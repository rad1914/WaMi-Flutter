// lib/api/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://22.ip.gl.ply.gg:18880',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));

  Future<String> createSession() async {
    final resp = await _dio.post('/session/create');
    return resp.data['sessionId'] as String;
  }

  Future<StatusResponse> getStatus(String sessionId) async {
    final resp = await _dio.get(
      '/session/status',
      options: Options(headers: {'Authorization': 'Bearer $sessionId'}),
    );
    return StatusResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<Chat>> fetchChats(String sessionId) async {
    final resp = await _dio.get(
      '/chats',
      options: Options(headers: {'Authorization': 'Bearer $sessionId'}),
    );
    return (resp.data as List)
        .map((e) => Chat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Message>> fetchMessages(String sessionId, String jid) async {
    final resp = await _dio.get(
      '/messages',
      queryParameters: {'jid': jid},
      options: Options(headers: {'Authorization': 'Bearer $sessionId'}),
    );
    return (resp.data as List)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> sendMessage(String sessionId, String jid, String text) async {
    final body = {'jid': jid, 'text': text};
    final resp = await _dio.post(
      '/message/send',
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $sessionId'}),
    );
    return resp.statusCode == 200;
  }
}

@immutable
class StatusResponse {
  final bool connected;
  final String? qr;

  const StatusResponse({required this.connected, this.qr});

  factory StatusResponse.fromJson(Map<String, dynamic> json) =>
      StatusResponse(
        connected: json['connected'] as bool,
        qr: json['qr'] as String?,
      );
}
