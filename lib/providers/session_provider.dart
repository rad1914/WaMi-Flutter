// lib/providers/session_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';

enum SessionStateStatus { loading, awaitingScan, authenticated, error }

class SessionState {
  final SessionStateStatus status;
  final String? qr;
  final String? message;
  final String? sessionId;

  SessionState._({
    required this.status,
    this.qr,
    this.message,
    this.sessionId,
  });

  factory SessionState.loading() =>
      SessionState._(status: SessionStateStatus.loading);

  factory SessionState.awaitingScan(String? qr, String sessionId) =>
      SessionState._(
        status: SessionStateStatus.awaitingScan,
        qr: qr,
        sessionId: sessionId,
      );

  factory SessionState.authenticated(String sessionId) =>
      SessionState._(
        status: SessionStateStatus.authenticated,
        sessionId: sessionId,
      );

  factory SessionState.error(String message) =>
      SessionState._(status: SessionStateStatus.error, message: message);
}

class SessionController extends StateNotifier<SessionState> {
  final ApiService _api;
  Timer? _pollTimer;

  SessionController(this._api) : super(SessionState.loading()) {
    start();
  }

  Future<void> start() async {
    state = SessionState.loading();
    try {
      final id = await _api.createSession();
      state = SessionState.awaitingScan(null, id);
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        final status = await _api.getStatus(id);
        if (status.connected) {
          _pollTimer?.cancel();
          state = SessionState.authenticated(id);
        } else {
          state = SessionState.awaitingScan(status.qr, id);
        }
      });
    } catch (e) {
      state = SessionState.error('No se pudo crear sesión');
    }
  }

  Future<void> loginWithId(String id) async {
    try {
      final status = await _api.getStatus(id);
      if (status.connected) {
        _pollTimer?.cancel();
        state = SessionState.authenticated(id);
      } else {
        state = SessionState.error('ID inválido o desconectado');
      }
    } catch (e) {
      state = SessionState.error('Error al verificar ID');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final apiProvider = Provider((ref) => ApiService());

final sessionProvider =
    StateNotifierProvider<SessionController, SessionState>(
        (ref) => SessionController(ref.read(apiProvider)));
