import 'package:calma/servicios/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:calma/controlador/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Global navigator key para navegación desde notificaciones
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Configurar el handler para background antes de runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configurar notificaciones locales
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Configurar manejo de notificaciones cuando la app está terminada
  _handleInitialMessage();

  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("🔔 Notificación recibida en background:");
  print("   Título: ${message.notification?.title}");
  print("   Mensaje: ${message.notification?.body}");
  print("   Datos: ${message.data}");

  // Mostrar notificación local
  await NotificationService().showForegroundNotification(message);
}

/// Maneja notificaciones cuando la app se abre desde una notificación
void _handleInitialMessage() {
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print("🚀 App abierta desde notificación: ${message.data}");
      _handleMessageNavigation(message.data);
    }
  });
}

/// Maneja la navegación basada en los datos de la notificación
void _handleMessageNavigation(Map<String, dynamic> data) {
  // Esperar un poco para que la app se inicialice completamente
  Future.delayed(const Duration(seconds: 1), () {
    final String tipo = data['tipo'] ?? '';
    final String usuarioTipo = data['usuario_tipo'] ?? '';

    print("📱 Navegando por notificación - Tipo: $tipo, Usuario: $usuarioTipo");

    // Aquí puedes implementar la navegación específica
    switch (tipo) {
      case 'notificacion_interna':
      case 'resumen_no_leidas':
        _navegarANotificaciones(usuarioTipo, data);
        break;
      default:
        print("🔄 Tipo de notificación no reconocido: $tipo");
        break;
    }
  });
}

void _navegarANotificaciones(String usuarioTipo, Map<String, dynamic> data) {
  if (navigatorKey.currentState != null) {
    // Ejemplo de navegación - ajusta según tu estructura de rutas
    if (usuarioTipo == 'aspirante') {
      // Navegar a notificaciones de aspirante
      print("📍 Navegando a notificaciones de aspirante");
      // navigatorKey.currentState!.pushNamed('/aspirante/notificaciones');
    } else if (usuarioTipo == 'contratante') {
      // Navegar a notificaciones de contratante
      print("📍 Navegando a notificaciones de contratante");
      // navigatorKey.currentState!.pushNamed('/contratante/notificaciones');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    _configureFirebaseMessaging();
  }

  void _configureFirebaseMessaging() {
    // Manejar notificaciones cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Notificación recibida en primer plano:");
      print("   Título: ${message.notification?.title}");
      print("   Mensaje: ${message.notification?.body}");
      print("   Datos: ${message.data}");

      // La notificación se muestra automáticamente gracias al listener configurado
    });

    // Manejar cuando se toca una notificación y la app se abre
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📱 App abierta por toque en notificación: ${message.data}");
      _handleMessageNavigation(message.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CALMA - Cuidado Geriátrico',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Importante: usar el key global
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      // Aquí puedes agregar tus rutas con nombre si las usas
      // routes: {
      //   '/aspirante/notificaciones': (context) => NotificacionesAspiranteScreen(),
      //   '/contratante/notificaciones': (context) => NotificacionesContratanteScreen(),
      // },
    );
  }
}