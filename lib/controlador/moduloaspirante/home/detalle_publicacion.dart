import 'package:calma/servicios/verpublicaciones_emple_aspi.dart';
import 'package:flutter/material.dart';

class DetallePublicacionView extends StatelessWidget {
  final PublicacionGenerada publicacion;
  final int idAspirante;

  const DetallePublicacionView({
    super.key,
    required this.publicacion,
    required this.idAspirante,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Empleo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0E1E3A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con título y contratante - AHORA OCUPANDO TODO EL ANCHO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1E3A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publicacion.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Publicado por: ${publicacion.nombreCompletoContratante}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección de descripción
            _buildSectionTitle('Descripción del puesto'),
            _buildContentCard(publicacion.descripcion),
            const SizedBox(height: 16),

            // Detalles principales
            _buildSectionTitle('Detalles del empleo'),
            _buildJobDetailsCard(),
            const SizedBox(height: 16),

            // Actividades
            _buildSectionTitle('Actividades a realizar'),
            _buildActivitiesList(),
            const SizedBox(height: 16),

            // Requisitos
            _buildSectionTitle('Requisitos'),
            _buildContentCard(publicacion.requisitos),
            const SizedBox(height: 16),

            // Ubicación
            _buildSectionTitle('Ubicación'),
            _buildLocationCard(),
            const SizedBox(height: 16),

            // Datos del contratante
            _buildSectionTitle('Datos del contratante'),
            _buildContractorInfo(),
            const SizedBox(height: 24),

            // Botón de postulación - MEJORADO
            Container(
              width: double.infinity,
              height: 60,  // Altura aumentada
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E1E3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                onPressed: () {
                  _postularse(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'POSTULARSE AHORA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0E1E3A),
        ),
      ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildJobDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.attach_money, 'Salario estimado', '\$${publicacion.salario.toStringAsFixed(2)}', Colors.amber),
          const Divider(height: 24),
          _buildDetailRow(Icons.calendar_today, 'Fecha límite', _formatDate(publicacion.fechaLimite), Colors.blue),
          const Divider(height: 24),
          _buildDetailRow(Icons.schedule, 'Jornada', publicacion.jornada.isNotEmpty ? publicacion.jornada : 'No especificada', Colors.green),
          const Divider(height: 24),
          _buildDetailRow(Icons.timelapse, 'Turno', publicacion.turno, Colors.purple),
          const Divider(height: 24),
          _buildDetailRow(Icons.check_circle, 'Disponibilidad', publicacion.disponibilidadInmediata ? "Inmediata" : "No inmediata", publicacion.disponibilidadInmediata ? Colors.green : Colors.orange),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...publicacion.actividadesRealizar.split(', ').map((actividad) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1E3A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Color(0xFF0E1E3A)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      actividad,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationItem(Icons.location_city, 'Parroquia', publicacion.nombreParroquia),
          const Divider(height: 16),
          _buildLocationItem(Icons.map, 'Cantón', publicacion.nombreCanton),
          const Divider(height: 16),
          _buildLocationItem(Icons.public, 'Provincia', publicacion.nombreProvincia),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0E1E3A), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContractorInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContractorDetail(Icons.person, 'Nombre', publicacion.nombreCompletoContratante),
          const Divider(height: 16),
          _buildContractorDetail(Icons.email, 'Correo electrónico', 'No disponible'), // Modificar según tus datos
        ],
      ),
    );
  }

  Widget _buildContractorDetail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0E1E3A), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _postularse(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar postulación'),
        content: const Text('¿Estás seguro que deseas postularte a este empleo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E1E3A),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showPostulacionExitosa(context);
            },
            child: const Text('Postularme'),
          ),
        ],
      ),
    );
  }

  void _showPostulacionExitosa(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Postulación exitosa'),
        content: const Text('Tu postulación ha sido enviada correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Cierra también el detalle
            },
            child: const Text('Aceptar'),
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