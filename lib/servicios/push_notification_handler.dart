import 'package:flutter/material.dart';

class PushNotificationHandler extends StatelessWidget {
  final Widget child;

  const PushNotificationHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}