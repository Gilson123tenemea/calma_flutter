import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/servicios/session_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SessionService _sessionService = SessionService();

  Future<void> initialize() async {
    // 1. Solicitar permisos (iOS/macOS)
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Permisos de notificaciones: ${settings.authorizationStatus}');

    // 2. Configurar manejadores de notificaciones
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);

    // 3. Obtener y registrar token inicial
    await handleTokenRegistration();

    // 4. Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen(handleTokenRegistration);
  }

  Future<void> handleTokenRegistration([String? newToken]) async {


    try {
      final token = newToken ?? await _firebaseMessaging.getToken();
      if (token == null) return;

      debugPrint('Token FCM obtenido: $token');

      final session = await _sessionService.getSession();
      final userId = session['userId'];
      if (userId == 0) {
        debugPrint('No hay usuario logueado, token no se enviará al backend');
        return;
      }

      await _registerTokenWithBackend(token, userId);
    } catch (e) {
      debugPrint('Error en manejo de token: $e');
    }
  }


  Future<void> _registerTokenWithBackend(String token, int userId) async {
    try {
      final platform = _getPlatform();
      final url = Uri.parse('${AppConfig.baseUrl}/api/dispositivos');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(),
        },
        body: jsonEncode({
          'token': token,
          'plataforma': platform,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Token registrado exitosamente en el backend');
      } else {
        debugPrint('Error registrando token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Excepción al registrar token: $e');
    }
  }

  String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'unknown';
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Notificación recibida en primer plano:');
    debugPrint('Título: ${message.notification?.title}');
    debugPrint('Cuerpo: ${message.notification?.body}');
    debugPrint('Datos: ${message.data}');

    // Aquí puedes mostrar una notificación local o actualizar la UI
  }

  void _handleOpenedApp(RemoteMessage message) {
    debugPrint('App abierta desde notificación:');
    debugPrint('Datos: ${message.data}');

    // Navegar a la pantalla correspondiente basada en message.data
  }
}