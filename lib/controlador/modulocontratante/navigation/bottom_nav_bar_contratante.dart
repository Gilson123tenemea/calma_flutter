import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../home/home_screen_contratante.dart';
import '../favorites/favorites_screen_contratante.dart';
import '../search/search_screen_contratante.dart';
import '../profile/profile_screen_contratante.dart';

class GoogleBottomBarContratante extends StatefulWidget {
  final int specificId; // Agrega este parámetro

  const GoogleBottomBarContratante({super.key, required this.specificId});

  @override
  State<GoogleBottomBarContratante> createState() => _GoogleBottomBarContratanteState();
}

class _GoogleBottomBarContratanteState extends State<GoogleBottomBarContratante> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreenContratante(specificId: widget.specificId),
      FavoritesScreenContratante(specificId: widget.specificId),
      SearchScreenContratante(specificId: widget.specificId),
      ProfileScreenContratante(specificId: widget.specificId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navBarItems,
      ),
    );
  }
}

final _navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home),
    title: const Text("Publicaciones"),
    selectedColor: Colors.blue,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.work),
    title: const Text("Postulaciones"),
    selectedColor: Colors.green,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.message),
    title: const Text("Crear Empleo"),
    selectedColor: Colors.orange,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    title: const Text("Perfil"),
    selectedColor: Colors.purple,
  ),
];