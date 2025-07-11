import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final int idAspirante;
  const FavoritesScreen({super.key,required this.idAspirante});

  @override
  Widget build(BuildContext context) {
    // Ahora puedes usar widget.specificId aquí
    return Scaffold(
      body: Center(
        child: Text('Favoritos ID: $idAspirante'),
      ),
    );
  }
}