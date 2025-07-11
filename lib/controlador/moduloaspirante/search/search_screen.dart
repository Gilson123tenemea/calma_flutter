import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final int idAspirante;
  const SearchScreen({super.key, required this.idAspirante});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Buscar ID: $idAspirante'),
      ),
    );
  }
}