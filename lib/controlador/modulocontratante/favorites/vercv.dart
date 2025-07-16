import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
        setState(() {
          cvData = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Error al obtener CV: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _descargarArchivo(String url, String nombreArchivo) async {
    try {
      // Solicitar permisos de almacenamiento
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Permiso de almacenamiento denegado');
      }

      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Descargando archivo...'),
              ],
            ),
          );
        },
      );

      // Realizar la petición HTTP
      final response = await http.get(Uri.parse(url));

      Navigator.of(context).pop(); // Cerrar diálogo de carga

      if (response.statusCode == 200) {
        // Obtener directorio de descargas
        final directory = await getExternalStorageDirectory();
        final path = directory?.path ?? '/storage/emulated/0/Download';

        // Crear archivo
        final file = File('$path/$nombreArchivo');

        // Escribir bytes en el archivo
        await file.writeAsBytes(response.bodyBytes);

        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo descargado en: $path/$nombreArchivo'),
            action: SnackBarAction(
              label: 'Abrir',
              onPressed: () async {
                if (await file.exists()) {
                  // Abrir el archivo con una aplicación compatible
                  // Necesitarás el paquete 'open_file' para esto
                  // Ejemplo: await OpenFile.open(file.path);
                }
              },
            ),
          ),
        );
      } else {
        throw Exception('Error al descargar archivo: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _descargarCertificado(int certificadoId) async {
    final certificado = cvData!['certificados'].firstWhere(
          (c) => c['id_certificado'] == certificadoId,
      orElse: () => null,
    );

    if (certificado != null) {
      final nombreArchivo = 'Certificado_${certificado['nombre_certificado']}.pdf';
      await _descargarArchivo(
        AppConfig.getDescargarCertificadoUrl(certificadoId),
        nombreArchivo,
      );
    }
  }


  Future<void> _descargarRecomendacion(int recomendacionId) async {
    final recomendacion = cvData!['recomendaciones'].firstWhere(
          (r) => r['id_recomendacion'] == recomendacionId,
      orElse: () => null,
    );

    if (recomendacion != null) {
      final nombreArchivo = 'Recomendacion_${recomendacion['nombre_recomendador']}.pdf';
      await _descargarArchivo(
        AppConfig.getDescargarRecomendacionUrl(recomendacionId),
        nombreArchivo,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoja de Vida'),
        backgroundColor: const Color(0xFF0A2647), // Azul oscuro
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
          : _buildCVContent(),
    );
  }

  Widget _buildCVContent() {
    final aspirante = cvData!['aspirante'];
    final recomendaciones = cvData!['recomendaciones'] as List;
    final certificados = cvData!['certificados'] as List;
    final habilidades = cvData!['habilidades'] as List;
    final disponibilidades = cvData!['disponibilidades'] as List;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Información Personal
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2647),
                      ),
                    ),
                    const Divider(color: Color(0xFF0A2647)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Nombre', '${aspirante['nombres']} ${aspirante['apellidos']}'),
                    _buildInfoRow('Cédula', aspirante['cedula']),
                    _buildInfoRow('Correo', aspirante['correo']),
                    _buildInfoRow('Género', aspirante['genero']),
                    _buildInfoRow('Fecha Nacimiento', _formatDate(aspirante['fechaNacimiento'])),
                    _buildInfoRow('Ubicación',
                        '${aspirante['ubicacion']['parroquia']}, ${aspirante['ubicacion']['canton']}, ${aspirante['ubicacion']['provincia']}'),
                  ],
                ),
              ),
            ),

            // Sección de Currículum Vitae
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Currículum Vitae',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2647),
                      ),
                    ),
                    const Divider(color: Color(0xFF0A2647)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Experiencia', cvData!['experiencia']),
                    _buildInfoRow('Idiomas', cvData!['idiomas']),
                    _buildInfoRow('Zona de trabajo', cvData!['zona_trabajo']),
                    _buildInfoRow('Información adicional', cvData!['informacion_opcional'] ?? 'N/A'),
                  ],
                ),
              ),
            ),

            // Sección de Disponibilidad
            if (disponibilidades.isNotEmpty)
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Disponibilidad',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2647),
                        ),
                      ),
                      const Divider(color: Color(0xFF0A2647)),
                      const SizedBox(height: 8),
                      for (var disponibilidad in disponibilidades) ...[
                        _buildInfoRow('Días disponibles', disponibilidad['dias_disponibles']),
                        _buildInfoRow('Tipo de jornada', disponibilidad['tipo_jornada']),
                        _buildInfoRow('Horario preferido', disponibilidad['horario_preferido']),
                        _buildInfoRow('Disponibilidad para viajar',
                            disponibilidad['disponibilidad_viaje'] ? 'Sí' : 'No'),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),

            // Sección de Habilidades
            if (habilidades.isNotEmpty)
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Habilidades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2647),
                        ),
                      ),
                      const Divider(color: Color(0xFF0A2647)),
                      const SizedBox(height: 8),
                      for (var habilidad in habilidades) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                habilidad['descripcion'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            _buildNivelEstrellas(habilidad['nivel']),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),

            // Sección de Recomendaciones
            if (recomendaciones.isNotEmpty)
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recomendaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2647),
                        ),
                      ),
                      const Divider(color: Color(0xFF0A2647)),
                      const SizedBox(height: 8),
                      for (var recomendacion in recomendaciones) ...[
                        Text(
                          recomendacion['nombre_recomendador'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(recomendacion['cargo']),
                        const SizedBox(height: 8),
                        _buildInfoRow('Empresa', recomendacion['empresa']),
                        _buildInfoRow('Email', recomendacion['email']),
                        _buildInfoRow('Teléfono', recomendacion['telefono']),
                        _buildInfoRow('Relación', recomendacion['relacion']),
                        _buildInfoRow('Fecha', recomendacion['fecha']),
                        const SizedBox(height: 8),
                        if (recomendacion['tiene_archivo'])
                          ElevatedButton(
                            onPressed: () => _descargarRecomendacion(recomendacion['id_recomendacion']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A2647),
                            ),
                            child: const Text('Descargar recomendación'),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),

            // Sección de Certificados
            if (certificados.isNotEmpty)
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Certificados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2647),
                        ),
                      ),
                      const Divider(color: Color(0xFF0A2647)),
                      const SizedBox(height: 8),
                      for (var certificado in certificados) ...[
                        Text(
                          certificado['nombre_certificado'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(certificado['nombre_institucion']),
                        const SizedBox(height: 8),
                        _buildInfoRow('Fecha de obtención', certificado['fecha']),
                        const SizedBox(height: 8),
                        if (certificado['tiene_archivo'])
                          ElevatedButton(
                            onPressed: () => _descargarCertificado(certificado['id_certificado']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A2647),
                            ),
                            child: const Text('Descargar certificado'),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildNivelEstrellas(String nivel) {
    int estrellas = 1;
    if (nivel.toLowerCase().contains('intermedio')) {
      estrellas = 3;
    } else if (nivel.toLowerCase().contains('avanzado') ||
        nivel.toLowerCase().contains('experto')) {
      estrellas = 5;
    }

    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < estrellas ? Icons.star : Icons.star_border,
          color: const Color(0xFF0A2647),
          size: 20,
        );
      }),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}