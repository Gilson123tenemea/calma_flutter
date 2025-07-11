// lib/services/auth_service.dart

import 'dart:convert';
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

    if (response.statusCode == 200) {
      return {
        'success': true,
        'rol': responseData['rol'],
        'userId': responseData['usuarioId'],
        'specificId': responseData['rol'] == 'aspirante'
            ? responseData['aspiranteId']
            : responseData['contratanteId'],
      };
    } else {
      throw Exception(responseData['message'] ?? 'Error desconocido');
    }
  }
}
