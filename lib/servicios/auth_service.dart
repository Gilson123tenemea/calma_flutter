import 'dart:convert';
import 'package:calma/servicios/session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../configuracion/AppConfig.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final uri = Uri.parse(AppConfig.loginUrl);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'correo': correo,
        'contrasena': contrasena,
      },
    );

    final responseData = jsonDecode(response.body);
    debugPrint('Respuesta CRUDA del servidor: ${response.body}');

    if (response.statusCode == 200) {
      final rol = responseData['rol']?.toString()?.toLowerCase() ?? '';
      final usuarioId = _parseInt(responseData['usuarioId']);

      final specificId = rol == 'aspirante'
          ? _parseInt(responseData['aspiranteId'])
          : _parseInt(responseData['contratanteId']);

      await SessionService().saveSession(
        userId: usuarioId,
        specificId: specificId,
        rol: rol,
      );

      return {
        'success': true,
        'rol': rol,
        'userId': usuarioId,
        'specificId': specificId,
      };
    } else {
      throw Exception(responseData['message'] ?? 'Error desconocido');
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}