import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final int idAspirante;
  const ProfileScreen({super.key, required this.idAspirante});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Perfil ID: $idAspirante'),
      ),
    );
  }
}