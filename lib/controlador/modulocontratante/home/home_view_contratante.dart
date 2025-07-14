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
  final Color _cardColor = const Color(0xFFF8F9FA);
  final Color _accentColor = const Color(0xFF0A2647);
  final Color _textColor = Colors.black87;

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
        title: Center(
          child: const Text(
            'Mis Publicaciones',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: _accentColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _publicacionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay publicaciones disponibles', style: TextStyle(color: _textColor)));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var publicacion = snapshot.data![index];
                  var empleo = publicacion['publicacionempleo'];
                  var parroquia = empleo['parroquia'];
                  var ubicacion = '${parroquia['nombre']}, ${parroquia['canton']['nombre']}';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: _cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  empleo['titulo'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                              ),
                              _buildEstadoChip(empleo['estado']),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            empleo['descripcion'],
                            style: TextStyle(color: _textColor.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.work, 'Jornada: ${empleo['jornada']}'),
                          _buildInfoRow(Icons.attach_money, 'Salario: \$${empleo['salario_estimado']}'),
                          _buildInfoRow(Icons.location_on, 'Ubicación: $ubicacion'),
                          _buildInfoRow(
                            Icons.access_time,
                            'Disponibilidad: ${empleo['disponibilidad_inmediata'] ? 'Inmediata' : 'Programada'}',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Editar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _accentColor,
                                  side: BorderSide(color: _accentColor),
                                ),
                                onPressed: () {
                                  // Lógica para editar
                                },
                              ),
                              ElevatedButton.icon(
                                icon: Icon(
                                  empleo['estado'] == 'Activo' ? Icons.toggle_on : Icons.toggle_off,
                                  size: 18,
                                  color: empleo['estado'] == 'Activo' ? Colors.green : Colors.red,
                                ),
                                label: Text(
                                  empleo['estado'] == 'Activo' ? 'Desactivar' : 'Activar',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: empleo['estado'] == 'Activo' ? Colors.red : Colors.green,
                                ),
                                onPressed: () {
                                  _cambiarEstadoPublicacion(publicacion['id_genera'], empleo['estado']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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



  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _textColor.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: _textColor.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    return Chip(
      label: Text(
        estado,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: estado == 'Activo' ? Colors.green : Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  void _cambiarEstadoPublicacion(int idGenera, String estadoActual) async {
    final nuevoEstado = estadoActual == 'Activo' ? 'Inactivo' : 'Activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambio'),
        content: Text('¿Cambiar estado a $nuevoEstado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PublicacionService.cambiarEstadoPublicacion(idGenera, nuevoEstado);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Estado cambiado a $nuevoEstado'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }


}