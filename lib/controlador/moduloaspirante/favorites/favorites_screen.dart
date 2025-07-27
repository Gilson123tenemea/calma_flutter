import 'package:calma/controlador/moduloaspirante/PostulacionesNotifier.dart';
import 'package:calma/controlador/moduloaspirante/favorites/FichaPacienteScreen.dart';
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

  late VoidCallback _postulacionListener;

  @override
  void initState() {
    super.initState();
    _fetchPostulaciones();

    _postulacionListener = () {
      print('🔔 Recibida notificación de nueva postulación, actualizando...');
      if (mounted) {
        refreshPostulaciones();
      }
    };

    PostulacionesNotifier().addRefreshListener(_postulacionListener);
  }

  @override
  void dispose() {
    PostulacionesNotifier().removeRefreshListener(_postulacionListener);
    super.dispose();
  }

  Future<void> refreshPostulaciones() async {
    await _fetchPostulaciones();
  }

  Future<void> _fetchPostulaciones() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/realizar/aspirante/${widget.idAspirante}');
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> nuevasPostulaciones = json.decode(response.body);

        if (nuevasPostulaciones.isNotEmpty) {
          print('🔍 Estructura de datos recibida:');
          print('Keys principales: ${nuevasPostulaciones[0].keys.toList()}');
          if (nuevasPostulaciones[0]['postulacion'] != null) {
            print('Keys de postulacion: ${nuevasPostulaciones[0]['postulacion'].keys.toList()}');
            if (nuevasPostulaciones[0]['postulacion']['postulacion_empleo'] != null) {
              print('Keys de postulacion_empleo: ${nuevasPostulaciones[0]['postulacion']['postulacion_empleo'].keys.toList()}');
            }
          }
        }

        setState(() {
          _postulaciones = nuevasPostulaciones;
          _isLoading = false;
          _errorMessage = '';
        });

        print('✅ Postulaciones actualizadas: ${_postulaciones.length} elementos');

      } else if (response.statusCode == 204) {
        setState(() {
          _postulaciones = [];
          _isLoading = false;
          _errorMessage = 'No tienes postulaciones aún';
        });
      } else {
        throw Exception('Error al cargar postulaciones (${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión: $e';
      });

      print('❌ Error al cargar postulaciones: $e');
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

  String _getSalario(Map<String, dynamic> postulacionEmpleo) {
    final salario = postulacionEmpleo['salario_estimado'] ??
        postulacionEmpleo['salario'] ??
        postulacionEmpleo['sueldo'] ??
        postulacionEmpleo['salario_minimo'] ??
        0.0;

    if (salario is String) {
      return double.tryParse(salario)?.toStringAsFixed(2) ?? '0.00';
    } else if (salario is num) {
      return salario.toStringAsFixed(2);
    }

    return 'No especificado';
  }

  String _getTextoSeguro(Map<String, dynamic> data, String key, {String defaultValue = 'No especificado'}) {
    final value = data[key];
    if (value == null || value.toString().isEmpty) {
      return defaultValue;
    }
    return value.toString();
  }

  int? _getIdPaciente(Map<String, dynamic> postulacionEmpleo) {
    final idPaciente = postulacionEmpleo['id_paciente'];
    if (idPaciente is int) {
      return idPaciente;
    } else if (idPaciente is String) {
      return int.tryParse(idPaciente);
    }
    return null;
  }

  void _navigateToFichaPaciente(int idPaciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FichaPacienteScreen(idPaciente: idPaciente),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: refreshPostulaciones,
            tooltip: 'Actualizar postulaciones',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPostulaciones,
        color: const Color(0xFF0E1E3A),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0E1E3A)))
            : _errorMessage.isNotEmpty
            ? _buildErrorState()
            : _postulaciones.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _postulaciones.length,
          itemBuilder: (context, index) {
            final postulacion = _postulaciones[index];
            final postulacionEmpleo = postulacion['postulacion']['postulacion_empleo'];
            final bool esAprobado = postulacion['postulacion']['estado'] == true;
            final int? idPaciente = _getIdPaciente(postulacionEmpleo);

            DateTime? fechaLimite;
            String fechaFormateada = 'No especificada';

            try {
              if (postulacionEmpleo['fecha_limite'] != null) {
                fechaLimite = DateTime.parse(postulacionEmpleo['fecha_limite']);
                fechaFormateada = '${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}';
              }
            } catch (e) {
              print('Error parseando fecha: $e');
              fechaFormateada = postulacionEmpleo['fecha_limite']?.toString() ?? 'Fecha inválida';
            }

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
                              _getTextoSeguro(postulacionEmpleo, 'titulo', defaultValue: 'Sin título'),
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
                        _getTextoSeguro(postulacionEmpleo, 'descripcion', defaultValue: 'Sin descripción'),
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
                          _buildInfoChip(Icons.work, _getTextoSeguro(postulacionEmpleo, 'jornada')),
                          _buildInfoChip(Icons.access_time, _getTextoSeguro(postulacionEmpleo, 'turno')),
                          _buildInfoChip(Icons.calendar_today, 'Vence: $fechaFormateada'),
                          _buildInfoChip(Icons.attach_money, '\$${_getSalario(postulacionEmpleo)}'),
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
                      ..._getActividades(postulacionEmpleo)
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

                      if (esAprobado && idPaciente != null) ...[
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToFichaPaciente(idPaciente),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3F7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              elevation: 3,
                            ),
                            icon: const Icon(Icons.medical_information, size: 20),
                            label: const Text(
                              'Ver Ficha Paciente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<String> _getActividades(Map<String, dynamic> postulacionEmpleo) {
    final actividades = postulacionEmpleo['actividades_realizar'];

    if (actividades == null || actividades.toString().isEmpty) {
      return ['No se especificaron actividades'];
    }

    if (actividades is String) {
      return actividades.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    if (actividades is List) {
      return actividades.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }

    return ['Actividades no disponibles'];
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar postulaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E1E3A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: refreshPostulaciones,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1E3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off, size: 80, color: Color(0xFF0E1E3A)),
            const SizedBox(height: 16),
            const Text(
              'No tienes postulaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E1E3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ve a la pantalla de empleos para postularte a trabajos disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: refreshPostulaciones,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1E3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      backgroundColor: Colors.black.withOpacity(0.2),
      avatar: Icon(icon, size: 16, color: Colors.black),
      label: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}