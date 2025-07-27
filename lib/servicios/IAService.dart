import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calma/configuracion/AppConfig.dart';


class IAService {
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
}