import 'package:calma/controlador/moduloaspirante/navigation/bottom_nav_bar.dart';
import 'package:calma/controlador/modulocontratante/navigation/bottom_nav_bar_contratante.dart';
import 'package:calma/servicios/session_service.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';

class TerminosCondiciones extends StatefulWidget {
  const TerminosCondiciones({Key? key}) : super(key: key);

  @override
  _TerminosCondicionesState createState() => _TerminosCondicionesState();
}

class _TerminosCondicionesState extends State<TerminosCondiciones>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAccepted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (_isAccepted) {
      // Marcar términos como aceptados
      await SessionService().acceptTerms();

      // Verificar si hay sesión activa
      final session = await SessionService().getSession();
      final bool isLoggedIn = session['isLoggedIn'] as bool;
      final String rol = session['rol'] as String;
      final int specificId = session['specificId'] as int;

      if (isLoggedIn) {
        // Redirigir al módulo correspondiente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => rol == 'aspirante'
                ? GoogleBottomBarAspirante(idAspirante: specificId)
                : GoogleBottomBarContratante(specificId: specificId),
          ),
        );
      } else {
        // Ir al login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF1E3A8A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: Color(0xFF1E3A8A),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CALMA',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              Text(
                                'Términos y Condiciones',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

                      // Contenido scrolleable
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                'Bienvenido a CALMA',
                                'Nuestra aplicación está diseñada para brindar el mejor cuidado geriátrico, conectando familias con profesionales especializados en el cuidado de adultos mayores.',
                              ),

                              _buildSection(
                                'Uso de la Aplicación',
                                'Al utilizar CALMA, usted acepta usar la aplicación de manera responsable y de acuerdo con las leyes aplicables. Esta aplicación está destinada exclusivamente para el cuidado y bienestar de adultos mayores.',
                              ),

                              _buildSection(
                                'Privacidad y Datos',
                                'La privacidad de nuestros usuarios es fundamental. Toda la información personal y médica será tratada con la máxima confidencialidad y de acuerdo con las leyes de protección de datos vigentes.',
                              ),

                              _buildSection(
                                'Servicios Médicos',
                                'CALMA facilita la conexión con profesionales de la salud, pero no sustituye la consulta médica presencial. Siempre consulte con un profesional de la salud para decisiones médicas importantes.',
                              ),

                              _buildSection(
                                'Responsabilidad',
                                'Los usuarios son responsables de proporcionar información precisa y actualizada. CALMA no se hace responsable por el mal uso de la aplicación o por información incorrecta proporcionada por los usuarios.',
                              ),

                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Checkbox y botón
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _isAccepted,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isAccepted = value ?? false;
                                    });
                                  },
                                  activeColor: Color(0xFF1E3A8A),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAccepted = !_isAccepted;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: Text(
                                        'He leído y acepto los términos y condiciones de uso de CALMA.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // Botón Continuar
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isAccepted ? _handleContinue : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: _isAccepted ? 2 : 0,
                                ),
                                child: Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}