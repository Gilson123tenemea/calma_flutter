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

        return {'success': true, 'rol': rol, 'userId': usuarioId, 'specificId': specificId};
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      rethrow;
    }
  }

  static Future<void> _registerTokenDirectly(
      String token, String rol, int specificId, int userId
      ) async {
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
          await http.delete(
            Uri.parse('${AppConfig.baseUrl}/api/dispositivos/$fcmToken'),
          );
        } catch (e) {
          debugPrint('Error eliminando token FCM: $e');
        }
      }

      // Limpiar sesión local
      await sessionService.clearSession();

      // Opcional: eliminar token de FCM
      await FirebaseMessaging.instance.deleteToken();
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