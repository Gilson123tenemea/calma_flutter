import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;

class MostrarCV {
  Future<Map<String, dynamic>> obtenerCVPorAspirante(int aspiranteId) async {
    final url = AppConfig.getCvPorAspiranteUrl(aspiranteId);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener CV: ${response.body}');
    }
  }

  Future<void> descargarCertificado(int certificadoId) async {
    final url = AppConfig.getDescargarCertificadoUrl(certificadoId);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Aquí puedes manejar la descarga del archivo
      // Puedes usar un paquete como dio o path_provider para guardar el archivo
      print('Certificado descargado: ${response.body}');
    } else {
      throw Exception('Error al descargar certificado: ${response.body}');
    }
  }

  Future<void> descargarRecomendacion(int recomendacionId) async {
    final url = AppConfig.getDescargarRecomendacionUrl(recomendacionId);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Manejo de la descarga
      print('Recomendación descargada: ${response.body}');
    } else {
      throw Exception('Error al descargar recomendación: ${response.body}');
    }
  }
}