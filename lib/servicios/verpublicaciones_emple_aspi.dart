import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PublicacionGenerada {
  final int idGenera;
  final String titulo;
  final String nombresContratante;
  final String apellidosContratante;
  final String descripcion;
  final double salario;
  final String fechaPublicacion;
  final String fechaLimite;
  final String requisitos;
  final String jornada;
  final String turno;
  final String estado;
  final String nombreParroquia;
  final String nombreCanton;
  final String nombreProvincia;
  final bool disponibilidadInmediata;

  PublicacionGenerada({
    required this.idGenera,
    required this.titulo,
    required this.nombresContratante,
    required this.apellidosContratante,
    required this.descripcion,
    required this.salario,
    required this.fechaPublicacion,
    required this.fechaLimite,
    required this.requisitos,
    required this.jornada,
    required this.turno,
    required this.estado,
    required this.nombreParroquia,
    required this.nombreCanton,
    required this.nombreProvincia,
    required this.disponibilidadInmediata,
  });

  factory PublicacionGenerada.fromJson(Map<String, dynamic> json) {
    return PublicacionGenerada(
      idGenera: json['id_genera'],
      titulo: json['publicacionempleo']['titulo'] ?? 'Sin título',
      nombresContratante: json['contratante']['usuario']['nombres'] ?? '',
      apellidosContratante: json['contratante']['usuario']['apellidos'] ?? '',
      descripcion: json['publicacionempleo']['descripcion'] ?? 'Sin descripción',
      salario: json['publicacionempleo']['salario_estimado']?.toDouble() ?? 0.0,
      fechaPublicacion: json['fechaPublicacion'] ?? '',
      fechaLimite: json['publicacionempleo']['fecha_limite'] ?? '',
      requisitos: json['publicacionempleo']['requisitos'] ?? 'No especificado',
      jornada: json['publicacionempleo']['jornada'] ?? 'No especificada',
      turno: json['publicacionempleo']['turno'] ?? 'No especificado',
      estado: json['publicacionempleo']['estado'] ?? 'Desconocido',
      nombreParroquia: json['publicacionempleo']['parroquia']['nombre'] ?? '',
      nombreCanton: json['publicacionempleo']['parroquia']['canton']['nombre'] ?? '',
      nombreProvincia: json['publicacionempleo']['parroquia']['canton']['provincia']['nombre'] ?? '',
      disponibilidadInmediata: json['publicacionempleo']['disponibilidad_inmediata'] ?? false,
    );
  }

  String get ubicacionCompleta {
    return '$nombreParroquia, $nombreCanton, $nombreProvincia';
  }

  String get nombreCompletoContratante {
    return '$nombresContratante $apellidosContratante';
  }
}

class PublicacionService {
  Future<List<PublicacionGenerada>> obtenerPublicacionesGeneradas() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.getPublicacionesGeneradasUrl()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        if (body.isEmpty) {
          throw Exception('No hay publicaciones disponibles');
        }
        return body.map((dynamic item) => PublicacionGenerada.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint no encontrado');
      } else if (response.statusCode >= 500) {
        throw Exception('Error del servidor');
      } else {
        throw Exception('Error al cargar las publicaciones: ${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Error al procesar los datos');
    } on http.ClientException {
      throw Exception('Error de conexión con el servidor');
    } catch (e) {
      throw Exception('Error desconocido: $e');
    }
  }
}

class VerPublicacionesEmpleo extends StatefulWidget {
  @override
  _VerPublicacionesEmpleoState createState() => _VerPublicacionesEmpleoState();
}

class _VerPublicacionesEmpleoState extends State<VerPublicacionesEmpleo> {
  final PublicacionService _publicacionService = PublicacionService();
  late Future<List<PublicacionGenerada>> _futurePublicaciones;

  @override
  void initState() {
    super.initState();
    _futurePublicaciones = _publicacionService.obtenerPublicacionesGeneradas();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futurePublicaciones = _publicacionService.obtenerPublicacionesGeneradas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publicaciones de Empleo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<PublicacionGenerada>>(
          future: _futurePublicaciones,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error al cargar las publicaciones',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_outline, size: 50, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'No hay publicaciones disponibles',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Intenta más tarde o crea una nueva publicación',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final publicacion = snapshot.data![index];
                  return _buildPublicacionCard(publicacion);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPublicacionCard(PublicacionGenerada publicacion) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          // Puedes añadir navegación a detalles aquí
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con título y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      publicacion.titulo,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      publicacion.estado,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: publicacion.estado == 'Activo'
                        ? Colors.green
                        : Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Contratante y fecha
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Publicado por: ${publicacion.nombreCompletoContratante}',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(_formatDate(publicacion.fechaPublicacion)),
                ],
              ),
              SizedBox(height: 16),

              // Descripción
              Text(
                publicacion.descripcion,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Detalles en 2 columnas
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(Icons.attach_money, 'Salario:', '\$${publicacion.salario.toStringAsFixed(2)}'),
                        _buildDetailItem(Icons.date_range, 'Fecha límite:', _formatDate(publicacion.fechaLimite)),
                        _buildDetailItem(Icons.location_on, 'Ubicación:', publicacion.ubicacionCompleta),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(Icons.work, 'Jornada:', publicacion.jornada),
                        _buildDetailItem(Icons.access_time, 'Turno:', publicacion.turno),
                        _buildDetailItem(Icons.check_circle, 'Disponibilidad:', publicacion.disponibilidadInmediata ? "Inmediata" : "No inmediata"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Requisitos
              Text(
                'Requisitos:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                publicacion.requisitos,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateString;
    }
  }
}