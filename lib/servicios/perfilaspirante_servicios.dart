import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calma/configuracion/AppConfig.dart';

class PerfilAspiranteService {
  Future<Map<String, dynamic>> obtenerPerfilAspirante(int idAspirante) async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.getPerfilAspiranteUrl(idAspirante)),
        headers: {
          'Content-Type': 'application/json',

        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);


        if (data.containsKey('aspirante') && data['aspirante'] != null) {
          return data;
        } else {
          throw Exception('La estructura de la respuesta no es la esperada');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Aspirante no encontrado');
      } else {
        throw Exception('Error al obtener el perfil del aspirante: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}