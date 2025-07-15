import 'package:calma/servicios/session_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int idAspirante;
  const ProfileScreen({super.key, required this.idAspirante});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? aspiranteData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAspiranteData();
  }

  Future<void> _fetchAspiranteData() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/registro/aspirante/detalle/${widget.idAspirante}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          aspiranteData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar los datos: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error de conexión: $e';
      });
    }
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cierre de sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sí, cerrar sesión', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Limpiar la sesión primero
                await SessionService().clearSession();

                // Redirigir al login
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2647),
        title: const Center(
          child: Text(
            'Perfil del Aspirante',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF0A2647),
                backgroundImage: aspiranteData?['aspirante']['foto'] != null
                    ? NetworkImage('${AppConfig.baseUrl}/api/registro/${aspiranteData?['aspirante']['foto']}')
                    : null,
                child: aspiranteData?['aspirante']['foto'] == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${aspiranteData?['aspirante']['nombre']} ${aspiranteData?['aspirante']['apellido']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2647),
                ),
              ),
            ),
            Center(
              child: Text(
                aspiranteData?['aspirante']['tipoContrato'] ?? 'Tiempo completo',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'Información Personal',
              children: [
                _buildInfoItem(
                  icon: Icons.credit_card,
                  label: 'Cédula',
                  value: aspiranteData?['aspirante']['cedula'] ?? 'No especificada',
                ),
                _buildInfoItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: aspiranteData?['aspirante']['correo'] ?? 'No especificado',
                ),
                _buildInfoItem(
                  icon: Icons.cake,
                  label: 'Fecha de Nacimiento',
                  value: aspiranteData?['aspirante']['fechaNacimiento'] != null
                      ? DateTime.parse(aspiranteData?['aspirante']['fechaNacimiento']).toString().split(' ')[0]
                      : 'No especificado',
                ),
                _buildInfoItem(
                  icon: Icons.transgender,
                  label: 'Género',
                  value: aspiranteData?['aspirante']['genero'] ?? 'No especificado',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Ubicación',
              children: [
                _buildInfoItem(
                  icon: Icons.location_on,
                  label: 'Provincia',
                  value: aspiranteData?['aspirante']['nombreProvincia'] ?? 'No especificada',
                ),
                _buildInfoItem(
                  icon: Icons.location_city,
                  label: 'Cantón',
                  value: aspiranteData?['aspirante']['nombreCanton'] ?? 'No especificado',
                ),
                _buildInfoItem(
                  icon: Icons.place,
                  label: 'Parroquia',
                  value: aspiranteData?['aspirante']['nombreParroquia'] ?? 'No especificada',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Detalles Profesionales',
              children: [
                _buildInfoItem(
                  icon: Icons.attach_money,
                  label: 'Aspiración Salarial',
                  value: '\$${aspiranteData?['aspirante']['aspiracionSalarial']?.toStringAsFixed(2) ?? '0.00'}',
                ),
                _buildInfoItem(
                  icon: Icons.work,
                  label: 'Disponibilidad',
                  value: aspiranteData?['aspirante']['disponibilidad'] == true ? 'Disponible' : 'No disponible',
                ),
                _buildInfoItem(
                  icon: Icons.assignment,
                  label: 'Tipo de Contrato',
                  value: aspiranteData?['aspirante']['tipoContrato'] ?? 'No especificado',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2647),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0A2647)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}