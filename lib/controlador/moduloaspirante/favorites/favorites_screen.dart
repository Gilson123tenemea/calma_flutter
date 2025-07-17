import 'package:flutter/material.dart';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesScreen extends StatefulWidget {
  final int idAspirante;
  const FavoritesScreen({super.key, required this.idAspirante});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> _postulaciones = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPostulaciones();
  }

  Future<void> _fetchPostulaciones() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/realizar/aspirante/${widget.idAspirante}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _postulaciones = json.decode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 204) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No tienes postulaciones aún';
        });
      } else {
        throw Exception('Error al cargar postulaciones');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión: $e';
      });
    }
  }

  String _getEstadoPostulacion(bool? estado) {
    if (estado == null) return 'Pendiente';
    return estado ? 'Aprobado' : 'Rechazado';
  }

  Color _getEstadoColor(bool? estado) {
    if (estado == null) return Colors.amber[700]!;
    return estado ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Mis Postulaciones',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF0E1E3A), // Azul oscuro
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0E1E3A)))
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      )
          : _postulaciones.isEmpty
          ? const Center(
        child: Text(
          'No tienes postulaciones',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _postulaciones.length,
        itemBuilder: (context, index) {
          final postulacion = _postulaciones[index];
          final postulacionEmpleo = postulacion['postulacion']['postulacion_empleo'];
          final fechaLimite = DateTime.parse(postulacionEmpleo['fecha_limite']);
          final fechaFormateada = '${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}';

          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: child,
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: const Color(0xFF0E1E3A), // Fondo azul oscuro
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            postulacionEmpleo['titulo'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(postulacion['postulacion']['estado']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getEstadoPostulacion(postulacion['postulacion']['estado']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      postulacionEmpleo['descripcion'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(Icons.work, '${postulacionEmpleo['jornada']}'),
                        _buildInfoChip(Icons.access_time, '${postulacionEmpleo['turno']}'),
                        _buildInfoChip(Icons.calendar_today, 'Vence: $fechaFormateada'),
                        _buildInfoChip(Icons.attach_money, '\$${postulacionEmpleo['salario_estimado']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Actividades a realizar:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...postulacionEmpleo['actividades_realizar']
                        .split(', ')
                        .map((actividad) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              actividad.trim(),
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      backgroundColor: Colors.white.withOpacity(0.2),
      avatar: Icon(icon, size: 16, color: Colors.black),
      label: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}