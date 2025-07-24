import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Claves para SharedPreferences
  static const String _keyUserId = 'userId';
  static const String _keySpecificId = 'specificId';
  static const String _keyRol = 'rol';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyTermsAccepted = 'termsAccepted';
  static const String _keyFcmToken = 'fcmToken';

  // Métodos para términos y condiciones
  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTermsAccepted, true);
  }

  Future<bool> areTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTermsAccepted) ?? false;
  }

  // Métodos para manejo de sesión
  Future<void> saveSession({
    required int userId,
    required int specificId,
    required String rol,
    String? fcmToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_keyUserId, userId),
      prefs.setInt(_keySpecificId, specificId),
      prefs.setString(_keyRol, rol.toLowerCase()), // Normalizamos el rol a minúsculas
      prefs.setBool(_keyIsLoggedIn, true),
      if (fcmToken != null) prefs.setString(_keyFcmToken, fcmToken),
    ]);
  }

  Future<Map<String, dynamic>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt(_keyUserId) ?? 0,
      'specificId': prefs.getInt(_keySpecificId) ?? 0,
      'rol': prefs.getString(_keyRol) ?? '',
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
      'termsAccepted': prefs.getBool(_keyTermsAccepted) ?? false,
      'fcmToken': prefs.getString(_keyFcmToken),
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyUserId),
      prefs.remove(_keySpecificId),
      prefs.remove(_keyRol),
      prefs.remove(_keyFcmToken),
      prefs.setBool(_keyIsLoggedIn, false),
    ]);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Métodos específicos para FCM Token
  Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, token);
  }

  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  Future<void> clearFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFcmToken);
  }
}