import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuracion/AppConfig.dart';

class PostulacionService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<List<dynamic>> getRealizacionesPorContratante(int idContratante) async {
    final url = '$_baseUrl/api/postulacion/$idContratante/realizaciones';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<dynamic>.from(data);
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Error al obtener las realizaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> actualizarEstadoPostulacion(int postulacionId, bool nuevoEstado) async {
    final url = AppConfig.getActualizarPostulacionUrl(postulacionId);

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'estado': nuevoEstado,
          'postulacion_empleo': null // No actualizamos esta información
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al actualizar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> aceptarPostulacion(int postulacionId) async {
    return await actualizarEstadoPostulacion(postulacionId, true);
  }

  Future<bool> rechazarPostulacion(int postulacionId) async {
    return await actualizarEstadoPostulacion(postulacionId, false);
  }
}