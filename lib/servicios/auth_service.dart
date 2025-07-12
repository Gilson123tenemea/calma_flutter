import 'dart:convert';
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
      // Extracción segura de datos con verificación de null
      final rol = responseData['rol']?.toString()?.toLowerCase() ?? '';
      final usuarioId = _parseInt(responseData['usuarioId']);

      // Determinar el ID específico basado en el rol
      final specificId = rol == 'aspirante'
          ? _parseInt(responseData['aspiranteId'])
          : _parseInt(responseData['contratanteId']);

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

  // Función helper para parsear enteros de forma segura
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}