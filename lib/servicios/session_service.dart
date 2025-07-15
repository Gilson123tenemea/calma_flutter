import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  static const String _keyUserId = 'userId';
  static const String _keySpecificId = 'specificId';
  static const String _keyRol = 'rol';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyTermsAccepted = 'termsAccepted';

  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTermsAccepted, true);
  }

  Future<bool> areTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTermsAccepted) ?? false;
  }

  Future<void> saveSession({
    required int userId,
    required int specificId,
    required String rol,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setInt(_keySpecificId, specificId);
    await prefs.setString(_keyRol, rol);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<Map<String, dynamic>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt(_keyUserId) ?? 0,
      'specificId': prefs.getInt(_keySpecificId) ?? 0,
      'rol': prefs.getString(_keyRol) ?? '',
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
      'termsAccepted': prefs.getBool(_keyTermsAccepted) ?? false,
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keySpecificId);
    await prefs.remove(_keyRol);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}