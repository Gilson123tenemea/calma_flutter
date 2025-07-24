import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/servicios/session_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SessionService _sessionService = SessionService();

  Future<void> initialize() async {
    try {
      // Configuración inicial
      await _firebaseMessaging.requestPermission();
      _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);

      // Registrar token si hay sesión
      if (await _sessionService.isLoggedIn()) {
        await registerTokenForCurrentUser();
      }
    } catch (e) {
      debugPrint('Error inicializando NotificationService: $e');
    }
  }

  Future<bool> registerTokenForCurrentUser() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('Token FCM obtenido: $token');
        return await _registerToken(token);
      }
      return false;
    } catch (e) {
      debugPrint('Error registrando token: $e');
      return false;
    }
  }

  Future<bool> _registerToken(String token) async {
    try {
      final session = await _sessionService.getSession();
      if (session == null) return false;

      final response = await http.post(
        Uri.parse(AppConfig.registrarDispositivoUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': token,
          'plataforma': _getPlatform(),
          if (session['rol'] == 'aspirante') 'aspiranteId': session['specificId'].toString(),
          if (session['rol'] == 'contratante') 'contratanteId': session['specificId'].toString(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error en _registerToken: $e');
      return false;
    }
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    debugPrint('Token refrescado: $newToken');
    await _registerToken(newToken);
  }

  String _getPlatform() {
    return defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';
  }
}