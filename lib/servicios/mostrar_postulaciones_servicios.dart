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

  Future<bool> actualizarEstadoPostulacion({
    required int postulacionId,
    required int contratanteId,
    required int aspiranteId,
    required bool estado,
  }) async {
    try {
      // 1. Obtener los datos actuales de la postulación (si aún los necesitas)
      final responseGet = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/postulacion/listar/$postulacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (responseGet.statusCode != 200) {
        throw Exception('Error al obtener postulación: ${responseGet.statusCode}');
      }

      final postulacionActual = json.decode(responseGet.body);
      final empleoId = postulacionActual['postulacion_empleo']['id_postulacion_empleo'];

      // 2. Realizar la petición PUT con todos los IDs
      final responsePut = await http.put(
        Uri.parse(AppConfig.getActualizarPostulacionUrl(
            postulacionId,
            contratanteId,
            aspiranteId
        )),
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
    } catch (e) {
      print('Error en actualizarEstadoPostulacion: $e');
      rethrow;
    }
  }
}