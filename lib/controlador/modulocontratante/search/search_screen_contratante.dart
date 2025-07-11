import 'package:flutter/material.dart';

class SearchScreenContratante extends StatelessWidget {
  final int specificId;
  const SearchScreenContratante({super.key, required this.specificId});

  @override
  Widget build(BuildContext context) {
    // Ahora puedes usar widget.specificId aquí
    return Scaffold(
      body: Center(
        child: Text('Buscar del contratante otra ve nuevo ID: $specificId'),
      ),
    );
  }
}