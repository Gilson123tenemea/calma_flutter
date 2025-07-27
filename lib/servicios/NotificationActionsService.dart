import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/servicios/session_service.dart';

class NotificationActionsService {

  /// Marcar una notificación específica como leída
  static Future<bool> marcarNotificacionComoLeida(int notificacionId) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/notificaciones/leida/$notificacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Notificación $notificacionId marcada como leída');
        return true;
      } else {
        print('❌ Error marcando notificación como leída: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión marcando notificación: $e');
      return false;
    }
  }

  /// Marcar todas las notificaciones como leídas para el usuario actual
  static Future<bool> marcarTodasComoLeidas() async {
    try {
      final session = await SessionService().getSession();
      final rol = session['rol'] as String?;
      final specificId = session['specificId'] as int?;

      if (rol == null || specificId == null || specificId == 0) {
        print('❌ No hay sesión válida para marcar notificaciones');
        return false;
      }

      String endpoint;
      if (rol == 'aspirante') {
        endpoint = '${AppConfig.baseUrl}/api/notificaciones/aspirante/marcar-leidas/$specificId';
      } else if (rol == 'contratante') {
        endpoint = '${AppConfig.baseUrl}/api/notificaciones/contratante/marcar-leidas/$specificId';
      } else {
        print('❌ Rol no válido: $rol');
        return false;
      }

      final response = await http.put(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Todas las notificaciones marcadas como leídas para $rol $specificId');
        return true;
      } else {
        print('❌ Error marcando todas las notificaciones: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión marcando todas las notificaciones: $e');
      return false;
    }
  }

  /// Obtener el conteo de notificaciones no leídas
  static Future<int> obtenerConteoNoLeidas() async {
    try {
      final session = await SessionService().getSession();
      final rol = session['rol'] as String?;
      final specificId = session['specificId'] as int?;

      if (rol == null || specificId == null || specificId == 0) {
        return 0;
      }

      String endpoint;
      if (rol == 'aspirante') {
        endpoint = '${AppConfig.baseUrl}/api/notificaciones/aspirante/noleidas/$specificId';
      } else if (rol == 'contratante') {
        endpoint = '${AppConfig.baseUrl}/api/notificaciones/contratante/noleidas/$specificId';
      } else {
        return 0;
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificaciones = jsonDecode(response.body);
        return notificaciones.length;
      } else {
        print('❌ Error obteniendo conteo de no leídas: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('❌ Error de conexión obteniendo conteo: $e');
      return 0;
    }
  }

  /// Procesar acción de notificación desde la UI de notificación push
  static Future<void> procesarAccionNotificacion(String accion, Map<String, dynamic> data) async {
    try {
      print('🔄 Procesando acción de notificación: $accion');
      print('📋 Datos: $data');

      switch (accion) {
        case 'ver_notificacion':
          await _manejarVerNotificacion(data);
          break;
        case 'marcar_leida':
          await _manejarMarcarLeida(data);
          break;
        case 'ver_todas':
          await _manejarVerTodas(data);
          break;
        default:
          print('⚠️ Acción no reconocida: $accion');
          break;
      }
    } catch (e) {
      print('❌ Error procesando acción de notificación: $e');
    }
  }

  static Future<void> _manejarVerNotificacion(Map<String, dynamic> data) async {
    final notificacionId = data['notificacion_id'];
    if (notificacionId != null) {
      await marcarNotificacionComoLeida(int.parse(notificacionId.toString()));
    }
    // Aquí puedes navegar a la pantalla específica de la notificación
    print('📱 Navegando a ver notificación específica');
  }

  static Future<void> _manejarMarcarLeida(Map<String, dynamic> data) async {
    final notificacionId = data['notificacion_id'];
    if (notificacionId != null) {
      await marcarNotificacionComoLeida(int.parse(notificacionId.toString()));
      print('✅ Notificación marcada como leída desde acción push');
    }
  }

  static Future<void> _manejarVerTodas(Map<String, dynamic> data) async {
    // Navegar a la pantalla de todas las notificaciones
    print('📱 Navegando a ver todas las notificaciones');
    // Aquí implementas la navegación específica
  }
}