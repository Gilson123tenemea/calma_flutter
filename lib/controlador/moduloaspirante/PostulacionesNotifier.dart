// Archivo: lib/utils/postulaciones_notifier.dart
// Crea este archivo nuevo en tu proyecto

import 'package:flutter/foundation.dart';

class PostulacionesNotifier extends ChangeNotifier {
  // Singleton pattern para asegurar una sola instancia
  static final PostulacionesNotifier _instance = PostulacionesNotifier._internal();
  factory PostulacionesNotifier() => _instance;
  PostulacionesNotifier._internal();

  // Lista de listeners para actualizaciones
  final List<VoidCallback> _refreshListeners = [];

  /// Agregar un listener que se ejecutará cuando haya una nueva postulación
  void addRefreshListener(VoidCallback listener) {
    _refreshListeners.add(listener);
    print('📝 Listener agregado. Total: ${_refreshListeners.length}');
  }

  /// Remover un listener específico
  void removeRefreshListener(VoidCallback listener) {
    _refreshListeners.remove(listener);
    print('🗑️ Listener removido. Total: ${_refreshListeners.length}');
  }

  /// Notificar a todos los listeners que se realizó una nueva postulación
  void notifyPostulacionRealizada() {
    print('🔔 Notificando nueva postulación a ${_refreshListeners.length} listeners...');

    for (var listener in _refreshListeners) {
      try {
        listener();
      } catch (e) {
        print('⚠️ Error ejecutando listener: $e');
      }
    }

    // También notificar a través de ChangeNotifier
    notifyListeners();
  }

  /// Limpiar todos los listeners (útil para debugging)
  void clearAllListeners() {
    _refreshListeners.clear();
    print('🧹 Todos los listeners eliminados');
  }

  @override
  void dispose() {
    _refreshListeners.clear();
    super.dispose();
  }
}