import 'dart:convert';
import 'package:calma/configuracion/AppConfig.dart';
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
  bool _obscurePassword = true;

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
      // Usar AppConfig para obtener usuario por correo
      final userResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/usuarios/por-correo?correo=$email'),
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Correo no registrado');
      }

      final userData = jsonDecode(userResponse.body);
      final userId = userData['userId'];
      final userType = userData['userType'];

      // Usar AppConfig para el endpoint de reset de contraseña
      final resetResponse = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/password/request-reset'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Espacio arriba reducido

              // Elemento decorativo bonito arriba - MÁS ANCHO
              Container(
                width: double.infinity,
                height: 180, // Aumentado para más contenido
                margin: const EdgeInsets.symmetric(horizontal: 8), // Márgenes AÚN MÁS pequeños = MÁS ANCHO
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A2647),
                      Color(0xFF144272),
                      Color(0xFF205295),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Círculos decorativos más bonitos
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Icono geriátrico decorativo
                    Positioned(
                      top: 30,
                      right: 30,
                      child: Icon(
                        Icons.elderly,
                        color: Colors.white.withOpacity(0.2),
                        size: 50,
                      ),
                    ),
                    // Contenido mejorado centrado
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bienvenido a',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'CALMA',
                              style: GoogleFonts.montserrat(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 3.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Conectando cuidadores\nespecializados con familias',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Cuidado geriátrico profesional •',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30), // Espacio entre elemento decorativo y cuadro

              // Formulario de login - MÁS ANCHO
              Container(
                padding: const EdgeInsets.all(32), // Más padding
                margin: const EdgeInsets.symmetric(horizontal: 8), // Márgenes AÚN MÁS pequeños = MÁS ANCHO
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2647), // Fondo azul oscuro
                  borderRadius: BorderRadius.circular(20), // Bordes más redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Título dentro del cuadro azul
                    Column(
                      children: [
                        Text(
                          'Iniciar Sesión',
                          style: GoogleFonts.montserrat(
                            fontSize: 28, // Ajustado
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // Texto blanco
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa tus credenciales para continuar',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.white70, // Blanco translúcido
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32), // Espacio entre título y campos
                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration(
                        icon: Icons.email_outlined,
                        label: 'Correo Electrónico',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.montserrat(color: Colors.white), // Texto blanco
                    ),

                    const SizedBox(height: 16),

                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _buildInputDecoration(
                        icon: Icons.lock_outline,
                        label: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white54, // Icono blanco translúcido
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: GoogleFonts.montserrat(color: Colors.white), // Texto blanco
                    ),

                    const SizedBox(height: 8),

                    // Olvidé contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showRecoveryDialog,
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.white, // Texto blanco sobre fondo azul
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón de login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Botón blanco
                          foregroundColor: const Color(0xFF0A2647), // Texto azul
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0A2647), // Spinner azul
                          ),
                        )
                            : Text(
                          'INICIAR SESIÓN',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: const Color(0xFF0A2647), // Texto azul
                          ),
                        ),
                      ),
                    ),

                    // Eliminado el TextButton de registro
                  ],
                ),
              ),

              const SizedBox(height: 60), // Más espacio abajo
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required IconData icon,
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(
        color: Colors.white70, // Label blanco translúcido
      ),
      prefixIcon: Icon(icon, color: Colors.white), // Iconos blancos
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white54), // Borde blanco translúcido
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white54), // Borde blanco translúcido
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2), // Borde blanco cuando está enfocado
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1), // Fondo ligeramente blanco translúcido
    );
  }
}