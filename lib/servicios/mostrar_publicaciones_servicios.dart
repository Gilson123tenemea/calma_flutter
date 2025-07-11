
import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;

class PublicacionService {
  static Future<List<dynamic>> obtenerPublicacionesPorContratante(int idContratante) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/generar/contratante/$idContratante'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar las publicaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<dynamic>> obtenerTodasLasPublicaciones() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/generar/publicaciones'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar las publicaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}