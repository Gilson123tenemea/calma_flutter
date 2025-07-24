import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Función para inicializar las notificaciones
  Future<void> initialize() async {
    // Solicitar permisos (para iOS/macOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Puedes cambiarlo a true para permisos provisionales
    );

    print('Permisos de usuario: ${settings.authorizationStatus}');

    // Obtener el token FCM
    await _getFCMToken();

    // Escuchar actualizaciones del token
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);
  }

  // Función para obtener el token FCM
  Future<String?> _getFCMToken() async {
    try {
      // Para web necesitarías pasar el vapidKey, para móvil no es necesario
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        print('FCM Token: $token');
        _saveTokenToDatabase(token);
      } else {
        print('No se pudo obtener el token FCM');
      }

      return token;
    } catch (e) {
      print('Error al obtener el token FCM: $e');
      return null;
    }
  }

  // Función para guardar el token en tu base de datos (debes implementarla)
  void _saveTokenToDatabase(String token) {
    // Aquí deberías enviar el token a tu servidor para guardarlo
    // Ejemplo: hacer una petición HTTP a tu backend
    print('Token para guardar en tu base de datos: $token');

    // Implementa la lógica para enviar el token a tu servidor
    // Ejemplo:
    // await http.post(
    //   Uri.parse('https://tuservidor.com/guardar-token'),
    //   body: {'token': token, 'userId': '123'},
    // );
  }
}