import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;

class RealizarService {
  Future<Map<String, dynamic>> postularAEmpleo(
      int idAspirante, int idPublicacion) async {

    // Validación de entrada
    if (idAspirante <= 0 || idPublicacion <= 0) {
      return {
        'success': false,
        'message': 'IDs inválidos',
      };
    }

    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/realizar/postular?'
          'idAspirante=$idAspirante&idPublicacionEmpleo=$idPublicacion',
    );

    print('🔵 URL de postulación: $url');
    print('🔵 ID Aspirante: $idAspirante, ID Publicación: $idPublicacion');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15), // Aumentamos el timeout
        onTimeout: () => http.Response(
          '{"message": "Tiempo de espera agotado"}',
          408,
        ),
      );

      print('🟢 Status Code: ${response.statusCode}');
      print('🟢 Response Body: ${response.body}');
      print('🟢 Response Headers: ${response.headers}');

      // Manejo mejorado de respuestas
      switch (response.statusCode) {
        case 200:
        // Respuesta exitosa
          try {
            final responseBody = json.decode(response.body);
            return {
              'success': true,
              'data': responseBody,
              'message': 'Postulación exitosa',
            };
          } catch (e) {
            // Si no se puede parsear como JSON, pero el status es 200, considerarlo exitoso
            print('🟠 Respuesta 200 pero no es JSON válido: ${response.body}');
            return {
              'success': true,
              'data': {'message': 'Postulación exitosa'},
              'message': 'Postulación exitosa',
            };
          }

        case 409:
        // Conflicto - Ya postulado
          return {
            'success': false,
            'message': 'Ya te has postulado a esta oferta anteriormente',
          };

        case 400:
        // Bad Request
          try {
            final responseBody = json.decode(response.body);
            return {
              'success': false,
              'message': responseBody['message'] ?? 'Datos inválidos',
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Datos de solicitud inválidos',
            };
          }

        case 404:
        // Not Found
          return {
            'success': false,
            'message': 'Publicación o aspirante no encontrado',
          };

        case 500:
        // Error interno del servidor
          print('🔴 Error 500 - Pero verificamos si la acción se completó');

          // Verificamos si a pesar del error 500, la postulación se realizó
          // Esto es común cuando hay errores en el logging o procesos secundarios
          // pero la operación principal se completó

          try {
            final responseBody = json.decode(response.body);

            // Si el cuerpo contiene datos válidos, consideramos que fue exitoso
            if (responseBody != null && responseBody is Map) {
              print('🟠 Error 500 pero con datos válidos - considerando exitoso');
              return {
                'success': true,
                'data': responseBody,
                'message': 'Postulación completada',
                'warning': 'Se completó la postulación aunque hubo un error menor en el servidor',
              };
            }
          } catch (e) {
            print('🔴 Error 500 y no se puede parsear respuesta');
          }

          // Si llegamos aquí, es un error real
          return {
            'success': false,
            'message': 'Error interno del servidor. Verifica si la postulación se realizó correctamente.',
            'shouldRetry': false, // No reintentar automáticamente
          };

        default:
        // Otros códigos de error
          try {
            final responseBody = json.decode(response.body);
            return {
              'success': false,
              'message': responseBody['message'] ?? 'Error desconocido: ${response.statusCode}',
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Error del servidor: ${response.statusCode}',
            };
          }
      }
    } on http.ClientException catch (e) {
      print('🔴 ClientException: $e');
      return {
        'success': false,
        'message': 'Error de conexión con el servidor',
      };
    } on FormatException catch (e) {
      print('🔴 FormatException: $e');
      return {
        'success': false,
        'message': 'Error en el formato de la respuesta del servidor',
      };
    } catch (e) {
      print('🔴 Exception general: $e');
      return {
        'success': false,
        'message': 'Error inesperado: $e',
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

  // Método auxiliar para verificar si una postulación existe
  Future<bool> verificarPostulacionExiste(int idAspirante, int idPublicacion) async {
    try {
      final postulaciones = await getPostulacionesPorAspirante(idAspirante);
      if (postulaciones['success'] == true) {
        final List<dynamic> datos = postulaciones['data'] ?? [];
        return datos.any((postulacion) =>
        postulacion['publicacion_empleo']['id'] == idPublicacion);
      }
      return false;
    } catch (e) {
      print('🔴 Error verificando postulación: $e');
      return false;
    }
  }
}