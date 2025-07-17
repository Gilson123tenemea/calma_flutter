import 'dart:convert';
import 'package:calma/controlador/moduloaspirante/navigation/bottom_nav_bar.dart';
import 'package:calma/servicios/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:calma/controlador/modulocontratante/navigation/bottom_nav_bar_contratante.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recoveryEmailController = TextEditingController();

  bool _isLoading = false;
  bool _isRecoveryLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_validateEmail(email)) {
      if (mounted) _showMessage('Por favor ingresa un correo válido');
      return;
    }

    if (!_validatePassword(password)) {
      if (mounted) _showMessage('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      debugPrint('Respuesta PROCESADA: $response');

      if (!mounted) return;

      final rol = (response['rol']?.toString() ?? '').toUpperCase();
      final userId = response['userId'] as int? ?? 0;
      final specificId = response['specificId'] as int? ?? 0;

      debugPrint('Datos VALIDADOS:');
      debugPrint('Rol: $rol');
      debugPrint('User ID: $userId');
      debugPrint('Specific ID: $specificId');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateBasedOnRole(
            rol: rol,
            userId: userId,
            specificId: specificId,
          );
          _showMessage('¡Acceso exitoso!');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error en login: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateBasedOnRole({
    required String rol,
    required int userId,
    required int specificId,
  }) {
    if (!mounted) return;

    debugPrint('=== INICIANDO NAVEGACIÓN ===');
    debugPrint('Rol: $rol');
    debugPrint('User ID: $userId');
    debugPrint('Specific ID: $specificId');

    try {
      if (rol == 'ASPIRANTE') {
        debugPrint('Navegando a módulo ASPIRANTE con ID: $specificId');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => GoogleBottomBarAspirante(idAspirante: specificId),
          ),
              (route) => false,
        );
      }
      else if (rol == 'CONTRATANTE') {
        debugPrint('Navegando a módulo CONTRATANTE con ID: $specificId');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => GoogleBottomBarContratante(specificId: specificId),
          ),
              (route) => false,
        );
      }
      else {
        throw Exception('Rol no reconocido: $rol');
      }
    } catch (e, stackTrace) {
      debugPrint('Error crítico en navegación: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showMessage('Error al navegar: ${e.toString()}');
      }
    }
  }


  Future<void> _handleRecovery() async {
    final email = _recoveryEmailController.text.trim();

    if (!_validateEmail(email)) {
      _showMessage('Correo inválido');
      return;
    }

    setState(() => _isRecoveryLoading = true);

    try {
      final userResponse = await http.get(
        Uri.parse('http://192.168.0.103:8090/api/usuarios/por-correo?correo=$email'),
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Correo no registrado');
      }

      final userData = jsonDecode(userResponse.body);
      final userId = userData['userId'];
      final userType = userData['userType'];

      final resetResponse = await http.post(
        Uri.parse('http://192.168.0.103:8090/api/password/request-reset'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'userId': userId.toString(), 'userType': userType},
      );

      if (resetResponse.statusCode == 200) {
        _showMessage('Se ha enviado un enlace de recuperación a $email');
        _recoveryEmailController.clear();
        Navigator.of(context).pop();
      } else {
        final errorMsg = resetResponse.body;
        throw Exception(errorMsg);
      }
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isRecoveryLoading = false);
    }
  }

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 8;
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showRecoveryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa tu correo para recuperar tu contraseña.'),
              const SizedBox(height: 10),
              TextField(
                controller: _recoveryEmailController,
                decoration: const InputDecoration(hintText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isRecoveryLoading ? null : _handleRecovery,
              child: _isRecoveryLoading
                  ? const CircularProgressIndicator()
                  : const Text('Enviar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CALMA',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Inicia sesión para continuar',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration('Correo'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration('Contraseña'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Iniciar sesión'),
                  ),
                  TextButton(
                    onPressed: _showRecoveryDialog,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro');
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}