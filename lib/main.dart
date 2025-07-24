import 'package:flutter/material.dart';
import 'package:calma/controlador/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configuración de notificaciones
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Solicitar permisos (iOS/macOS)
  await FirebaseMessaging.instance.requestPermission();

  // Escuchar mensajes en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensaje en primer plano: ${message.notification?.title}');
  });

  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensaje en segundo plano: ${message.notification?.title}');
}

Future<void> _setupFCM() async {
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print('FCM Token: $token');
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('Nuevo FCM Token: $newToken');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CALMA - Cuidado Geriátrico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1E3A8A)),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}