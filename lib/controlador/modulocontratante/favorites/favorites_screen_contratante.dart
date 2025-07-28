import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/controlador/modulocontratante/favorites/FloatingIAButton.dart';
import 'package:calma/controlador/modulocontratante/favorites/vercv.dart';
import 'package:calma/servicios/IAService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calma/servicios/mostrar_postulaciones_servicios.dart';

class FavoritesScreenContratante extends StatefulWidget {
  final int specificId;
  const FavoritesScreenContratante({super.key, required this.specificId});

  @override
  _FavoritesScreenContratanteState createState() => _FavoritesScreenContratanteState();
}

class _FavoritesScreenContratanteState extends State<FavoritesScreenContratante> {
  final PostulacionService _postulacionService = PostulacionService();
  final IAService _iaService = IAService();

  List<dynamic> _postulaciones = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final Color _primaryColor = const Color(0xFF0A2647);
  final Color _secondaryColor = const Color(0xFF144272);
  final Color _accentColor = const Color(0xFF2C74B3);

  @override
  void initState() {
    super.initState();
    _fetchPostulaciones();
  }

  Future<void> _fetchPostulaciones() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final postulaciones = await _postulacionService.getPostulacionesPorContratante(widget.specificId);

      setState(() {
        _postulaciones = postulaciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAceptar(int postulacionId, int idAspirante, String tituloPublicacion) async {
    try {
      final success = await _postulacionService.actualizarEstadoPostulacion(
        postulacionId: postulacionId,
        contratanteId: widget.specificId,
        aspiranteId: idAspirante,
        estado: true,
        tituloPublicacion: tituloPublicacion,
      );

      if (success) {
        _showSnackbar('Postulación aceptada correctamente');
        await _fetchPostulaciones();
      }
    } catch (e) {
      String errorString = e.toString();
      if (errorString.contains('Postulación actualizada')) {
        _showSnackbar('Postulación aceptada correctamente');
        await _fetchPostulaciones();
      } else {
        _showSnackbar('Error al aceptar postulación: ${e.toString()}');
      }
    }
  }

  Future<void> _handleRechazar(int postulacionId, int idAspirante, String tituloPublicacion) async {
    try {
      final success = await _postulacionService.actualizarEstadoPostulacion(
        postulacionId: postulacionId,
        contratanteId: widget.specificId,
        aspiranteId: idAspirante,
        estado: false,
        tituloPublicacion: tituloPublicacion,
      );

      if (success) {
        _showSnackbar('Postulación rechazada correctamente');
        await _fetchPostulaciones();
      }
    } catch (e) {
      String errorString = e.toString();
      if (errorString.contains('Postulación actualizada')) {
        _showSnackbar('Postulación rechazada correctamente');
        await _fetchPostulaciones();
      } else {
        _showSnackbar('Error al rechazar postulación: ${e.toString()}');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _accentColor,
      ),
    );
  }

  Map<String, dynamic> _getEstadoData(bool? estado) {
    if (estado == null) {
      return {
        'texto': 'Pendiente',
        'color': Colors.blue[800]!,
        'bgColor': Colors.blue[100]!,
      };
    } else if (estado) {
      return {
        'texto': 'Aceptado',
        'color': Colors.green[800]!,
        'bgColor': Colors.green[100]!,
      };
    } else {
      return {
        'texto': 'Rechazado',
        'color': Colors.red[800]!,
        'bgColor': Colors.red[100]!,
      };
    }
  }

  // Método para mostrar el chat IA flotante con selector de trabajos
  void _showIAChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IAChatWidget(
          contratanteId: widget.specificId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Postulaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
          : _postulaciones.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes postulaciones guardadas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _postulaciones.length,
        itemBuilder: (context, index) {
          final postulacion = _postulaciones[index]['postulacion'];
          final empleo = postulacion['postulacion_empleo'];
          final parroquia = empleo['parroquia'];
          final canton = parroquia['canton'];
          final provincia = canton['provincia'];
          final aspirante = _postulaciones[index]['aspirante'];
          final idAspirante = aspirante['idAspirante'];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con título y estado (sin botones IA individuales)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          empleo['titulo'] ?? 'Sin título',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final estadoData = _getEstadoData(postulacion['estado']);
                          return Chip(
                            backgroundColor: estadoData['bgColor'],
                            label: Text(
                              estadoData['texto'],
                              style: TextStyle(color: estadoData['color']),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    empleo['descripcion'] ?? 'Sin descripción',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Detalles en fila
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildDetailItem(
                        Icons.attach_money,
                        'Salario: \$${empleo['salario_estimado'] ?? '0'}',
                      ),
                      _buildDetailItem(
                        Icons.schedule,
                        'Jornada: ${empleo['jornada'] ?? 'No especificada'}',
                      ),
                      _buildDetailItem(
                        Icons.timer,
                        'Turno: ${empleo['turno'] ?? 'No especificado'}',
                      ),
                      _buildDetailItem(
                        Icons.location_on,
                        '${parroquia['nombre'] ?? ''}, ${canton['nombre'] ?? ''}, ${provincia['nombre'] ?? ''}',
                      ),
                      _buildDetailItem(
                        Icons.calendar_today,
                        'Fecha límite: ${empleo['fecha_limite']?.toString().split('T')[0] ?? 'No especificada'}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Requisitos
                  Text(
                    'Requisitos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    empleo['requisitos'] ?? 'Sin requisitos especificados',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Botón Rechazar
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: postulacion['estado'] == null
                            ? () => _handleRechazar(
                          postulacion['id_postulacion'],
                          idAspirante,
                          empleo['titulo'] ?? 'Sin título',
                        )
                            : null,
                        child: const Text('Rechazar'),
                      ),

                      const SizedBox(width: 16),

                      // Botón Aceptar
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: postulacion['estado'] == null
                              ? _accentColor
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: postulacion['estado'] == null
                            ? () => _handleAceptar(
                          postulacion['id_postulacion'],
                          idAspirante,
                          empleo['titulo'] ?? 'Sin título',
                        )
                            : null,
                        child: const Text('Aceptar'),
                      ),

                      const SizedBox(width: 16),

                      // Botón Ver CV
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerCV(aspiranteId: idAspirante),
                            ),
                          );
                        },
                        child: const Text('Ver CV'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Botón flotante IA con funcionalidad mejorada
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: _showIAChat,
          backgroundColor: _primaryColor,
          icon: const Icon(Icons.psychology, color: Colors.white),
          label: const Text(
            'IA Recomendaciones',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _secondaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

// Widget de Chat IA actualizado con selector de trabajos
class IAChatWidget extends StatefulWidget {
  final int contratanteId;

  const IAChatWidget({
    Key? key,
    required this.contratanteId,
  }) : super(key: key);

  @override
  _IAChatWidgetState createState() => _IAChatWidgetState();
}

class _IAChatWidgetState extends State<IAChatWidget> {
  final IAService _iaService = IAService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  List<dynamic> _publicaciones = [];
  int? _selectedPublicacion;
  String? _selectedTitulo;
  bool _isLoading = false;
  bool _isLoadingPublicaciones = true;

  final Color _primaryColor = const Color(0xFF0A2647);
  final Color _accentColor = const Color(0xFF2C74B3);

  @override
  void initState() {
    super.initState();
    _loadPublicaciones();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // SOLUCIÓN IMPLEMENTADA: Usar PostulacionService en lugar de IAService
  Future<void> _loadPublicaciones() async {
    try {
      // Usar el PostulacionService existente en lugar del IAService
      final PostulacionService postulacionService = PostulacionService();
      final postulaciones = await postulacionService.getPostulacionesPorContratante(widget.contratanteId);

      // Extraer trabajos únicos de las postulaciones
      final Map<int, Map<String, dynamic>> trabajosUnicos = {};

      for (var postulacionData in postulaciones) {
        final empleo = postulacionData['postulacion']['postulacion_empleo'];
        final idEmpleo = empleo['id_postulacion_empleo'];

        // Solo agregar si no existe ya (evitar duplicados)
        if (!trabajosUnicos.containsKey(idEmpleo)) {
          trabajosUnicos[idEmpleo] = {
            'id_postulacion_empleo': idEmpleo,
            'titulo': empleo['titulo'] ?? 'Sin título',
            'salario_estimado': empleo['salario_estimado'] ?? '0',
            'jornada': empleo['jornada'] ?? 'No especificada',
            'descripcion': empleo['descripcion'] ?? 'Sin descripción',
          };
        }
      }

      setState(() {
        _publicaciones = trabajosUnicos.values.toList();
        _isLoadingPublicaciones = false;
      });

      print('✅ Trabajos únicos cargados: ${_publicaciones.length}');

    } catch (e) {
      setState(() {
        _isLoadingPublicaciones = false;
      });
      print('❌ Error cargando publicaciones: $e');

      // Mostrar mensaje de error más amigable
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Error al cargar los trabajos. Asegúrate de que tengas postulaciones activas.',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      });
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: '''¡Hola! 👋 Soy tu asistente de IA para recomendaciones de candidatos.

Para ayudarte mejor:
1️⃣ Selecciona uno de tus trabajos publicados de la lista desplegable arriba
2️⃣ Pregúntame sobre los candidatos que se han postulado, por ejemplo:
   • "¿Cuál es el mejor candidato?"
   • "¿Quién tiene más experiencia?"
   • "¿Cuál candidato recomiendas?"
   • "Dame estadísticas de los postulantes"

Solo puedo analizar trabajos que tengan postulaciones activas. 🎯''',
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
      Map<String, dynamic> response;

      if (_selectedPublicacion == null) {
        response = {
          'success': false,
          'error': 'Por favor, primero selecciona un trabajo de la lista desplegable para poder analizar sus candidatos.',
        };
      } else {
        // Detectar si es una pregunta sobre estadísticas o recomendaciones
        final String lowerText = text.toLowerCase();

        if (_shouldUseStatistics(lowerText)) {
          // Obtener estadísticas
          response = await _iaService.obtenerEstadisticasCandidatos(_selectedPublicacion!);
          if (response['success'] == true) {
            response['respuesta'] = _formatStatisticsResponse(response);
          }
        } else {
          // Obtener recomendación de candidato
          response = await _iaService.obtenerRecomendacionIA(
            idPublicacion: _selectedPublicacion!,
            criterios: text,
          );
        }
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

  bool _shouldUseStatistics(String text) {
    final keywords = [
      'estadística', 'cuántos', 'total', 'porcentaje', 'promedio',
      'cantidad', 'número', 'datos', 'métricas', 'resumen'
    ];
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _formatStatisticsResponse(Map<String, dynamic> stats) {
    return '''📊 **Estadísticas de "${_selectedTitulo}"**

👥 **Total de candidatos:** ${stats['totalCandidatos']}
⭐ **Promedio de calificaciones:** ${stats['promedioCalificaciones']} estrellas
✅ **Candidatos disponibles:** ${stats['candidatosDisponibles']} (${stats['porcentajeDisponibilidad']}%)
🎯 **Con experiencia previa:** ${stats['candidatosConExperiencia']} (${stats['porcentajeExperiencia']}%)

${stats['totalCandidatos'] > 0 ? '¡Tienes candidatos interesados! Pregúntame "¿cuál es el mejor candidato?" para obtener una recomendación personalizada.' : 'Aún no hay candidatos para esta publicación.'}''';
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
    return Column(
      children: [
        // Header con selector de trabajos
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Asistente IA - Recomendaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
              const SizedBox(height: 12),

              // Selector de publicaciones
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoadingPublicaciones
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                    : _publicaciones.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No hay trabajos con postulaciones disponibles',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedPublicacion,
                    hint: const Text(
                      'Selecciona un trabajo para analizar candidatos',
                      style: TextStyle(fontSize: 14),
                    ),
                    isExpanded: true,
                    items: _publicaciones.map<DropdownMenuItem<int>>((publicacion) {
                      return DropdownMenuItem<int>(
                        value: publicacion['id_postulacion_empleo'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              publicacion['titulo'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Salario: \$${publicacion['salario_estimado']} - ${publicacion['jornada']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedPublicacion = newValue;
                        _selectedTitulo = _publicaciones
                            .firstWhere((p) => p['id_postulacion_empleo'] == newValue)['titulo'];
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de mensajes
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

        // Indicador de carga
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
                  child: const Icon(Icons.psychology, color: Colors.grey),
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
                        'Analizando candidatos...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Campo de entrada
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _selectedPublicacion != null
                        ? 'Pregunta sobre los candidatos...'
                        : 'Primero selecciona un trabajo arriba',
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
                message.isError ? Icons.error_outline : Icons.psychology,
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