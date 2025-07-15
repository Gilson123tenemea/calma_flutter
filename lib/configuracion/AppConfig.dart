

class AppConfig {
  static const String baseUrl = 'http://192.168.0.109:8090';

  static const String loginEndpoint = '/api/login/auth';
  static const String perfilContratanteEndpoint = '/api/registro/contratante/detalle-completo';
  static const String postulacionEndpoint = '/api/postulacion';
  static const String perfilAspiranteEndpoint = '/api/registro/aspirante/detalle';
  static const String generarEndpoint = '/api/generar';

  static const String cvPorAspiranteEndpoint = '/api/cvs/por-aspirante';
  static const String descargarCertificadoEndpoint = '/api/certificados';
  static const String descargarRecomendacionEndpoint = '/api/recomendaciones';


  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String getPerfilContratanteUrl(int id) => '$baseUrl$perfilContratanteEndpoint/$id';
  static String getRealizacionesUrl(int idContratante) => '$baseUrl$postulacionEndpoint/$idContratante/realizaciones';
  static String getActualizarPostulacionUrl(int id) => '$baseUrl$postulacionEndpoint/actualizar/$id';
  static String getPerfilAspiranteUrl(int id) => '$baseUrl$perfilAspiranteEndpoint/$id';
  static String get cambiarEstadoPublicacionUrl => '$baseUrl/api/publicacion_empleo/cambiar-estado';
// static String getTodasLasPublicacionesUrl() => '$baseUrl$generarEndpoint/publicaciones';
  static String getPublicacionesGeneradasUrl() => '$baseUrl$generarEndpoint/publicaciones';
  static String get postularEndpoint => '$baseUrl/api/realizar/postular';

  static String getCvPorAspiranteUrl(int aspiranteId) => '$baseUrl$cvPorAspiranteEndpoint/$aspiranteId';
  static String getDescargarCertificadoUrl(int certificadoId) => '$baseUrl$descargarCertificadoEndpoint/$certificadoId/descargar';
  static String getDescargarRecomendacionUrl(int recomendacionId) => '$baseUrl$descargarRecomendacionEndpoint/$recomendacionId/descargar';

}
