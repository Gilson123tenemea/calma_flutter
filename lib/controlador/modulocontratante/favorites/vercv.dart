import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';

class VerCV extends StatefulWidget {
  final int aspiranteId;

  const VerCV({Key? key, required this.aspiranteId}) : super(key: key);

  @override
  _VerCVState createState() => _VerCVState();
}

class _VerCVState extends State<VerCV> {
  Map<String, dynamic>? cvData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCV();
  }

  Future<void> _fetchCV() async {
    try {
      final response = await http.get(Uri.parse(AppConfig.getCvPorAspiranteUrl(widget.aspiranteId)));

      if (response.statusCode == 200) {
        cvData = json.decode(response.body);
      } else {
        _errorMessage = 'Error al obtener CV: ${response.body}';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoja de Vida'),
        backgroundColor: const Color(0xFF0A2647),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
          : _buildCVContent(),
    );
  }

  Widget _buildCVContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${cvData!['aspirante']['nombres']} ${cvData!['aspirante']['apellidos']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${cvData!['aspirante']['correo']}'),
            const SizedBox(height: 8),
            Text('Teléfono: ${cvData!['aspirante']['telefono'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            Text('Experiencia: ${cvData!['experiencia']}', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Idiomas: ${cvData!['idiomas']}'),
            const SizedBox(height: 16),
            Text('Zona de trabajo: ${cvData!['zona_trabajo']}'),
            const SizedBox(height: 16),
            Text('Información adicional: ${cvData!['informacion_opcional'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            // Puedes agregar más campos según sea necesario
          ],
        ),
      ),
    );
  }
}