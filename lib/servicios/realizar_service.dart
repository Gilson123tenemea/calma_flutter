import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;

class RealizarService {
  Future<Map<String, dynamic>> postularAEmpleo(
      int idAspirante, int idPublicacion) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/realizar/postular?'
        'idAspirante=$idAspirante&idPublicacionEmpleo=$idPublicacion');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Ya te has postulado a esta oferta.',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al postular: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  Future<Map<String, dynamic>> getPostulacionesPorAspirante(int idAspirante) async {
    final url = Uri.parse(AppConfig.getPostulacionesPorAspiranteUrl(idAspirante));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else if (response.statusCode == 204) {
        return {
          'success': true,
          'data': [],
          'message': 'No hay postulaciones para este aspirante'
        };
      } else {
        return {
          'success': false,
          'message': 'Error al obtener postulaciones: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

}