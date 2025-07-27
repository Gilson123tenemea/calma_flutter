import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/servicios/notificaciones_servicios.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostulacionService {
  final NotificacionesService _notificacionesService = NotificacionesService();

  Future<List<dynamic>> getPostulacionesPorContratante(int idContratante) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/postulacion/$idContratante/realizaciones'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> postulaciones = json.decode(response.body);

      // Ordenar las postulaciones por fecha de creación (más recientes primero)
      postulaciones.sort((a, b) {
        try {
          // Intentar ordenar por fecha de postulación si existe
          final fechaA = DateTime.tryParse(a['postulacion']['fecha_postulacion']?.toString() ?? '');
          final fechaB = DateTime.tryParse(b['postulacion']['fecha_postulacion']?.toString() ?? '');

          if (fechaA != null && fechaB != null) {
            return fechaB.compareTo(fechaA); // Más recientes primero
          }

          // Si no hay fecha, ordenar por ID (IDs más altos primero = más recientes)
          final idA = a['postulacion']['id_postulacion'] ?? 0;
          final idB = b['postulacion']['id_postulacion'] ?? 0;
          return idB.compareTo(idA);
        } catch (e) {
          print('Error al ordenar postulaciones: $e');
          return 0;
        }
      });

      return postulaciones;
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Error al cargar postulaciones: ${response.statusCode}');
    }
  }

  // AQUÍ ESTÁ LA CORRECCIÓN PRINCIPAL DEL ERROR
  Future<bool> actualizarEstadoPostulacion({
    required int postulacionId,
    required int contratanteId,
    required int aspiranteId,
    required bool estado,
    required String tituloPublicacion,
  }) async {
    try {
      print('Iniciando actualización de postulación $postulacionId');

      // 1. Obtener datos actuales
      final responseGet = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/postulacion/listar/$postulacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (responseGet.statusCode != 200) {
        print('Error al obtener postulación: ${responseGet.body}');
        throw Exception('Error al obtener postulación');
      }

      final postulacionActual = json.decode(responseGet.body);
      final empleoId = postulacionActual['postulacion_empleo']['id_postulacion_empleo'];

      // 2. Actualizar estado
      final responsePut = await http.put(
        Uri.parse(AppConfig.getActualizarPostulacionUrl(
            postulacionId, contratanteId, aspiranteId)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'estado': estado,
          'postulacion_empleo': {'id_postulacion_empleo': empleoId}
        }),
      );

      print('Respuesta actualización: ${responsePut.statusCode} - ${responsePut.body}');

      // CORRECCIÓN: El backend devuelve texto plano, no JSON
      if (responsePut.statusCode == 200) {
        final responseBody = responsePut.body;
        print('Respuesta del servidor: $responseBody');

        // Verificar que la respuesta contenga el mensaje de éxito
        if (responseBody.contains('Postulación actualizada')) {
          print('✅ Postulación actualizada correctamente en el servidor');
          return true;
        } else {
          throw Exception('Respuesta inesperada del servidor: $responseBody');
        }
      } else {
        throw Exception('Error al actualizar postulación: ${responsePut.statusCode}');
      }
    } catch (e) {
      print('❌ Error en actualizarEstadoPostulacion: $e');
      rethrow;
    }
  }
}