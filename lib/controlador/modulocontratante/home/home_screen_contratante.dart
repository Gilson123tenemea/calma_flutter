import 'package:calma/controlador/modulocontratante/home/home_view_contratante.dart';
import 'package:flutter/material.dart';

class HomeScreenContratante extends StatelessWidget {
  final int specificId;

  const HomeScreenContratante({super.key, required this.specificId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeViewContratante(specificId: specificId),
    );
  }
}