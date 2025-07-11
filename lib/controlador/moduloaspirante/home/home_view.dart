import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  final int idAspirante;
  const HomeView({super.key ,required this.idAspirante});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Home Aspirante ID: $idAspirante'),
      ),
    );
  }
}