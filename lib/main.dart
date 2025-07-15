import 'package:flutter/material.dart';
import 'package:calma/controlador/splash_screen.dart';

void main() {
  runApp(const MyApp());
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