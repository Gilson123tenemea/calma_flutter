import 'package:calma/servicios/IAService.dart';
import 'package:flutter/material.dart';

class IAChatWidget extends StatefulWidget {
  final int? idPublicacion;
  final String? tituloPublicacion;

  const IAChatWidget({
    Key? key,
    this.idPublicacion,
    this.tituloPublicacion,
  }) : super(key: key);

  @override
  _IAChatWidgetState createState() => _IAChatWidgetState();
}

class _IAChatWidgetState extends State<IAChatWidget> {
  final IAService _iaService = IAService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFF0A2647);
  final Color _accentColor = const Color(0xFF2C74B3);

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    String welcomeText = '''¡Hola! 👋 Soy tu asistente de IA para Calma.

Puedo ayudarte con:
• ℹ️ Información general sobre Calma
• 💼 Análisis de candidatos para tus publicaciones
• 📊 Estadísticas de postulaciones
• 🤖 Recomendaciones personalizadas

¿En qué puedo ayudarte hoy?''';

    setState(() {
      _messages.add(ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Detectar tipo de consulta
      final String lowerText = text.toLowerCase();
      Map<String, dynamic> response;

      if (_shouldUseJobRecommendation(lowerText)) {
        // Usar recomendación de candidatos si hay publicación seleccionada
        if (widget.idPublicacion != null) {
          response = await _iaService.obtenerRecomendacionIA(
            idPublicacion: widget.idPublicacion!,
            criterios: text,
          );
        } else {
          response = {
            'success': false,
            'error': 'Para obtener recomendaciones de candidatos, necesito que selecciones una publicación específica.',
          };
        }
      } else if (_shouldUseStatistics(lowerText)) {
        // Usar estadísticas si hay publicación seleccionada
        if (widget.idPublicacion != null) {
          response = await _iaService.obtenerEstadisticasCandidatos(widget.idPublicacion!);
          if (response['success'] == true) {
            response['respuesta'] = _formatStatisticsResponse(response);
          }
        } else {
          response = {
            'success': false,
            'error': 'Para obtener estadísticas, necesito que selecciones una publicación específica.',
          };
        }
      } else {
        // Usar chatbot general
        response = await _iaService.preguntarChatbot(pregunta: text);
      }

      setState(() {
        if (response['success'] == true) {
          _messages.add(ChatMessage(
            text: response['respuesta'] ?? 'No se pudo obtener respuesta',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        } else {
          _messages.add(ChatMessage(
            text: '❌ ${response['error'] ?? 'Error desconocido'}',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Error de conexión: $e',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  bool _shouldUseJobRecommendation(String text) {
    final keywords = [
      'recomienda', 'candidato', 'aspirante', 'mejor', 'elegir',
      'seleccionar', 'contratar', 'perfil', 'experiencia',
      'recomendación', 'análisis', 'evalúa', 'quien'
    ];
    return keywords.any((keyword) => text.contains(keyword));
  }

  bool _shouldUseStatistics(String text) {
    final keywords = [
      'estadística', 'cuántos', 'total', 'porcentaje', 'promedio',
      'cantidad', 'número', 'datos', 'métricas', 'resumen'
    ];
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _formatStatisticsResponse(Map<String, dynamic> stats) {
    return '''📊 **Estadísticas de Candidatos**

👥 **Total de candidatos:** ${stats['totalCandidatos']}
⭐ **Promedio de calificaciones:** ${stats['promedioCalificaciones']} estrellas
✅ **Candidatos disponibles:** ${stats['candidatosDisponibles']} (${stats['porcentajeDisponibilidad']}%)
🎯 **Con experiencia previa:** ${stats['candidatosConExperiencia']} (${stats['porcentajeExperiencia']}%)
🆕 **Sin experiencia:** ${stats['candidatosSinExperiencia']}
⏰ **No disponibles inmediatamente:** ${stats['candidatosNoDisponibles']}

${stats['totalCandidatos'] > 0 ? '¡Tienes candidatos interesados! ¿Te gustaría que analice cuál sería el mejor para tu trabajo?' : 'Aún no hay candidatos para esta publicación.'}''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asistente IA de Calma',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.tituloPublicacion != null)
                        Text(
                          'Contexto: ${widget.tituloPublicacion}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pensando...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Pregúntame sobre candidatos, estadísticas o Calma...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: message.isError ? Colors.red[100] : _accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.isError ? Icons.error_outline : Icons.smart_toy,
                size: 18,
                color: message.isError ? Colors.red : _accentColor,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? _accentColor
                    : message.isError
                    ? Colors.red[50]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : message.isError
                          ? Colors.red[800]
                          : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white70
                          : Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}