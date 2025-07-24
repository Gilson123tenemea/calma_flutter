import 'package:calma/servicios/auth_service.dart';
import 'package:calma/servicios/session_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/login_screen.dart';

class ProfileScreenContratante extends StatefulWidget {
  final int specificId;
  const ProfileScreenContratante({super.key, required this.specificId});

  @override
  _ProfileScreenContratanteState createState() => _ProfileScreenContratanteState();
}

class _ProfileScreenContratanteState extends State<ProfileScreenContratante> {
  Map<String, dynamic>? contratanteData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchContratanteData();
  }

  Future<void> _fetchContratanteData() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/registro/contratante/detalle-completo/${widget.specificId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          contratanteData = json.decode(response.body);
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
                // Obtener el token FCM antes de limpiar la sesión
                final session = await SessionService().getSession();
                final fcmToken = session['fcmToken'] as String?;

                // Llamar al servicio de logout
                await AuthService.logout();

                // Eliminar el token del backend si existe
                if (fcmToken != null) {
                  try {
                    await http.delete(
                      Uri.parse('${AppConfig.baseUrl}/api/dispositivos/$fcmToken'),
                    );
                  } catch (e) {
                    debugPrint('Error eliminando token FCM: $e');
                  }
                }

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
        backgroundColor: const Color(0xFF0A2647), // Azul oscuro
        title: Center(
          child: Text(
            'Perfil del Contratante',
            style: const TextStyle(
              color: Colors.white, // Cambia el color aquí
            ),
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
                backgroundImage: contratanteData?['contratante']['foto'] != null
                    ? NetworkImage(contratanteData?['contratante']['foto'])
                    : null,
                child: contratanteData?['contratante']['foto'] == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${contratanteData?['contratante']['nombre']} ${contratanteData?['contratante']['apellido']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2647),
                ),
              ),
            ),
            Center(
              child: Text(
                contratanteData?['contratante']['ocupacion'] ?? 'Sin ocupación',
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
                  icon: Icons.email,
                  label: 'Email',
                  value: contratanteData?['contratante']['correo'] ?? 'No especificado',
                ),
                _buildInfoItem(
                  icon: Icons.phone,
                  label: 'Teléfono',
                  value: 'No especificado', // Agrega este campo a tu API si lo necesitas
                ),
                _buildInfoItem(
                  icon: Icons.cake,
                  label: 'Fecha de Nacimiento',
                  value: contratanteData?['contratante']['fechaNacimiento'] != null
                      ? DateTime.parse(contratanteData?['contratante']['fechaNacimiento']).toString().split(' ')[0]
                      : 'No especificado',
                ),
                _buildInfoItem(
                  icon: Icons.transgender,
                  label: 'Género',
                  value: contratanteData?['contratante']['genero'] ?? 'No especificado',
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
                  value: contratanteData?['contratante']['nombreProvincia'] ?? 'No especificado',
                ),
                _buildInfoItem(
                  icon: Icons.location_city,
                  label: 'Cantón',
                  value: contratanteData?['contratante']['nombreCanton'] ?? 'No especificado',
                ),
                _buildInfoItem(
                  icon: Icons.place,
                  label: 'Parroquia',
                  value: contratanteData?['contratante']['nombreParroquia'] ?? 'No especificado',
                ),
              ],
            ),
            if (contratanteData?['empresa']['tieneEmpresa'] == true) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                title: 'Información de Empresa',
                children: [
                  _buildInfoItem(
                    icon: Icons.business,
                    label: 'Nombre',
                    value: contratanteData?['empresa']['nombre'] ?? 'No especificado',
                  ),
                  _buildInfoItem(
                    icon: Icons.assignment_ind,
                    label: 'RUC',
                    value: contratanteData?['empresa']['ruc'] ?? 'No especificado',
                  ),
                  _buildInfoItem(
                    icon: Icons.email,
                    label: 'Correo Empresa',
                    value: contratanteData?['empresa']['correo'] ?? 'No especificado',
                  ),
                ],
              ),
            ],
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