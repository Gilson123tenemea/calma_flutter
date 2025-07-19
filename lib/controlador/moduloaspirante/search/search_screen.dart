import 'package:flutter/material.dart';
import 'package:calma/servicios/notificaciones_servicios.dart';

class SearchScreen extends StatefulWidget {
  final int idAspirante;

  const SearchScreen({super.key, required this.idAspirante});

  @override
  _NotificacionesAspiranteScreenState createState() => _NotificacionesAspiranteScreenState();
}

class _NotificacionesAspiranteScreenState extends State<SearchScreen> {
  final NotificacionesService _notificacionesService = NotificacionesService();
  List<Notificaciones> _notificaciones = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final Color _primaryColor = const Color(0xFF0A2647);
  final Color _accentColor = const Color(0xFF2C74B3);

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final notificaciones = await _notificacionesService.obtenerNotificacionesAspirante(widget.idAspirante);

      // Ordenar por fecha descendente
      notificaciones.sort((a, b) => b.fecha.compareTo(a.fecha));

      setState(() {
        _notificaciones = notificaciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _marcarTodasComoLeidas() async {
    try {
      await _notificacionesService.marcarTodasLeidasAspirante(widget.idAspirante);
      await _cargarNotificaciones();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Todas las notificaciones marcadas como leídas'),
          backgroundColor: _accentColor,
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
  }

  Future<void> _marcarComoLeida(int idNotificacion) async {
    try {
      await _notificacionesService.marcarComoLeida(idNotificacion);
      await _cargarNotificaciones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al marcar como leída: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Notificaciones',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: _primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist, color: Colors.white),
            onPressed: _marcarTodasComoLeidas,
            tooltip: 'Marcar todas como leídas',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarNotificaciones,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _notificaciones.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes notificaciones',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _cargarNotificaciones,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _notificaciones.length,
          itemBuilder: (context, index) {
            final notificacion = _notificaciones[index];
            return _buildNotificacionCard(notificacion);
          },
        ),
      ),
    );
  }

  Widget _buildNotificacionCard(Notificaciones notificacion) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: notificacion.leida ? Colors.grey[100] : Colors.blue[50],
      child: InkWell(
        onTap: notificacion.id != null
            ? () => _marcarComoLeida(notificacion.id!)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    notificacion.leida ? Icons.mark_email_read : Icons.mark_email_unread,
                    color: notificacion.leida ? Colors.grey : _accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notificacion.descripcion,
                      style: TextStyle(
                        fontWeight: notificacion.leida ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatFecha(notificacion.fecha),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}