import 'package:calma/controlador/moduloaspirante/home/detalle_publicacion.dart';
import 'package:calma/servicios/verpublicaciones_emple_aspi.dart';
import 'package:flutter/material.dart';
import 'package:calma/servicios/realizar_service.dart';

class HomeView extends StatelessWidget {
  final int idAspirante;
  const HomeView({super.key, required this.idAspirante});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar estilo LinkedIn
          SliverAppBar(
            backgroundColor: const Color(0xFF0E3E8B),
            pinned: true,
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Empleos Disponibles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              background: Container(
                color: const Color(0xFF0E3E8B),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FutureBuilder<List<PublicacionGenerada>>(
                future: PublicacionService().obtenerPublicacionesGeneradas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator();
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    return Column(
                      children: snapshot.data!.map((publicacion) =>
                          _buildJobCard(publicacion, context)
                      ).toList(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0E3E8B)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar empleos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E3E8B), // Cambiado de primary a backgroundColor
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              // Recargar
            },
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay empleos disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa más tarde o ajusta tus filtros de búsqueda',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(PublicacionGenerada publicacion, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navegar a detalles
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con logo y título
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder para logo de empresa
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3E8B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF0E3E8B).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: const Color(0xFF0E3E8B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          publicacion.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          publicacion.nombreCompletoContratante,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: publicacion.estado == 'Activo'
                          ? Colors.green[50]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: publicacion.estado == 'Activo'
                            ? Colors.green
                            : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      publicacion.estado,
                      style: TextStyle(
                        color: publicacion.estado == 'Activo'
                            ? Colors.green[800]
                            : Colors.grey[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                publicacion.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // Detalles en 2 columnas
              Row(
                children: [
                  Expanded(
                    child: _buildJobDetailItem(
                      Icons.attach_money,
                      'Salario',
                      '\$${publicacion.salario.toStringAsFixed(2)}',
                    ),
                  ),
                  Expanded(
                    child: _buildJobDetailItem(
                      Icons.location_on,
                      'Ubicación',
                      publicacion.nombreCanton,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildJobDetailItem(
                      Icons.date_range,
                      'Fecha límite',
                      _formatDate(publicacion.fechaLimite),
                    ),
                  ),
                  Expanded(
                    child: _buildJobDetailItem(
                      Icons.access_time,
                      'Jornada',
                      publicacion.jornada,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0E3E8B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetallePublicacionView(
                              publicacion: publicacion,
                              idAspirante: idAspirante,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'VER OFERTA',
                        style: TextStyle(color: Color(0xFF0E3E8B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E3E8B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _postularse(context, publicacion);
                      },
                      child: const Text(
                        'POSTULARSE',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ], // <-- Esta llave cierra el Column de children
          ), // <-- Esta llave cierra el Column principal
        ), // <-- Esta llave cierra el Padding
      ), // <-- Esta llave cierra el InkWell
    ); // <-- Esta llave cierra el Card
  }

  void _postularse(BuildContext context, PublicacionGenerada publicacion) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar postulación'),
        content: const Text('¿Estás seguro que deseas postularte a este empleo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Postularme'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final realizarService = RealizarService();
      final result = await realizarService.postularAEmpleo(
        idAspirante,
        publicacion.idGenera, // Usamos id directamente como en la versión web
      );

      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      // Mostrar resultado
      if (result['success'] == true) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Postulación exitosa!'),
            backgroundColor: Colors.green,
          ),
        );
        // Aquí podrías actualizar el estado para marcar como postulado
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al postular'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      Navigator.of(context).pop(); // Cerrar diálogo de carga en caso de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarMensajeExito(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Postulación exitosa'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarMensajeError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildJobDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF0E3E8B),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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