class AppConfig {

  static const String baseUrl = 'http://192.168.0.105:8090';

  static const String loginEndpoint = '/api/login/auth';
  static const String perfilContratanteEndpoint = '/api/registro/contratante/detalle-completo';
  static const String postulacionEndpoint = '/api/postulacion';
  static const String perfilAspiranteEndpoint = '/api/registro/aspirante/detalle';
  static const String generarEndpoint = '/api/generar';
  static const String cvPorAspiranteEndpoint = '/api/cvs/por-aspirante';
  static const String descargarCertificadoEndpoint = '/api/certificados';
  static const String descargarRecomendacionEndpoint = '/api/recomendaciones';
  static const String calificacionesCompletasEndpoint = '/api/cvs/aspirante';
  static const String fichaPacienteEndpoint = '/api/fichas';
  static const String chatbotEndpoint = '/api/chatbot';
  static const String usuariosPorCorreoEndpoint = '/api/usuarios/por-correo';
  static const String passwordResetEndpoint = '/api/password/request-reset';

  // URLs principales
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String getPerfilContratanteUrl(int id) => '$baseUrl$perfilContratanteEndpoint/$id';
  static String getRealizacionesUrl(int idContratante) => '$baseUrl$postulacionEndpoint/$idContratante/realizaciones';
  static String getPerfilAspiranteUrl(int id) => '$baseUrl$perfilAspiranteEndpoint/$id';
  static String get cambiarEstadoPublicacionUrl => '$baseUrl/api/publicacion_empleo/cambiar-estado';
  static String getPublicacionesGeneradasUrl() => '$baseUrl$generarEndpoint/publicaciones';
  static String get postularEndpoint => '$baseUrl/api/realizar/postular';

  // URLs de CV y certificados
  static String getCvPorAspiranteUrl(int aspiranteId) => '$baseUrl$cvPorAspiranteEndpoint/$aspiranteId';
  static String getDescargarCertificadoUrl(int certificadoId) => '$baseUrl$descargarCertificadoEndpoint/$certificadoId/descargar';
  static String getDescargarRecomendacionUrl(int recomendacionId) => '$baseUrl$descargarRecomendacionEndpoint/$recomendacionId/descargar';
  static String getCalificacionesCompletasUrl(int aspiranteId) => '$baseUrl$calificacionesCompletasEndpoint/$aspiranteId/calificaciones/completas';

  // URLs de publicaciones y postulaciones
  static String getPublicacionesNoPostuladasUrl(int idAspirante) => '$baseUrl$generarEndpoint/publicaciones-no-postuladas/$idAspirante';
  static String getActualizarPostulacionUrl(int postulacionId, int contratanteId, int aspiranteId) => '$baseUrl$postulacionEndpoint/actualizar/$postulacionId/$contratanteId/$aspiranteId';
  static String getPostulacionesPorAspiranteUrl(int idAspirante) => '$baseUrl/api/realizar/aspirante/$idAspirante';
  static String getPublicacionesContratanteUrl(int contratanteId) => '$baseUrl$generarEndpoint/publicaciones-contratante/$contratanteId';

  // URLs de notificaciones push
  static String get registrarDispositivoUrl => '$baseUrl/api/dispositivos';
  static String get notificacionpushpostulacion => '$baseUrl/api/dispositivos/enviar-push';

  // URLs de fichas de pacientes
  static String getFichaPacienteUrl(int idPaciente) => '$baseUrl$fichaPacienteEndpoint/$idPaciente';

  // URLs de IA y Chatbot
  static String get chatbotPreguntarUrl => '$baseUrl$chatbotEndpoint/preguntar';
  static String get recomendacionesCuidadoUrl => '$baseUrl$chatbotEndpoint/recomendaciones-cuidado';
  static String get evaluacionRiesgosUrl => '$baseUrl$chatbotEndpoint/evaluacion-riesgos';
  static String get recomendarAspiranteUrl => '$baseUrl$chatbotEndpoint/recomendar-aspirante';
  static String get estadisticasCandidatosUrl => '$baseUrl$chatbotEndpoint/estadisticas-candidatos';

  static String getUsuarioPorCorreoUrl(String correo) => '$baseUrl$usuariosPorCorreoEndpoint?correo=$correo';
  static String get passwordResetUrl => '$baseUrl$passwordResetEndpoint';
}