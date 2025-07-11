import 'package:calma/configuracion/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesScreenContratante extends StatefulWidget {
  final int specificId;
  const FavoritesScreenContratante({super.key, required this.specificId});

  @override
  _FavoritesScreenContratanteState createState() => _FavoritesScreenContratanteState();
}

class _FavoritesScreenContratanteState extends State<FavoritesScreenContratante> {
  List<dynamic> _postulaciones = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final Color _primaryColor = const Color(0xFF0A2647); // Azul oscuro profesional
  final Color _secondaryColor = const Color(0xFF144272); // Azul medio
  final Color _accentColor = const Color(0xFF2C74B3); // Azul claro

  @override
  void initState() {
    super.initState();
    _fetchPostulaciones();
  }

  Future<void> _fetchPostulaciones() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/postulacion/${widget.specificId}/realizaciones'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _postulaciones = json.decode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 204) {
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar las postulaciones: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleAceptar(int postulacionId) {
    // Lógica para aceptar postulación
    _showSnackbar('Postulación $postulacionId aceptada');
  }

  void _handleRechazar(int postulacionId) {
    // Lógica para rechazar postulación
    _showSnackbar('Postulación $postulacionId rechazada');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Postulaciones',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
          : _postulaciones.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes postulaciones guardadas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _postulaciones.length,
        itemBuilder: (context, index) {
          final postulacion = _postulaciones[index]['postulacion'];
          final empleo = postulacion['postulacion_empleo'];
          final parroquia = empleo['parroquia'];
          final canton = parroquia['canton'];
          final provincia = canton['provincia'];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con título y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          empleo['titulo'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      Chip(
                        backgroundColor: postulacion['estado']
                            ? Colors.green[100]
                            : Colors.red[100],
                        label: Text(
                          postulacion['estado'] ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: postulacion['estado']
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    empleo['descripcion'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Detalles en fila
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildDetailItem(
                        Icons.attach_money,
                        'Salario: \$${empleo['salario_estimado']}',
                      ),
                      _buildDetailItem(
                        Icons.schedule,
                        'Jornada: ${empleo['jornada']}',
                      ),
                      _buildDetailItem(
                        Icons.timer,
                        'Turno: ${empleo['turno']}',
                      ),
                      _buildDetailItem(
                        Icons.location_on,
                        '${parroquia['nombre']}, ${canton['nombre']}, ${provincia['nombre']}',
                      ),
                      _buildDetailItem(
                        Icons.calendar_today,
                        'Fecha límite: ${empleo['fecha_limite'].toString().split('T')[0]}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Requisitos
                  Text(
                    'Requisitos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    empleo['requisitos'],
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: () => _handleRechazar(postulacion['id_postulacion']),
                        child: const Text('Rechazar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: () => _handleAceptar(postulacion['id_postulacion']),
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _secondaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}