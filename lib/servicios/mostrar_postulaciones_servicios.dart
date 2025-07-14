import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostulacionService {
  Future<List<dynamic>> getPostulacionesPorContratante(int idContratante) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/postulacion/$idContratante/realizaciones'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al cargar postulaciones: ${response.statusCode}');
    }
  }

  Future<bool> actualizarEstadoPostulacion(int postulacionId, bool estado) async {
    final responseGet = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/postulacion/listar/$postulacionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (responseGet.statusCode != 200) {
      throw Exception('Error al obtener postulación: ${responseGet.statusCode}');
    }

    final postulacionActual = json.decode(responseGet.body);
    final empleoId = postulacionActual['postulacion_empleo']['id_postulacion_empleo'];

    final responsePut = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/postulacion/actualizar/$postulacionId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'estado': estado,
        'postulacion_empleo': {
          'id_postulacion_empleo': empleoId
        }
      }),
    );

    if (responsePut.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al actualizar postulación: ${responsePut.statusCode}');
    }
  }
}