import 'dart:async';
import 'package:calma/servicios/notificaciones_servicios.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';

class GoogleBottomBarAspirante extends StatefulWidget {
  final int idAspirante;

  const GoogleBottomBarAspirante({super.key, required this.idAspirante});

  @override
  State<GoogleBottomBarAspirante> createState() => _GoogleBottomBarAspiranteState();
}

class _GoogleBottomBarAspiranteState extends State<GoogleBottomBarAspirante> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  int _notificacionesNoLeidas = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(idAspirante: widget.idAspirante),
      FavoritesScreen(idAspirante: widget.idAspirante),
      SearchScreen(idAspirante: widget.idAspirante),
      ProfileScreen(idAspirante: widget.idAspirante),
    ];
    _cargarNotificacionesNoLeidas();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _cargarNotificacionesNoLeidas();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _cargarNotificacionesNoLeidas() async {
    try {
      final count = await NotificacionesService().obtenerCantidadNoLeidasAspirante(widget.idAspirante);
      if (mounted) {
        setState(() {
          _notificacionesNoLeidas = count;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar notificaciones no leídas: $e');
    }
  }

  Widget _buildIconoNotificaciones() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications),
        if (_notificacionesNoLeidas > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _notificacionesNoLeidas.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  List<SalomonBottomBarItem> get _navBarItems => [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home),
      title: const Text("Empleos"),
      selectedColor: Colors.purple,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.favorite_border),
      title: const Text("Postulaciones"),
      selectedColor: Colors.pink,
    ),
    SalomonBottomBarItem(
      icon: _buildIconoNotificaciones(),
      title: const Text("Notificaciones"),
      selectedColor: Colors.orange,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.person),
      title: const Text("Perfil"),
      selectedColor: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          if (index == 2) { // Si es la pestaña de notificaciones
            _cargarNotificacionesNoLeidas(); // Actualiza el contador
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navBarItems,
      ),
    );
  }
}