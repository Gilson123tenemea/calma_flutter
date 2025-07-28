import 'package:flutter/material.dart';

class FloatingIAButton extends StatefulWidget {
  final int contratanteId;

  const FloatingIAButton({
    Key? key,
    required this.contratanteId,
  }) : super(key: key);

  @override
  _FloatingIAButtonState createState() => _FloatingIAButtonState();
}

class _FloatingIAButtonState extends State<FloatingIAButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  final Color _primaryColor = const Color(0xFF0A2647);
  final Color _accentColor = const Color(0xFF2C74B3);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showIARecommendations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IARecommendationsScreen(
          contratanteId: widget.contratanteId,
        ),
      ),
    );
    _toggleExpanded(); // Cerrar el menú después de navegar
  }

  void _showQuickChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.all(16),
        child: const IAChatWidget(),
      ),
    );
    _toggleExpanded(); // Cerrar el menú después de mostrar el chat
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Overlay para cerrar el menú al tocar fuera
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

        // Opciones del menú
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_isExpanded) ...[
                    // Opción 1: Recomendaciones IA
                    Container(
                      margin: const EdgeInsets.only(bottom: 16, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Análisis de Candidatos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            heroTag: 'recommendations',
                            onPressed: _showIARecommendations,
                            backgroundColor: Colors.purple,
                            child: const Icon(Icons.psychology, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Opción 2: Chat rápido
                    Container(
                      margin: const EdgeInsets.only(bottom: 16, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Chat con IA',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            heroTag: 'chat',
                            onPressed: _showQuickChat,
                            backgroundColor: _accentColor,
                            child: const Icon(Icons.chat, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Botón principal
                  FloatingActionButton(
                    heroTag: 'main',
                    onPressed: _toggleExpanded,
                    backgroundColor: _isExpanded ? Colors.red : _primaryColor,
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.125 : 0, // 45 grados
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isExpanded ? Icons.close : Icons.smart_toy,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// Pantalla de recomendaciones IA (importar la que creamos anteriormente)
class IARecommendationsScreen extends StatelessWidget {
  final int contratanteId;

  const IARecommendationsScreen({
    Key? key,
    required this.contratanteId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aquí deberías importar y usar la pantalla IARecommendationsScreen
    // que creamos anteriormente
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendaciones IA'),
        backgroundColor: const Color(0xFF0A2647),
      ),
      body: const Center(
        child: Text('Pantalla de recomendaciones IA'),
      ),
    );
  }
}

// Widget de chat IA (una versión simplificada)
class IAChatWidget extends StatelessWidget {
  const IAChatWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Chat IA - Implementar funcionalidad completa'),
      ),
    );
  }
}