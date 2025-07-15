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
        title: Text(publicacion.titulo),
        backgroundColor: const Color(0xFF0E3E8B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            _buildHeader(context),
            const SizedBox(height: 24),

            // Descripción detallada
            _buildDescriptionSection(),
            const SizedBox(height: 24),

            // Detalles de la oferta
            _buildJobDetails(),
            const SizedBox(height: 24),

            // Requisitos
            _buildRequirementsSection(),
            const SizedBox(height: 32),

            // Botón de postulación
            _buildApplyButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo/icono
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF0E3E8B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF0E3E8B).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.business_center,
            color: Color(0xFF0E3E8B),
            size: 30,
          ),
        ),
        const SizedBox(width: 16),

        // Título y contratante
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publicacion.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Publicado por: ${publicacion.nombreCompletoContratante}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción del puesto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          publicacion.descripcion,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildJobDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildDetailItem(Icons.attach_money, 'Salario ofrecido', '\$${publicacion.salario.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildDetailItem(Icons.location_on, 'Ubicación', publicacion.ubicacionCompleta),
          const Divider(height: 24),
          _buildDetailItem(Icons.date_range, 'Fecha límite', _formatDate(publicacion.fechaLimite)),
          const Divider(height: 24),
          _buildDetailItem(Icons.work, 'Jornada laboral', '${publicacion.jornada} - ${publicacion.turno}'),
          const Divider(height: 24),
          _buildDetailItem(Icons.check_circle, 'Disponibilidad', publicacion.disponibilidadInmediata ? "Inmediata" : "No inmediata"),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0E3E8B)),
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

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requisitos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          publicacion.requisitos,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0E3E8B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          _postularse(context);
        },
        child: const Text(
          'POSTULARSE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _postularse(BuildContext context) {
    // Aquí implementarías la lógica de postulación
    // usando el idAspirante y publicacion.idGenera

    showDialog(
      context: context,
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