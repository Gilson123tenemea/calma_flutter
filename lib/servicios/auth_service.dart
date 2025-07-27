import 'dart:convert';
import 'dart:io';
import 'package:calma/servicios/NotificationService.dart';
import 'package:calma/servicios/session_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../configuracion/AppConfig.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.loginUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'correo': correo, 'contrasena': contrasena},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rol = data['rol']?.toString()?.toLowerCase() ?? '';
        final usuarioId = _parseInt(data['usuarioId']);
        final specificId = rol == 'aspirante'
            ? _parseInt(data['aspiranteId'])
            : _parseInt(data['contratanteId']);

        // Guardar sesión y token
        final token = await FirebaseMessaging.instance.getToken();
        await SessionService().saveSession(
          userId: usuarioId,
          specificId: specificId,
          rol: rol,
          fcmToken: token,
        );

        // Registrar token en backend
        if (token != null) {
          final success = await NotificationService().registerTokenForCurrentUser();
          if (!success) {
            await _registerTokenDirectly(token, rol, specificId, usuarioId);
          }
        }

        // NUEVO: Solicitar notificaciones pendientes después del login exitoso
        await _solicitarNotificacionesPendientes(rol, specificId);

        return {'success': true, 'rol': rol, 'userId': usuarioId, 'specificId': specificId};
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      rethrow;
    }
  }

  /// Solicita al backend que envíe las notificaciones pendientes
  static Future<void> _solicitarNotificacionesPendientes(String rol, int specificId) async {
    try {
      debugPrint('🔔 Solicitando notificaciones pendientes para $rol ID: $specificId');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/login/enviar-notificaciones-pendientes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rol': rol,
          'specificId': specificId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('✅ Notificaciones pendientes solicitadas: ${responseData['message']}');
      } else {
        debugPrint('⚠️ Error al solicitar notificaciones pendientes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error solicitando notificaciones pendientes: $e');
      // No lanzamos el error para no interrumpir el flujo de login
    }
  }

  static Future<void> _registerTokenDirectly(
      String token, String rol, int specificId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.registrarDispositivoUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': token,
          'plataforma': Platform.isAndroid ? 'android' : 'ios',
          if (rol == 'aspirante') 'aspiranteId': specificId.toString(),
          if (rol == 'contratante') 'contratanteId': specificId.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error registrando token: ${response.body}');
      }
      debugPrint('Token registrado exitosamente en el backend');
    } catch (e) {
      debugPrint('Error en _registerTokenDirectly: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      final sessionService = SessionService();
      final session = await sessionService.getSession();
      final fcmToken = session['fcmToken'] as String?;

      // Eliminar registro del backend si existe token
      if (fcmToken != null) {
        try {
          final response = await http.delete(
            Uri.parse('${AppConfig.baseUrl}/api/dispositivos/$fcmToken'),
          );
          if (response.statusCode == 204) {
            debugPrint('Token eliminado del servidor exitosamente');
          }
        } catch (e) {
          debugPrint('Error eliminando token FCM del servidor: $e');
        }
      }

      // Limpiar sesión local
      await sessionService.clearSession();

      // Opcional: eliminar token de FCM
      await FirebaseMessaging.instance.deleteToken();
      debugPrint('Logout completado exitosamente');
    } catch (e) {
      debugPrint('Error durante logout: $e');
      rethrow;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}