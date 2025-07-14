import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;

class EstadoPublicacionService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> actualizarPublicacion(
      int id, Map<String, dynamic> publicacionData) async {
    try {
      final url = Uri.parse('$baseUrl/api/publicacion_empleo/$id');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Si necesitas autenticación:
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode(publicacionData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Publicación no encontrada');
      } else {
        throw Exception('Error al actualizar la publicación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}