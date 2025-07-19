import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;

class Notificaciones {
  final int? id;
  final String descripcion;
  final int? idContratante;
  final int? idAspirante;
  final int? idPostulacion;
  final bool leida;
  final DateTime fecha;

  Notificaciones({
    this.id,
    required this.descripcion,
    this.idContratante,
    this.idAspirante,
    this.idPostulacion,
    this.leida = false,
    required this.fecha,
  });

  factory Notificaciones.fromJson(Map<String, dynamic> json) {
    return Notificaciones(
      id: json['id'],
      descripcion: json['descripcion'],
      idContratante: json['contratante'] != null ? json['contratante']['idContratante'] : null,
      idAspirante: json['aspirante'] != null ? json['aspirante']['idAspirante'] : null,
      idPostulacion: json['postulacion'] != null ? json['postulacion']['id_postulacion'] : null,
      leida: json['leida'] ?? false,
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descripcion': descripcion,
      if (idContratante != null) 'contratante': {'idContratante': idContratante},
      if (idAspirante != null) 'aspirante': {'idAspirante': idAspirante},
      if (idPostulacion != null) 'postulacion': {'id_postulacion': idPostulacion},
      'leida': leida,
      'fecha': fecha.toIso8601String(),
    };
  }
}

class NotificacionesService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Notificaciones> crearNotificacion(Notificaciones notificacion) async {
    final url = Uri.parse('$baseUrl/api/notificaciones');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(notificacion.toJson()),
      );

      if (response.statusCode == 201) {
        return Notificaciones.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear notificación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Notificaciones>> obtenerNotificacionesContratante(int idContratante) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/contratante/$idContratante');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((json) => Notificaciones.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Marcar todas como leídas
  Future<void> marcarTodasLeidasContratante(int idContratante) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/contratante/marcar-leidas/$idContratante');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al marcar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Marcar una notificación como leída
  Future<void> marcarComoLeida(int idNotificacion) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/leida/$idNotificacion');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al marcar notificación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Notificaciones>> obtenerNotificacionesAspirante(int idAspirante) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/aspirante/$idAspirante');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((json) => Notificaciones.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 2. Obtener notificaciones no leídas del aspirante
  Future<List<Notificaciones>> obtenerNoLeidasAspirante(int idAspirante) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/aspirante/noleidas/$idAspirante');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((json) => Notificaciones.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar notificaciones no leídas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 3. Marcar todas como leídas para aspirante
  Future<void> marcarTodasLeidasAspirante(int idAspirante) async {
    final url = Uri.parse('$baseUrl/api/notificaciones/aspirante/marcar-leidas/$idAspirante');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al marcar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }


}