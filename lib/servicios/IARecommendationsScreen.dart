import 'package:calma/servicios/IAService.dart';
import 'package:flutter/material.dart';

class IARecommendationsScreen extends StatefulWidget {
  final int contratanteId;

  const IARecommendationsScreen({
    Key? key,
    required this.contratanteId,
  }) : super(key: key);

  @override
  _IARecommendationsScreenState createState() => _IARecommendationsScreenState();
}

class _IARecommendationsScreenState extends State<IARecommendationsScreen>
    with SingleTickerProviderStateMixin {

  final IAService _iaService = IAService();
  final TextEditingController _criteriosController = TextEditingController();

  List<dynamic> _publicaciones = [];
  int? _selectedPublicacionId;
  String? _selectedPublicacionTitulo;
  Map<String, dynamic>? _recomendacionData;
  Map<String, dynamic>? _estadisticasData;

  bool _isLoadingPublicaciones = true;
  bool _isLoadingRecomendacion = false;
  bool _isLoadingEstadisticas = false;

  late TabController _tabController;

  final Color _primaryColor = const Color(0xFF0A2647);
  final Color _secondaryColor = const Color(0xFF144272);
  final Color _accentColor = const Color(0xFF2C74B3);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarPublicaciones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _criteriosController.dispose();
    super.dispose();
  }

  Future<void> _cargarPublicaciones() async {
    try {
      setState(() => _isLoadingPublicaciones = true);

      final publicaciones = await _iaService.obtenerPublicacionesContratante(widget.contratanteId);

      setState(() {
        _publicaciones = publicaciones;
        _isLoadingPublicaciones = false;
      });
    } catch (e) {
      setState(() => _isLoadingPublicaciones = false);
      _mostrarError('Error al cargar publicaciones: $e');
    }
  }

  Future<void> _obtenerRecomendacion() async {
    if (_selectedPublicacionId == null) {
      _mostrarError('Por favor selecciona una publicación');
      return;
    }

    try {
      setState(() => _isLoadingRecomendacion = true);

      final resultado = await _iaService.obtenerRecomendacionIA(
        idPublicacion: _selectedPublicacionId!,
        criterios: _criteriosController.text.trim().isEmpty
            ? null
            : _criteriosController.text.trim(),
      );

      setState(() {
        _recomendacionData = resultado;
        _isLoadingRecomendacion = false;
      });
    } catch (e) {
      setState(() => _isLoadingRecomendacion = false);
      _mostrarError('Error al obtener recomendación: $e');
    }
  }

  Future<void> _obtenerEstadisticas() async {
    if (_selectedPublicacionId == null) {
      _mostrarError('Por favor selecciona una publicación');
      return;
    }

    try {
      setState(() => _isLoadingEstadisticas = true);

      final estadisticas = await _iaService.obtenerEstadisticasCandidatos(_selectedPublicacionId!);

      setState(() {
        _estadisticasData = estadisticas;
        _isLoadingEstadisticas = false;
      });
    } catch (e) {
      setState(() => _isLoadingEstadisticas = false);
      _mostrarError('Error al obtener estadísticas: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Asistente IA - Candidatos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.psychology), text: 'Recomendaciones'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Selector de publicación
          _buildPublicacionSelector(),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecomendacionesTab(),
                _buildEstadisticasTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicacionSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: _primaryColor),
              const SizedBox(width: 8),
              Text(
                'Seleccionar Publicación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoadingPublicaciones)
            const Center(child: CircularProgressIndicator())
          else if (_publicaciones.isEmpty)
            Text(
              'No tienes publicaciones activas',
              style: TextStyle(color: Colors.grey[600]),
            )
          else
            DropdownButtonFormField<int>(
              value: _selectedPublicacionId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Selecciona una publicación'),
              isExpanded: true,
              items: _publicaciones.map<DropdownMenuItem<int>>((publicacion) {
                return DropdownMenuItem<int>(
                  value: publicacion['id_postulacion_empleo'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        publicacion['titulo'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Salario: \$${publicacion['salario_estimado']} - ${publicacion['jornada']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedPublicacionId = newValue;
                  _selectedPublicacionTitulo = _publicaciones
                      .firstWhere((p) => p['id_postulacion_empleo'] == newValue)['titulo'];
                  _recomendacionData = null;
                  _estadisticasData = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecomendacionesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de criterios personalizados
          _buildCriteriosSection(),

          const SizedBox(height: 16),

          // Botón para obtener recomendación
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedPublicacionId != null && !_isLoadingRecomendacion
                  ? _obtenerRecomendacion
                  : null,
              icon: _isLoadingRecomendacion
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.psychology),
              label: Text(_isLoadingRecomendacion
                  ? 'Analizando candidatos...'
                  : 'Obtener Recomendación IA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mostrar recomendación
          if (_recomendacionData != null)
            _buildRecomendacionResult(),
        ],
      ),
    );
  }

  Widget _buildCriteriosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: _primaryColor),
              const SizedBox(width: 8),
              Text(
                'Criterios Personalizados (Opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Especifica criterios adicionales para que la IA considere en su análisis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _criteriosController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ej: Prefiero candidatos con experiencia previa en cuidado de personas con demencia, disponibilidad completa los fines de semana...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacionResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: _accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recomendación IA para: $_selectedPublicacionTitulo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_recomendacionData!['totalCandidatos'] != null)
            Text(
              'Total de candidatos analizados: ${_recomendacionData!['totalCandidatos']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          const Divider(height: 24),

          SelectableText(
            _recomendacionData!['respuesta'] ?? 'No se pudo obtener recomendación',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botón para obtener estadísticas
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedPublicacionId != null && !_isLoadingEstadisticas
                  ? _obtenerEstadisticas
                  : null,
              icon: _isLoadingEstadisticas
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.analytics),
              label: Text(_isLoadingEstadisticas
                  ? 'Calculando estadísticas...'
                  : 'Obtener Estadísticas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mostrar estadísticas
          if (_estadisticasData != null)
            _buildEstadisticasResult(),
        ],
      ),
    );
  }

  Widget _buildEstadisticasResult() {
    final stats = _estadisticasData!;

    return Column(
      children: [
        // Resumen general
        _buildStatCard(
          title: 'Resumen General',
          icon: Icons.people,
          children: [
            _buildStatRow('Total de Candidatos', '${stats['totalCandidatos'] ?? 0}'),
            _buildStatRow('Candidatos Disponibles', '${stats['candidatosDisponibles'] ?? 0}'),
            _buildStatRow('Con Experiencia', '${stats['candidatosConExperiencia'] ?? 0}'),
            _buildStatRow('Promedio Calificaciones', '${stats['promedioCalificaciones'] ?? '0.0'} ⭐'),
          ],
        ),

        const SizedBox(height: 16),

        // Porcentajes
        _buildStatCard(
          title: 'Distribución por Porcentajes',
          icon: Icons.pie_chart,
          children: [
            _buildStatRow('% con Experiencia', '${stats['porcentajeExperiencia'] ?? 0}%'),
            _buildStatRow('% Disponibilidad Inmediata', '${stats['porcentajeDisponibilidad'] ?? 0}%'),
            _buildStatRow('% Sin Experiencia', '${((stats['totalCandidatos'] ?? 0) > 0 ? ((stats['candidatosSinExperiencia'] ?? 0) * 100 / stats['totalCandidatos']) : 0).round()}%'),
          ],
        ),

        const SizedBox(height: 16),

        // Detalles adicionales
        if (stats['totalCandidatos'] != null && stats['totalCandidatos'] > 0)
          _buildStatCard(
            title: 'Análisis Detallado',
            icon: Icons.insights,
            children: [
              _buildStatRow('Candidatos sin Experiencia', '${stats['candidatosSinExperiencia'] ?? 0}'),
              _buildStatRow('Candidatos no Disponibles', '${stats['candidatosNoDisponibles'] ?? 0}'),
            ],
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}