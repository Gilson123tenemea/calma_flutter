import 'package:calma/servicios/mostrar_publicaciones_servicios.dart';
import 'package:flutter/material.dart';

class HomeViewContratante extends StatefulWidget {
  final int specificId;

  const HomeViewContratante({super.key, required this.specificId});

  @override
  _HomeViewContratanteState createState() => _HomeViewContratanteState();
}

class _HomeViewContratanteState extends State<HomeViewContratante> {
  late Future<List<dynamic>> _publicacionesFuture;
  final Color _primaryColor = Colors.white;
  final Color _accentColor = const Color(0xFF0A2647); // Azul oscuro
  final Color _textColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey[700]!;

  @override
  void initState() {
    super.initState();
    _publicacionesFuture = PublicacionService.obtenerPublicacionesPorContratante(widget.specificId);
  }

  void _refreshData() {
    setState(() {
      _publicacionesFuture = PublicacionService.obtenerPublicacionesPorContratante(widget.specificId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        title: const Text(
          'Mis Publicaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: _accentColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: _refreshData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _publicacionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A2647)),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar las publicaciones',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 16,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay publicaciones disponibles',
                      style: TextStyle(
                        color: _secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  var publicacion = snapshot.data![index];
                  var empleo = publicacion['publicacionempleo'];
                  var parroquia = empleo['parroquia'];
                  var ubicacion = '${parroquia['nombre']}, ${parroquia['canton']['nombre']}';

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado con color azul oscuro
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  empleo['titulo'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildEstadoChip(empleo['estado']),
                            ],
                          ),
                        ),

                        // Contenido de la publicación
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                empleo['descripcion'],
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Información detallada
                              _buildDetailItem(
                                icon: Icons.work_outline,
                                title: 'Jornada',
                                value: empleo['jornada'],
                              ),
                              _buildDetailItem(
                                icon: Icons.attach_money,
                                title: 'Salario estimado',
                                value: '\$${empleo['salario_estimado']}',
                              ),
                              _buildDetailItem(
                                icon: Icons.location_on,
                                title: 'Ubicación',
                                value: ubicacion,
                              ),
                              _buildDetailItem(
                                icon: Icons.calendar_today,
                                title: 'Disponibilidad',
                                value: empleo['disponibilidad_inmediata']
                                    ? 'Inmediata'
                                    : 'Programada',
                              ),

                              const SizedBox(height: 16),

                              // Botón de activar/desactivar
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    empleo['estado'] == 'Activo'
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    empleo['estado'] == 'Activo'
                                        ? 'DESACTIVAR PUBLICACIÓN'
                                        : 'ACTIVAR PUBLICACIÓN',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: empleo['estado'] == 'Activo'
                                        ? Colors.red[700]
                                        : Colors.green[700],
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _cambiarEstadoPublicacion(
                                      publicacion['id_genera'],
                                      empleo['estado'],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: _accentColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: estado == 'Activo' ? Colors.green[700] : Colors.red[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _cambiarEstadoPublicacion(int idGenera, String estadoActual) async {
    final nuevoEstado = estadoActual == 'Activo' ? 'Inactivo' : 'Activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmar cambio',
          style: TextStyle(
            color: _accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro que deseas cambiar el estado a "$nuevoEstado"?',
          style: TextStyle(color: _textColor),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: _accentColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PublicacionService.cambiarEstadoPublicacion(idGenera, nuevoEstado);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Estado cambiado a $nuevoEstado',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green[700],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${e.toString()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red[700],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}