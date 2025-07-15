// @path: lib/providers/session_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Se cambió la importación relativa por una de paquete:
import 'package:wa_mi_flutter/api/api_service.dart';

enum SessionStatus { loading, awaitingScan, authenticated, error }

class SessionState {
  final SessionStatus status;
  final String? qr;
  final String? message;
  final String? sessionId;
  SessionState._({
    required this.status,
    this.qr,
    this.message,
    this.sessionId,
  });
  factory SessionState.loading() => SessionState._(status: SessionStatus.loading);
  factory SessionState.awaitingScan(String? qr, String id) =>
      SessionState._(status: SessionStatus.awaitingScan, qr: qr, sessionId: id);
  factory SessionState.authenticated(String id) =>
      SessionState._(status: SessionStatus.authenticated, sessionId: id);
  factory SessionState.error(String msg) =>
      SessionState._(status: SessionStatus.error, message: msg);
}

final apiProvider = Provider((ref) => ApiService());

class SessionController extends StateNotifier<SessionState> {
  final ApiService _api;
  Timer? _poll;
  SessionController(this._api) : super(SessionState.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('sessionId');
    if (stored != null) {
      final status = await _api.getStatus(stored);
      if (status.connected) {
        state = SessionState.authenticated(stored);
        return;
      }
    }
    start();
  }

  Future<void> start() async {
    state = SessionState.loading();
    try {
      final id = await _api.createSession();
      state = SessionState.awaitingScan(null, id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionId', id);
      _poll?.cancel();
      _poll = Timer.periodic(const Duration(seconds: 3), (_) async {
        final st = await _api.getStatus(id);
        if (st.connected) {
          _poll?.cancel();
          state = SessionState.authenticated(id);
        } else {
          state = SessionState.awaitingScan(st.qr, id);
        }
      });
    } catch (_) {
      state = SessionState.error('No se pudo crear sesión');
    }
  }

  Future<void> loginWithId(String id) async {
    final st = await _api.getStatus(id);
    if (st.connected) {
      _poll?.cancel();
      state = SessionState.authenticated(id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionId', id);
    } else {
      state = SessionState.error('ID inválido o desconectado');
    }
  }

  Future<void> logout() async {
    _poll?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
    state = SessionState.loading();
    start();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionController, SessionState>(
        (ref) => SessionController(ref.read(apiProvider)));