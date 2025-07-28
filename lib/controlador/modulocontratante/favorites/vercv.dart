import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VerCV extends StatefulWidget {
  final int aspiranteId;

  const VerCV({Key? key, required this.aspiranteId}) : super(key: key);

  @override
  _VerCVState createState() => _VerCVState();
}

class _VerCVState extends State<VerCV> {
  Map<String, dynamic>? cvData;
  Map<String, dynamic>? calificacionesData;
  bool _isLoading = true;
  bool _isLoadingCalificaciones = true;
  String _errorMessage = '';
  String _errorCalificaciones = '';

  @override
  void initState() {
    super.initState();
    _fetchCV();
    _fetchCalificaciones();
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

  Future<void> _fetchCalificaciones() async {
    try {
      final response = await http.get(Uri.parse(AppConfig.getCalificacionesCompletasUrl(widget.aspiranteId)));

      if (response.statusCode == 200) {
        setState(() {
          calificacionesData = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorCalificaciones = 'Error al obtener calificaciones: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorCalificaciones = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingCalificaciones = false;
      });
    }
  }

  Future<bool> _checkAndRequestStoragePermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt ?? 0;

    if (sdkVersion >= 30) {
      // Android 11+ - Usar el directorio de la aplicación (no necesita permisos)
      return true;
    } else if (sdkVersion == 29) {
      // Android 10 - Verificar si tenemos acceso legacy
      if (await Permission.storage.isGranted) {
        return true;
      }
      return (await Permission.storage.request()).isGranted;
    } else {
      // Android 6-9 - Necesitamos WRITE_EXTERNAL_STORAGE
      if (await Permission.storage.isGranted) {
        return true;
      }
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  Future<void> _descargarArchivo(String url, String nombreArchivo) async {
    try {
      // 1. Verificar conexión a internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Se requiere conexión a internet');
      }

      // 2. Obtener directorio adecuado
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        throw Exception('No se pudo acceder al directorio de descargas');
      }

      // 3. Verificar permisos (solo para Android < 10)
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt != null && androidInfo.version.sdkInt! < 29) {
        if (!await _checkAndRequestStoragePermissions()) {
          throw Exception('Permisos de almacenamiento denegados');
        }
      }

      // 4. Mostrar progreso
      bool downloadCompleted = false;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Descargando archivo...'),
              if (!downloadCompleted)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
            ],
          ),
        ),
      );

      // 5. Descargar el archivo
      final file = File('${directory.path}/$nombreArchivo');
      final response = await http.get(Uri.parse(url));

      if (mounted) {
        Navigator.of(context).pop();
        downloadCompleted = true;
      }

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archivo descargado: ${file.path}'),
              action: SnackBarAction(
                label: 'Abrir',
                onPressed: () => OpenFile.open(file.path),
              ),
            ),
          );
        }
      } else {
        throw Exception('Error al descargar: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt ?? 0;

    if (sdkVersion >= 29) {
      // Android 10+ - Usar directorio interno de la app
      return await getApplicationDocumentsDirectory();
    } else {
      // Android 6-9 - Usar almacenamiento externo
      final dir = await getExternalStorageDirectory();
      final downloadDir = Directory('${dir?.path}/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
  }

  Future<bool> _checkStoragePermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt ?? 0;

    // Android 13+ no necesita permisos para el directorio de la aplicación
    if (sdkVersion >= 29) {
      return true;
    }

    // Para versiones anteriores (Android 6-9)
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    return true;
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
        title: const Text(
          'Hoja de Vida',
          style: TextStyle(
            color: Colors.white, // Color blanco
            fontWeight: FontWeight.bold, // Texto más grueso
          ),
        ),
        centerTitle: true, // Centrar el título
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

            // NUEVA SECCIÓN DE CALIFICACIONES
            _buildCalificacionesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalificacionesSection() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_rate,
                  color: Color(0xFF0A2647),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Calificaciones de Servicios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2647),
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF0A2647)),
            const SizedBox(height: 12),

            if (_isLoadingCalificaciones)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorCalificaciones.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error al cargar calificaciones',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ),
              )
            else if (calificacionesData == null ||
                  calificacionesData!['totalCalificaciones'] == 0)
                _buildSinCalificaciones()
              else
                _buildListaCalificaciones(),
          ],
        ),
      ),
    );
  }

  Widget _buildSinCalificaciones() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star_border_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Aún no cuenta con calificaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las calificaciones aparecerán aquí una vez que complete trabajos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListaCalificaciones() {
    final calificaciones = calificacionesData!['calificaciones'] as List;
    final totalCalificaciones = calificacionesData!['totalCalificaciones'];

    // Calcular promedio
    double promedio = 0.0;
    if (calificaciones.isNotEmpty) {
      int suma = calificaciones.fold(0, (sum, cal) => sum + (cal['puntaje'] as int));
      promedio = suma / calificaciones.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen de calificaciones
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A2647).withOpacity(0.1),
                const Color(0xFF0A2647).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0A2647).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promedio General',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildEstrellasPuntaje(promedio.round()),
                        const SizedBox(width: 8),
                        Text(
                          '${promedio.toStringAsFixed(1)}/5.0',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2647),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2647),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCalificaciones ${totalCalificaciones == 1 ? 'calificación' : 'calificaciones'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Historial de Calificaciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),

        const SizedBox(height: 12),

        // Lista de calificaciones individuales
        ...calificaciones.map((calificacion) => _buildCalificacionCard(calificacion)).toList(),
      ],
    );
  }

  Widget _buildCalificacionCard(Map<String, dynamic> calificacion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estrellas y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEstrellasPuntaje(calificacion['puntaje']),
                Text(
                  _formatDateCalificacion(calificacion['fecha']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Comentario
            if (calificacion['comentario'] != null && calificacion['comentario'].toString().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  '"${calificacion['comentario']}"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Información del contratante
            if (calificacion['contratante'] != null)
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2647).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF0A2647),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          calificacion['contratante']['nombre'] ?? 'Contratante',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A2647),
                          ),
                        ),
                        if (calificacion['contratante']['empresa'] != null)
                          Text(
                            calificacion['contratante']['empresa'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

            // Información del trabajo (si existe)
            if (calificacion['trabajo'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2647).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0A2647).withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Trabajo realizado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      calificacion['trabajo']['tituloTrabajo'] ?? 'Trabajo sin título',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A2647),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstrellasPuntaje(int puntaje) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < puntaje ? Icons.star : Icons.star_border,
          color: index < puntaje ? Colors.amber[600] : Colors.grey[400],
          size: 20,
        );
      }),
    );
  }

  String _formatDateCalificacion(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
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