import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calma/configuracion/AppConfig.dart';

class IAService {

  // Chatbot general - Preguntas sobre Calma
  Future<Map<String, dynamic>> preguntarChatbot({
    required String pregunta,
  }) async {
    try {
      final url = Uri.parse(AppConfig.chatbotPreguntarUrl);

      final body = {
        'pregunta': pregunta,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'respuesta': data['respuesta'] ?? 'No se pudo obtener respuesta',
        };
      } else {
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Obtener recomendaciones de cuidado
  Future<Map<String, dynamic>> obtenerRecomendacionesCuidado({
    required int idPaciente,
    String? pregunta,
  }) async {
    try {
      final url = Uri.parse(AppConfig.recomendacionesCuidadoUrl);

      final body = {
        'idPaciente': idPaciente,
        if (pregunta != null && pregunta.isNotEmpty) 'pregunta': pregunta,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'respuesta': data['respuesta'] ?? 'No se pudo obtener respuesta',
          'pacienteNombre': data['pacienteNombre'] ?? 'Paciente',
        };
      } else {
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Evaluación de riesgos
  Future<Map<String, dynamic>> evaluarRiesgos({
    required int idPaciente,
  }) async {
    try {
      final url = Uri.parse(AppConfig.evaluacionRiesgosUrl);

      final body = {
        'idPaciente': idPaciente,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'respuesta': data['respuesta'] ?? 'No se pudo obtener evaluación',
        };
      } else {
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Obtener publicaciones del contratante
  Future<List<dynamic>> obtenerPublicacionesContratante(int contratanteId) async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.getPublicacionesContratanteUrl(contratanteId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      } else {
        throw Exception('Error al cargar publicaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener recomendación de IA para aspirantes
  Future<Map<String, dynamic>> obtenerRecomendacionIA({
    required int idPublicacion,
    String? criterios,
  }) async {
    try {
      final body = {
        'idPublicacion': idPublicacion,
        if (criterios != null && criterios.trim().isNotEmpty)
          'criterios': criterios.trim(),
      };

      final response = await http.post(
        Uri.parse(AppConfig.recomendarAspiranteUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'respuesta': data['respuesta'] ?? 'No se pudo obtener recomendación',
          'totalCandidatos': data['totalCandidatos'] ?? 0,
          'tituloTrabajo': data['tituloTrabajo'] ?? 'Trabajo',
        };
      } else {
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Obtener estadísticas de candidatos
  Future<Map<String, dynamic>> obtenerEstadisticasCandidatos(int idPublicacion) async {
    try {
      final body = {
        'idPublicacion': idPublicacion,
      };

      final response = await http.post(
        Uri.parse(AppConfig.estadisticasCandidatosUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'totalCandidatos': data['totalCandidatos'] ?? 0,
          'candidatosConExperiencia': data['candidatosConExperiencia'] ?? 0,
          'candidatosDisponibles': data['candidatosDisponibles'] ?? 0,
          'promedioCalificaciones': data['promedioCalificaciones'] ?? '0.0',
          'porcentajeExperiencia': data['porcentajeExperiencia'] ?? 0,
          'porcentajeDisponibilidad': data['porcentajeDisponibilidad'] ?? 0,
          'candidatosSinExperiencia': data['candidatosSinExperiencia'] ?? 0,
          'candidatosNoDisponibles': data['candidatosNoDisponibles'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  // Validar conexión con el servidor
  Future<bool> validarConexion() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Método helper para manejar errores comunes
  Map<String, dynamic> _handleError(dynamic error, String operacion) {
    String mensaje;

    if (error.toString().contains('SocketException')) {
      mensaje = 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
    } else if (error.toString().contains('TimeoutException')) {
      mensaje = 'La operación tardó demasiado tiempo. Intenta nuevamente.';
    } else if (error.toString().contains('FormatException')) {
      mensaje = 'Error en el formato de datos recibidos del servidor.';
    } else {
      mensaje = 'Error inesperado en $operacion: ${error.toString()}';
    }

    return {
      'success': false,
      'error': mensaje,
    };
  }
}