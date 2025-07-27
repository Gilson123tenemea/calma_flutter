import 'package:calma/servicios/IAService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AsistenteIAService {
}

class AsistenteIAScreen extends StatefulWidget {
  final int idPaciente;
  final String nombrePaciente;

  const AsistenteIAScreen({
    super.key,
    required this.idPaciente,
    required this.nombrePaciente,
  });

  @override
  _AsistenteIAScreenState createState() => _AsistenteIAScreenState();
}

class _AsistenteIAScreenState extends State<AsistenteIAScreen> {
  final TextEditingController _preguntaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final IAService _iaService = IAService();

  List<Map<String, dynamic>> _conversacion = [];
  bool _isLoading = false;
  bool _showSugerencias = true;

  final List<String> _preguntasSugeridas = [
    "¿Qué medicamentos debe tomar en la mañana?",
    "¿Qué medicamentos debe tomar en la tarde?",
    "¿Qué medicamentos debe tomar en la noche?",
    "¿Cuáles son los cuidados generales que debo proporcionar?",
    "¿Qué señales de alerta debo vigilar?",
    "¿Cómo debo ayudar con la alimentación?",
    "¿Qué actividades físicas puede realizar?",
    "¿Cómo estimular cognitivamente al paciente?",
  ];

  @override
  void initState() {
    super.initState();
    _agregarMensajeBienvenida();
  }

  void _agregarMensajeBienvenida() {
    _conversacion.add({
      'tipo': 'asistente',
      'mensaje': '¡Hola! Soy tu asistente especializado en cuidado geriátrico. Estoy aquí para ayudarte con recomendaciones de cuidado específicas para ${widget.nombrePaciente}.\n\n¿En qué puedo ayudarte hoy?',
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _enviarPregunta(String pregunta) async {
    if (pregunta.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSugerencias = false;
      _conversacion.add({
        'tipo': 'usuario',
        'mensaje': pregunta,
        'timestamp': DateTime.now(),
      });
    });

    _preguntaController.clear();
    _scrollToBottom();

    try {
      final resultado = await _iaService.obtenerRecomendacionesCuidado(
        idPaciente: widget.idPaciente,
        pregunta: pregunta,
      );

      setState(() {
        _conversacion.add({
          'tipo': 'asistente',
          'mensaje': resultado['success']
              ? resultado['respuesta']
              : resultado['error'] ?? 'Error desconocido',
          'timestamp': DateTime.now(),
          'isError': !resultado['success'],
        });
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _conversacion.add({
          'tipo': 'asistente',
          'mensaje': 'Error al procesar tu consulta. Por favor intenta nuevamente.',
          'timestamp': DateTime.now(),
          'isError': true,
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _evaluarRiesgos() async {
    setState(() {
      _isLoading = true;
      _showSugerencias = false;
      _conversacion.add({
        'tipo': 'usuario',
        'mensaje': 'Evaluar riesgos del paciente',
        'timestamp': DateTime.now(),
      });
    });

    _scrollToBottom();

    try {
      final resultado = await _iaService.evaluarRiesgos(
        idPaciente: widget.idPaciente,
      );

      setState(() {
        _conversacion.add({
          'tipo': 'asistente',
          'mensaje': resultado['success']
              ? resultado['respuesta']
              : resultado['error'] ?? 'Error desconocido',
          'timestamp': DateTime.now(),
          'isError': !resultado['success'],
        });
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _conversacion.add({
          'tipo': 'asistente',
          'mensaje': 'Error al evaluar riesgos. Por favor intenta nuevamente.',
          'timestamp': DateTime.now(),
          'isError': true,
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
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

  void _limpiarConversacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar conversación'),
          content: const Text('¿Estás seguro de que quieres limpiar toda la conversación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _conversacion.clear();
                  _showSugerencias = true;
                });
                _agregarMensajeBienvenida();
              },
              child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asistente IA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.nombrePaciente,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0E1E3A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment, color: Colors.white),
            onPressed: _evaluarRiesgos,
            tooltip: 'Evaluar riesgos',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: _limpiarConversacion,
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de conversación
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _conversacion.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _conversacion.length && _isLoading) {
                  return _buildTypingIndicator();
                }

                final mensaje = _conversacion[index];
                return _buildMensaje(mensaje);
              },
            ),
          ),

          // Sugerencias de preguntas
          if (_showSugerencias && _conversacion.length <= 1)
            _buildSugerencias(),

          // Campo de entrada
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMensaje(Map<String, dynamic> mensaje) {
    final esUsuario = mensaje['tipo'] == 'usuario';
    final esError = mensaje['isError'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: esUsuario
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!esUsuario) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: esError ? Colors.red[100] : const Color(0xFF0E1E3A),
              child: Icon(
                esError ? Icons.error : Icons.smart_toy,
                color: esError ? Colors.red : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: mensaje['mensaje']));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mensaje copiado al portapapeles'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: esUsuario
                      ? const Color(0xFF0E1E3A)
                      : esError
                      ? Colors.red[50]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: esError
                      ? Border.all(color: Colors.red[200]!)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  mensaje['mensaje'],
                  style: TextStyle(
                    color: esUsuario
                        ? Colors.white
                        : esError
                        ? Colors.red[700]
                        : Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          if (esUsuario) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF0E1E3A),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF0E1E3A),
            child: Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[600]!,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Analizando...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugerencias() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preguntas sugeridas:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E1E3A),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _preguntasSugeridas.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _enviarPregunta(_preguntasSugeridas[index]),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        _preguntasSugeridas[index],
                        style: const TextStyle(
                          color: Color(0xFF0E1E3A),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _preguntaController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              onSubmitted: _enviarPregunta,
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta sobre el cuidado del paciente...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF0E1E3A)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading
                ? null
                : () => _enviarPregunta(_preguntaController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoading
                    ? Colors.grey[400]
                    : const Color(0xFF0E1E3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _preguntaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}