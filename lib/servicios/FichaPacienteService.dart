import 'dart:convert';
import 'package:calma/servicios/FichaPaciente.dart';
import 'package:http/http.dart' as http;
import 'package:calma/configuracion/AppConfig.dart';

class FichaPacienteService {

  /// Obtiene la ficha de un paciente por su ID
  Future<FichaPaciente?> getFichaPacienteById(int idPaciente) async {
    try {
      final url = Uri.parse(AppConfig.getFichaPacienteUrl(idPaciente));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Agregar headers de autenticación si es necesario
          // 'Authorization': 'Bearer $token',
        },
      );

      print('🔍 URL solicitada: $url');
      print('📡 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Datos de ficha recibidos: ${data.keys.toList()}');

        return FichaPaciente.fromJson(data);
      } else if (response.statusCode == 404) {
        print('❌ No se encontró ficha para el paciente ID: $idPaciente');
        return null;
      } else {
        print('❌ Error al obtener ficha: ${response.statusCode}');
        print('❌ Respuesta: ${response.body}');
        throw Exception('Error al cargar la ficha del paciente (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception al obtener ficha del paciente: $e');
      rethrow;
    }
  }

  /// Obtiene todas las fichas de un paciente (si hay múltiples)
  Future<List<FichaPaciente>> getFichasByPaciente(int idPaciente) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.fichaPacienteEndpoint}/paciente/$idPaciente');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔍 URL solicitada: $url');
      print('📡 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Fichas recibidas: ${data.length}');

        return data.map((json) => FichaPaciente.fromJson(json)).toList();
      } else if (response.statusCode == 404 || response.statusCode == 204) {
        print('❌ No se encontraron fichas para el paciente ID: $idPaciente');
        return [];
      } else {
        print('❌ Error al obtener fichas: ${response.statusCode}');
        throw Exception('Error al cargar las fichas del paciente (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception al obtener fichas del paciente: $e');
      rethrow;
    }
  }

  /// Crea una nueva ficha de paciente
  Future<FichaPaciente?> createFichaPaciente(FichaPaciente ficha) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.fichaPacienteEndpoint}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(ficha.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return FichaPaciente.fromJson(data);
      } else {
        throw Exception('Error al crear la ficha del paciente (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception al crear ficha del paciente: $e');
      rethrow;
    }
  }

  /// Actualiza una ficha de paciente existente
  Future<FichaPaciente?> updateFichaPaciente(int id, FichaPaciente ficha) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.fichaPacienteEndpoint}/$id');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(ficha.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return FichaPaciente.fromJson(data);
      } else {
        throw Exception('Error al actualizar la ficha del paciente (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception al actualizar ficha del paciente: $e');
      rethrow;
    }
  }

  /// Elimina una ficha de paciente
  Future<bool> deleteFichaPaciente(int id) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}${AppConfig.fichaPacienteEndpoint}/$id');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('❌ Exception al eliminar ficha del paciente: $e');
      rethrow;
    }
  }
}