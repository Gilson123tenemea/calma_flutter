import 'dart:convert';
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

  Future<void> initializeNotifications() async {
    // Configurar el canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'canal_notificaciones',
      'Notificaciones CALMA',
      description: 'Canal para notificaciones importantes',
      importance: Importance.max,
      playSound: true,
    );

    // Crear el canal (solo necesario para Android 8.0+)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Configurar cómo manejar las notificaciones entrantes
    FirebaseMessaging.onMessage.listen(showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    // Configurar detalles para Android
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'canal_notificaciones',
      'Notificaciones CALMA',
      channelDescription: 'Canal para notificaciones importantes',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: const Color(0xFF0A2647),
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Mostrar la notificación
    await _localNotifications.show(
      message.hashCode,
      notification?.title ?? 'Nueva notificación',
      notification?.body,
      platformChannelSpecifics,
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

  void _onNotificationClicked(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      debugPrint("Notificación clickeada: $data");
      // Aquí puedes manejar la navegación
    }
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