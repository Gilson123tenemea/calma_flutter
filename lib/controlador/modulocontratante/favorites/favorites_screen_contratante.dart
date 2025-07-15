import 'package:calma/configuracion/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/servicios/mostrar_postulaciones_servicios.dart';

class FavoritesScreenContratante extends StatefulWidget {
  final int specificId;
  const FavoritesScreenContratante({super.key, required this.specificId});

  @override
  _FavoritesScreenContratanteState createState() => _FavoritesScreenContratanteState();
}

class _FavoritesScreenContratanteState extends State<FavoritesScreenContratante> {
  final PostulacionService _postulacionService = PostulacionService();
  List<dynamic> _postulaciones = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final Color _primaryColor = const Color(0xFF0A2647);
  final Color _secondaryColor = const Color(0xFF144272);
  final Color _accentColor = const Color(0xFF2C74B3);

  @override
  void initState() {
    super.initState();
    _fetchPostulaciones();
  }

  Future<void> _fetchPostulaciones() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final postulaciones = await _postulacionService.getPostulacionesPorContratante(widget.specificId);

      setState(() {
        _postulaciones = postulaciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAceptar(int postulacionId) async {
    try {
      final success = await _postulacionService.actualizarEstadoPostulacion(postulacionId, true);

      if (success) {
        _showSnackbar('Postulación aceptada correctamente');
        await _fetchPostulaciones();
      }
    } catch (e) {
      _showSnackbar('Error al aceptar postulación: ${e.toString()}');
    }
  }

  Future<void> _handleRechazar(int postulacionId) async {
    try {
      final success = await _postulacionService.actualizarEstadoPostulacion(postulacionId, false);

      if (success) {
        _showSnackbar('Postulación rechazada correctamente');
        await _fetchPostulaciones();
      }
    } catch (e) {
      _showSnackbar('Error al rechazar postulación: ${e.toString()}');
    }
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
          style: TextStyle(color: Colors.white),
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
                          postulacion['estado'] ? 'Aceptado' : 'Rechazado',
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