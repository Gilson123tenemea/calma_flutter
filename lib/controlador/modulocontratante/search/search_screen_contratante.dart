import 'package:calma/servicios/notificaciones_servicios.dart';
import 'package:flutter/material.dart';

class SearchScreenContratante extends StatefulWidget {
  final int specificId;
  const SearchScreenContratante({super.key, required this.specificId});

  @override
  _SearchScreenContratanteState createState() => _SearchScreenContratanteState();
}

class _SearchScreenContratanteState extends State<SearchScreenContratante> {
  List<dynamic> notificaciones = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    obtenerNotificaciones();
  }

  Future<void> obtenerNotificaciones() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : notificaciones.isEmpty
          ? Center(child: Text('No hay notificaciones'))
          : ListView.builder(
        itemCount: notificaciones.length,
        itemBuilder: (context, index) {
          final notificacion = notificaciones[index];
          return ListTile(
            title: Text(notificacion['titulo']),
            subtitle: Text(notificacion['mensaje']),
            onTap: () {
              // Lógica para manejar el clic en la notificación
            },
          );
        },
      ),
    );
  }
}