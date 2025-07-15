import 'package:calma/controlador/moduloaspirante/navigation/bottom_nav_bar.dart';
import 'package:calma/controlador/modulocontratante/navigation/bottom_nav_bar_contratante.dart';
import 'package:calma/login_screen.dart';
import 'package:calma/servicios/session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'terminos_condiciones.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _holeController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _holeAnimation;
  late Animation<double> _logoYAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Configura la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Controlador para el hueco oval
    _holeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Controlador para el logo
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Controlador para el texto
    _textController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Animación del hueco oval
    _holeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _holeController,
      curve: Curves.easeOut,
    ));

    // Animación del movimiento vertical del logo
    _logoYAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -20.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -20.0, end: 10.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: -30.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
    ]).animate(_logoController);

    // Animación del escalado del logo
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0,
      ),
    ]).animate(_logoController);

    // Animación de opacidad del texto
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimationSequence() async {
    // Espera inicial
    await Future.delayed(Duration(milliseconds: 300));

    // Inicia la animación del hueco
    _holeController.forward();

    // Espera un poco y luego inicia la animación del logo
    await Future.delayed(Duration(milliseconds: 400));
    _logoController.forward();

    // Espera a que termine la animación del logo y luego muestra el texto
    await Future.delayed(Duration(milliseconds: 1200));
    _textController.forward();

    // Espera 2 segundos después de que aparezca el texto
    await Future.delayed(Duration(milliseconds: 2800));

    // Navega a la pantalla de términos y condiciones
    _navigateToTerminos();
  }

  Future<void> _checkSessionAndNavigate() async {
    final session = await SessionService().getSession();
    final bool termsAccepted = session['termsAccepted'] as bool;
    final bool isLoggedIn = session['isLoggedIn'] as bool;
    final String rol = session['rol'] as String;
    final int specificId = session['specificId'] as int;

    if (!termsAccepted) {
      // Mostrar términos si no han sido aceptados
      _navigateToTerminos();
    } else if (isLoggedIn) {
      // Redirigir al módulo correspondiente si hay sesión
      _navigateToHome(rol, specificId);
    } else {
      // Ir al login si no hay sesión pero términos ya aceptados
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToHome(String rol, int specificId) {
    Widget homeScreen = rol == 'aspirante'
        ? GoogleBottomBarAspirante(idAspirante: specificId)
        : GoogleBottomBarContratante(specificId: specificId);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => homeScreen),
    );
  }

  void _navigateToTerminos() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const TerminosCondiciones(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _holeController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo blanco
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),

          // Hueco oval gris animado
          AnimatedBuilder(
            animation: _holeAnimation,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 200 * _holeAnimation.value,
                  height: 160 * _holeAnimation.value,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle, // Usamos círculo por compatibilidad
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Logo animado
          AnimatedBuilder(
            animation: Listenable.merge([_logoController, _holeController]),
            builder: (context, child) {
              return Center(
                child: Transform.translate(
                  offset: Offset(0, _logoYAnimation.value),
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.elderly, // Ícono temporal relacionado con geriatría
                          size: 40,
                          color: Color(0xFF1E3A8A),
                        ),
                        // TODO: Reemplazar con tu logo cuando esté listo
                        // child: Image.asset(
                        //   'assets/images/logo_calma.png',
                        //   fit: BoxFit.contain,
                        // ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Texto animado
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return Center(
                child: Transform.translate(
                  offset: Offset(0, 120),
                  child: Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CALMA',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A), // Azul oscuro
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Cuidado geriátrico',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}