import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;

class Notificaciones {
  final String mensaje;
  final int idContratante;

  Notificaciones({
    required this.mensaje,
    required this.idContratante,
  });
}

class NotificacionesService {
  // Obtener todas las notificaciones de un aspirante
  Future<List<dynamic>> obtenerNotificacionesAspirante(int aspiranteId) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones/aspirante/$aspiranteId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar las notificaciones');
    }
  }

  // Obtener todas las notificaciones de un contratante
  Future<List<dynamic>> obtenerNotificacionesContratante(int contratanteId) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones/contratante/$contratanteId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar las notificaciones del contratante');
    }
  }

  // Obtener notificaciones no leídas de un aspirante
  Future<List<dynamic>> obtenerNoLeidasAspirante(int aspiranteId) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones/aspirante/noleidas/$aspiranteId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar las notificaciones no leídas');
    }
  }

  // Obtener notificaciones no leídas de un contratante
  Future<List<dynamic>> obtenerNoLeidasContratante(int contratanteId) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones/contratante/noleidas/$contratanteId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar las notificaciones no leídas del contratante');
    }
  }

  // Marcar notificación como leída
  Future<void> marcarLeida(int notificacionId) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones/leida/$notificacionId';

    final response = await http.put(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Error al marcar la notificación como leída');
    }
  }

  // Marcar todas las notificaciones como leídas para un aspirante
  Future<void> marcarTodasLeidasAspirante(int aspiranteId) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones/aspirante/marcar-leidas/$aspiranteId';

    final response = await http.put(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Error al marcar todas las notificaciones como leídas');
    }
  }

  // Marcar todas las notificaciones como leídas para un contratante
  Future<void> marcarTodasLeidasContratante(int contratanteId) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones/contratante/marcar-leidas/$contratanteId';

    final response = await http.put(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Error al marcar todas las notificaciones del contratante como leídas');
    }
  }

  Future<void> crear(Notificaciones notificacion) async {
    final url = '${AppConfig.baseUrl}/api/notificaciones';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'mensaje': notificacion.mensaje,
        'idContratante': notificacion.idContratante,
        // Agrega otros campos si es necesario
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear la notificación');
    }
  }
}