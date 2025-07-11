import 'package:flutter/material.dart';
import 'home_view.dart';

class HomeScreen extends StatelessWidget {
  final int idAspirante;
  const HomeScreen({super.key, required this.idAspirante});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeView(idAspirante: idAspirante),
    );
  }
}