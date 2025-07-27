import 'package:calma/controlador/moduloaspirante/PostulacionesNotifier.dart';
import 'package:calma/controlador/moduloaspirante/home/detalle_publicacion.dart';
import 'package:calma/servicios/notificaciones_servicios.dart';
import 'package:calma/servicios/verpublicaciones_emple_aspi.dart';
import 'package:flutter/material.dart';
import 'package:calma/servicios/realizar_service.dart';

class HomeView extends StatefulWidget {
  final int idAspirante;
  const HomeView({super.key, required this.idAspirante});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<PublicacionGenerada>> _futurePublicaciones;
  final PublicacionService _publicacionService = PublicacionService();

  @override
  void initState() {
    super.initState();
    _cargarPublicaciones();
  }

  void _cargarPublicaciones() {
    setState(() {
      _futurePublicaciones = _publicacionService.obtenerPublicacionesNoPostuladas(widget.idAspirante);
    });
  }

  Future<void> _refrescarPublicaciones() async {
    print('🔄 Refrescando publicaciones...');
    setState(() {
      _futurePublicaciones = _publicacionService.obtenerPublicacionesNoPostuladas(widget.idAspirante);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Empleos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF0E1E3A), // Azul oscuro exacto
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refrescarPublicaciones,
            tooltip: 'Actualizar empleos',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refrescarPublicaciones,
        color: const Color(0xFF0E1E3A),
        child: FutureBuilder<List<PublicacionGenerada>>(
          future: _futurePublicaciones,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator();
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            } else {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: snapshot.data!.map((publicacion) =>
                    _buildJobCard(publicacion, context, widget.idAspirante)
                ).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E1E3A)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando empleos...',
            style: TextStyle(
              color: Color(0xFF0E1E3A),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar empleos',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0E1E3A),
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
                backgroundColor: const Color(0xFF0E1E3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _refrescarPublicaciones,
              child: const Text(
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
            const Icon(Icons.work_outline, size: 50, color: Color(0xFF0E1E3A)),
            const SizedBox(height: 16),
            const Text(
              'No hay empleos disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0E1E3A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa más tarde o ajusta tus filtros de búsqueda',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1E3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _refrescarPublicaciones,
              child: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(PublicacionGenerada publicacion, BuildContext context, int idAspirante) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1E3A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                publicacion.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Nombre del contratante
              Text(
                'Publicado por: ${publicacion.nombreCompletoContratante}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),

              // Divider con estilo
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 12),

              // Salario estimado - RESALTADO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber[700]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber[700]!.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 20, color: Colors.amber[300]),
                    const SizedBox(width: 8),
                    Text(
                      'Salario estimado: \$${publicacion.salario.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Ubicación - RESALTADA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[900]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Ubicación:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(
                        '${publicacion.nombreParroquia}, ${publicacion.nombreCanton}, ${publicacion.nombreProvincia}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Actividades a realizar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Actividades:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: publicacion.actividadesRealizar.split(', ').map((actividad) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          actividad,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
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
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                        'VER DETALLES',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _postularse(context, publicacion, idAspirante);
                      },
                      child: const Text(
                        'POSTULARSE',
                        style: TextStyle(
                          color: Color(0xFF0E1E3A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _postularse(BuildContext context, PublicacionGenerada publicacion, int idAspirante) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Postulación'),
        content: const Text('¿Estás seguro que deseas postularte a este empleo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
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
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Procesando postulación...'),
          ],
        ),
      ),
    );

    try {
      // 1. Realizar la postulación
      final realizarService = RealizarService();
      final resultado = await realizarService.postularAEmpleo(idAspirante, publicacion.idGenera);

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      print('🟢 Resultado de postulación: $resultado');

      if (resultado['success'] == true) {
        // 2. Manejar respuesta exitosa
        try {
          // Intentar obtener datos para la notificación si están disponibles
          final postulacionData = resultado['data'];
          String nombreAspirante = 'Usuario'; // Valor por defecto
          int? idPostulacion;

          // Intentar extraer información si está disponible
          if (postulacionData != null && postulacionData is Map) {
            try {
              if (postulacionData.containsKey('aspirante') &&
                  postulacionData['aspirante'] != null &&
                  postulacionData['aspirante']['usuario'] != null) {
                final usuario = postulacionData['aspirante']['usuario'];
                nombreAspirante = '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
              }

              if (postulacionData.containsKey('postulacion') &&
                  postulacionData['postulacion'] != null) {
                idPostulacion = postulacionData['postulacion']['id_postulacion'];
              } else if (postulacionData.containsKey('id_realizar')) {
                idPostulacion = postulacionData['id_realizar'];
              }
            } catch (e) {
              print('🟠 Error extrayendo datos de postulación: $e');
            }
          }

          // 3. Crear y enviar notificación al contratante
          try {
            final notificacion = Notificaciones(
              descripcion: 'El aspirante $nombreAspirante ha postulado a: ${publicacion.titulo}',
              idContratante: publicacion.idContratante,
              idAspirante: idAspirante,
              idPostulacion: idPostulacion,
              fecha: DateTime.now(),
            );

            final notificacionService = NotificacionesService();
            await notificacionService.crearNotificacion(notificacion);
          } catch (e) {
            print('🟠 Error enviando notificación: $e');
            // No fallar por esto, la postulación ya se realizó
          }

          // 4. Mostrar feedback exitoso al usuario
          final mensaje = resultado['warning'] != null
              ? 'Postulación exitosa (${resultado['warning']})'
              : resultado['message'] ?? '¡Postulación exitosa!';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // 5. ✨ ACTUALIZAR LA LISTA INMEDIATAMENTE ✨
          print('🔄 Actualizando lista después de postulación exitosa...');
          _refrescarPublicaciones();

          // ✨ NUEVA LÍNEA: Notificar a la pantalla de postulaciones
          PostulacionesNotifier().notifyPostulacionRealizada();

        } catch (e) {
          print('🟠 Error en procesamiento post-postulación: $e');
          // Mostrar mensaje de éxito simple y actualizar lista
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Postulación exitosa!'),
              backgroundColor: Colors.green,
            ),
          );

          // Actualizar lista incluso si hay errores secundarios
          _refrescarPublicaciones();

          // ✨ NUEVA LÍNEA: Notificar incluso en caso de error secundario
          PostulacionesNotifier().notifyPostulacionRealizada();
        }

      } else {
        // Manejar errores
        final mensajeError = resultado['message'] ?? 'Error desconocido al postular';

        // Diferentes colores según el tipo de error
        Color backgroundColor = Colors.red;
        if (mensajeError.contains('Ya te has postulado') ||
            mensajeError.contains('Ya se ha postulado')) {
          backgroundColor = Colors.orange;
          // Si ya se postuló, también actualizar la lista para quitar la publicación
          _refrescarPublicaciones();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 4),
            action: resultado['shouldRetry'] != false
                ? SnackBarAction(
              label: 'Reintentar',
              onPressed: () => _postularse(context, publicacion, idAspirante),
            )
                : null,
          ),
        );
      }

    } catch (e) {
      // Cerrar diálogo de carga si aún está abierto
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('🔴 Error general en _postularse: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () => _postularse(context, publicacion, idAspirante),
          ),
        ),
      );
    }
  }

  Future<void> enviarNotificacion(int idContratante, String tituloPublicacion, String nombreAspirante) async {
    // Implementación si es necesaria
  }
}