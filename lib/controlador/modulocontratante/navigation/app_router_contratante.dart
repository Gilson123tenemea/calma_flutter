import 'package:flutter/material.dart';
import 'bottom_nav_bar_contratante.dart';

class AppRouterContratante {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => GoogleBottomBarContratante(
            specificId: arguments?['specificId'] ?? 0, // Valor por defecto 0 o maneja el error
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}