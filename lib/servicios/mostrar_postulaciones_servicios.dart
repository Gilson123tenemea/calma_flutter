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

      if (responsePut.statusCode == 200) {
        final responseBody = json.decode(responsePut.body);
        if (responseBody['success'] != true) {
          throw Exception('Error en la respuesta del servidor');
        }

        // 3. Enviar notificación
        final mensaje = estado
            ? '¡Felicidades! Tu postulación para "$tituloPublicacion" ha sido aceptada.'
            : 'Lamentamos informarte que tu postulación para "$tituloPublicacion" no ha sido aceptada.';

        print('Preparando notificación: $mensaje');

        final notificacion = Notificaciones(
          descripcion: mensaje,
          idAspirante: aspiranteId,
          idPostulacion: postulacionId,
          fecha: DateTime.now().toUtc(),
        );

        print('Notificación a enviar: ${notificacion.toJson()}');

        try {
          await _notificacionesService.crearNotificacion(notificacion);
          print('Notificación enviada con éxito');
          return true;
        } catch (e) {
          print('Error al enviar notificación: $e');
          throw Exception('Postulación actualizada pero falló la notificación');
        }
      } else {
        throw Exception('Error al actualizar postulación: ${responsePut.statusCode}');
      }
    } catch (e) {
      print('Error en actualizarEstadoPostulacion: $e');
      rethrow;
    }


  }
}