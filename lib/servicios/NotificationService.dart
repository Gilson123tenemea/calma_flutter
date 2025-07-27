import 'dart:convert';
import 'package:calma/servicios/NotificationActionsService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/servicios/session_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SessionService _sessionService = SessionService();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _initNotifications();
  }

  Future<void> initialize() async {
    // Configurar canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'canal_notificaciones',
      'Notificaciones CALMA',
      description: 'Canal para notificaciones importantes',
      importance: Importance.max,
      playSound: true,
    );

    // Crear el canal
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Configurar handlers
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Configurar inicialización para background
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    // Solo se ejecuta cuando la app está en primer plano
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'canal_notificaciones',
      'Notificaciones CALMA',
      channelDescription: 'Canal para notificaciones importantes',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Nueva notificación',
      message.notification?.body,
      NotificationDetails(android: androidPlatformChannelSpecifics),
      payload: json.encode(message.data),
    );
  }

  Future<void> _initNotifications() async {
    // 1. Configurar notificaciones locales
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationClicked(response);
      },
    );

    // 2. Configurar FCM
    await _firebaseMessaging.requestPermission();
    _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);

    // 3. Manejar notificaciones en diferentes estados
    FirebaseMessaging.onMessage.listen(showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'canal_notificaciones',
      'Notificaciones CALMA',
      channelDescription: 'Canal para notificaciones de CALMA',
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFF0A2647),
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      notification?.title ?? 'Nueva notificación',
      notification?.body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }


  void _onNotificationClicked(NotificationResponse response) async {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      debugPrint("Notificación clickeada: $data");

      // Procesar acción específica si existe
      if (response.actionId != null) {
        await NotificationActionsService.procesarAccionNotificacion(response.actionId!, data);
        return;
      }

      // Manejar diferentes tipos de notificaciones
      final String tipo = data['tipo'] ?? '';

      switch (tipo) {
        case 'notificacion_interna':
          debugPrint("🔔 Navegando a notificaciones internas");
          // Marcar como leída automáticamente al hacer clic
          final notificacionId = data['notificacion_id'];
          if (notificacionId != null) {
            await NotificationActionsService.marcarNotificacionComoLeida(
                int.parse(notificacionId.toString())
            );
          }
          _navegarANotificaciones(data);
          break;
        case 'resumen_no_leidas':
          debugPrint("📱 Navegando a resumen de no leídas");
          _navegarANotificaciones(data);
          break;
        default:
          debugPrint("🔄 Notificación genérica recibida");
          break;
      }
    }
  }
  void _navegarANotificaciones(Map<String, dynamic> data) {
    // Aquí puedes implementar la navegación específica
    // Por ejemplo, usando un NavigatorKey global o un sistema de eventos
    debugPrint("📍 Datos para navegación: $data");

    // Ejemplo de cómo podrías manejar la navegación:
    // if (data['usuario_tipo'] == 'aspirante') {
    //   // Navegar a pantalla de notificaciones de aspirante
    // } else if (data['usuario_tipo'] == 'contratante') {
    //   // Navegar a pantalla de notificaciones de contratante
    // }
  }
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint("App abierta desde notificación: ${message.data}");
    _onNotificationClicked(NotificationResponse(
      payload: json.encode(message.data),
      actionId: null,
      input: null,
      notificationResponseType: NotificationResponseType.selectedNotification,
    ));
  }

  Future<bool> registerTokenForCurrentUser() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('Token FCM obtenido: $token');
        return await _registerToken(token);
      }
      return false;
    } catch (e) {
      debugPrint('Error registrando token: $e');
      return false;
    }
  }

  Future<bool> _registerToken(String token) async {
    try {
      final session = await _sessionService.getSession();
      if (session == null) return false;

      final response = await http.post(
        Uri.parse(AppConfig.registrarDispositivoUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': token,
          'plataforma': _getPlatform(),
          if (session['rol'] == 'aspirante') 'aspiranteId': session['specificId'].toString(),
          if (session['rol'] == 'contratante') 'contratanteId': session['specificId'].toString(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error en _registerToken: $e');
      return false;
    }
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    debugPrint('Token refrescado: $newToken');
    await _registerToken(newToken);
  }

  String _getPlatform() {
    return defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';
  }
}