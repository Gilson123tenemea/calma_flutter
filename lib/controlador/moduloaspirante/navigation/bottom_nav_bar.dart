import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';

class GoogleBottomBarAspirante extends StatefulWidget {
  final int  idAspirante;

  const GoogleBottomBarAspirante({super.key, required this.idAspirante});

  @override
  State<GoogleBottomBarAspirante> createState() => _GoogleBottomBarAspiranteState();
}

class _GoogleBottomBarAspiranteState extends State<GoogleBottomBarAspirante> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
       HomeScreen(idAspirante: widget.idAspirante),
       FavoritesScreen(idAspirante: widget.idAspirante),
       SearchScreen(idAspirante: widget.idAspirante),
       ProfileScreen(idAspirante: widget.idAspirante),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Bottom Bar')),
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
    title: const Text("Home"),
    selectedColor: Colors.purple,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.favorite_border),
    title: const Text("Likes"),
    selectedColor: Colors.pink,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.search),
    title: const Text("Search"),
    selectedColor: Colors.orange,
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    title: const Text("Profile"),
    selectedColor: Colors.teal,
  ),
];