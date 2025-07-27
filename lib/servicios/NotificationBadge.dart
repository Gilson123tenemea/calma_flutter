import 'package:calma/servicios/NotificationActionsService.dart';
import 'package:flutter/material.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final Color badgeColor;
  final Color textColor;
  final double badgeSize;

  const NotificationBadge({
    Key? key,
    required this.child,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.badgeSize = 18,
  }) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarConteoNoLeidas();
  }

  Future<void> _cargarConteoNoLeidas() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final count = await NotificationActionsService.obtenerConteoNoLeidas();
      if (mounted) {
        setState(() {
          _unreadCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando conteo de notificaciones: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Método público para actualizar el contador desde fuera
  void actualizarConteo() {
    _cargarConteoNoLeidas();
  }

  /// Método público para decrementar el contador
  void decrementarConteo() {
    if (_unreadCount > 0) {
      setState(() {
        _unreadCount--;
      });
    }
  }

  /// Método público para resetear el contador
  void resetearConteo() {
    setState(() {
      _unreadCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: widget.badgeColor,
                borderRadius: BorderRadius.circular(widget.badgeSize / 2),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: BoxConstraints(
                minWidth: widget.badgeSize,
                minHeight: widget.badgeSize,
              ),
              child: Center(
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.badgeSize * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension para facilitar el uso del badge
extension NotificationBadgeExtension on Widget {
  Widget withNotificationBadge({
    Color badgeColor = Colors.red,
    Color textColor = Colors.white,
    double badgeSize = 18,
  }) {
    return NotificationBadge(
      badgeColor: badgeColor,
      textColor: textColor,
      badgeSize: badgeSize,
      child: this,
    );
  }
}