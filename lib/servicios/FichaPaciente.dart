class FichaPaciente {
  final int? idFichaPaciente;
  final String? diagnosticoMeActual;
  final String? condicionesFisicas;
  final String? estadoAnimo;
  final bool? comunicacion;
  final String? otrasComunicaciones;
  final String? tipoDieta;
  final String? alimentacionAsistida;
  final String? horaLevantarse;
  final String? horaAcostarse;
  final String? frecuenciaSiestas;
  final String? frecuenciaBano;
  final String? rutinaMedica;
  final bool? usaPanal;
  final bool? acompanado;
  final String? observaciones;
  final String? caidas;
  final DateTime? fechaRegistro;
  final PacienteInfo? paciente;
  final List<Medicamento>? medicamentos;
  final List<AlergiaAlimentaria>? alergiasAlimentarias;
  final List<TemaConversacion>? temasConversacion;
  final List<InteresPersonal>? interesesPersonales;
  final List<AlergiaMedicamento>? alergiasMedicamentos;

  FichaPaciente({
    this.idFichaPaciente,
    this.diagnosticoMeActual,
    this.condicionesFisicas,
    this.estadoAnimo,
    this.comunicacion,
    this.otrasComunicaciones,
    this.tipoDieta,
    this.alimentacionAsistida,
    this.horaLevantarse,
    this.horaAcostarse,
    this.frecuenciaSiestas,
    this.frecuenciaBano,
    this.rutinaMedica,
    this.usaPanal,
    this.acompanado,
    this.observaciones,
    this.caidas,
    this.fechaRegistro,
    this.paciente,
    this.medicamentos,
    this.alergiasAlimentarias,
    this.temasConversacion,
    this.interesesPersonales,
    this.alergiasMedicamentos,
  });

  factory FichaPaciente.fromJson(Map<String, dynamic> json) {
    return FichaPaciente(
      idFichaPaciente: json['id_ficha_paciente'],
      diagnosticoMeActual: json['diagnostico_me_actual'],
      condicionesFisicas: json['condiciones_fisicas'],
      estadoAnimo: json['estado_animo'],
      comunicacion: json['comunicacion'],
      otrasComunicaciones: json['otras_comunicaciones'],
      tipoDieta: json['tipo_dieta'],
      alimentacionAsistida: json['alimentacion_asistida'],
      horaLevantarse: json['hora_levantarse'],
      horaAcostarse: json['hora_acostarse'],
      frecuenciaSiestas: json['frecuencia_siestas'],
      frecuenciaBano: json['frecuencia_baño'],
      rutinaMedica: json['rutina_medica'],
      usaPanal: json['usapanal'],
      acompanado: json['acompañado'],
      observaciones: json['observaciones'],
      caidas: json['caidas'],
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : null,
      paciente: json['paciente'] != null
          ? PacienteInfo.fromJson(json['paciente'])
          : null,
      medicamentos: json['medicamentos'] != null
          ? (json['medicamentos'] as List)
          .map((item) => Medicamento.fromJson(item))
          .toList()
          : null,
      alergiasAlimentarias: json['alergiasAlimentarias'] != null
          ? (json['alergiasAlimentarias'] as List)
          .map((item) => AlergiaAlimentaria.fromJson(item))
          .toList()
          : null,
      temasConversacion: json['temasConversacion'] != null
          ? (json['temasConversacion'] as List)
          .map((item) => TemaConversacion.fromJson(item))
          .toList()
          : null,
      interesesPersonales: json['interesesPersonales'] != null
          ? (json['interesesPersonales'] as List)
          .map((item) => InteresPersonal.fromJson(item))
          .toList()
          : null,
      alergiasMedicamentos: json['alergiasMedicamentos'] != null
          ? (json['alergiasMedicamentos'] as List)
          .map((item) => AlergiaMedicamento.fromJson(item))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ficha_paciente': idFichaPaciente,
      'diagnostico_me_actual': diagnosticoMeActual,
      'condiciones_fisicas': condicionesFisicas,
      'estado_animo': estadoAnimo,
      'comunicacion': comunicacion,
      'otras_comunicaciones': otrasComunicaciones,
      'tipo_dieta': tipoDieta,
      'alimentacion_asistida': alimentacionAsistida,
      'hora_levantarse': horaLevantarse,
      'hora_acostarse': horaAcostarse,
      'frecuencia_siestas': frecuenciaSiestas,
      'frecuencia_baño': frecuenciaBano,
      'rutina_medica': rutinaMedica,
      'usapanal': usaPanal,
      'acompañado': acompanado,
      'observaciones': observaciones,
      'caidas': caidas,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'paciente': paciente?.toJson(),
      'medicamentos': medicamentos?.map((item) => item.toJson()).toList(),
      'alergiasAlimentarias': alergiasAlimentarias?.map((item) => item.toJson()).toList(),
      'temasConversacion': temasConversacion?.map((item) => item.toJson()).toList(),
      'interesesPersonales': interesesPersonales?.map((item) => item.toJson()).toList(),
      'alergiasMedicamentos': alergiasMedicamentos?.map((item) => item.toJson()).toList(),
    };
  }
}

class PacienteInfo {
  final int? idPaciente;
  final String? cedula;
  final String? nombres;
  final String? apellidos;
  final String? genero;
  final String? direccion;
  final String? contactoEmergencia;
  final String? parentesco;
  final String? tipoSangre;
  final String? foto;
  final String? alergia;
  final DateTime? fechaNac;
  final Parroquia? parroquia;
  final Contratante? contratante;

  PacienteInfo({
    this.idPaciente,
    this.cedula,
    this.nombres,
    this.apellidos,
    this.genero,
    this.direccion,
    this.contactoEmergencia,
    this.parentesco,
    this.tipoSangre,
    this.foto,
    this.alergia,
    this.fechaNac,
    this.parroquia,
    this.contratante,
  });

  factory PacienteInfo.fromJson(Map<String, dynamic> json) {
    return PacienteInfo(
      idPaciente: json['id_paciente'],
      cedula: json['cedula'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      genero: json['genero'],
      direccion: json['direccion'],
      contactoEmergencia: json['contacto_emergencia'],
      parentesco: json['parentesco'],
      tipoSangre: json['tipo_sangre'],
      foto: json['foto'],
      alergia: json['alergia'],
      fechaNac: json['fecha_Nac'] != null
          ? DateTime.parse(json['fecha_Nac'])
          : null,
      parroquia: json['parroquia'] != null
          ? Parroquia.fromJson(json['parroquia'])
          : null,
      contratante: json['contratante'] != null
          ? Contratante.fromJson(json['contratante'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_paciente': idPaciente,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'genero': genero,
      'direccion': direccion,
      'contacto_emergencia': contactoEmergencia,
      'parentesco': parentesco,
      'tipo_sangre': tipoSangre,
      'foto': foto,
      'alergia': alergia,
      'fecha_Nac': fechaNac?.toIso8601String(),
      'parroquia': parroquia?.toJson(),
      'contratante': contratante?.toJson(),
    };
  }

  String get nombreCompleto => '${nombres ?? ''} ${apellidos ?? ''}'.trim();
}

class Parroquia {
  final int? idParroquia;
  final String? nombre;
  final Canton? canton;

  Parroquia({this.idParroquia, this.nombre, this.canton});

  factory Parroquia.fromJson(Map<String, dynamic> json) {
    return Parroquia(
      idParroquia: json['id_parroquia'],
      nombre: json['nombre'],
      canton: json['canton'] != null ? Canton.fromJson(json['canton']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_parroquia': idParroquia,
      'nombre': nombre,
      'canton': canton?.toJson(),
    };
  }
}

class Canton {
  final int? idCanton;
  final String? nombre;
  final Provincia? provincia;

  Canton({this.idCanton, this.nombre, this.provincia});

  factory Canton.fromJson(Map<String, dynamic> json) {
    return Canton(
      idCanton: json['id_canton'],
      nombre: json['nombre'],
      provincia: json['provincia'] != null ? Provincia.fromJson(json['provincia']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_canton': idCanton,
      'nombre': nombre,
      'provincia': provincia?.toJson(),
    };
  }
}

class Provincia {
  final int? idProvincia;
  final String? nombre;

  Provincia({this.idProvincia, this.nombre});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(
      idProvincia: json['id_provincia'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_provincia': idProvincia,
      'nombre': nombre,
    };
  }
}

class Contratante {
  final int? idContratante;
  final Usuario? usuario;
  final String? ocupacion;

  Contratante({this.idContratante, this.usuario, this.ocupacion});

  factory Contratante.fromJson(Map<String, dynamic> json) {
    return Contratante(
      idContratante: json['idContratante'],
      usuario: json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
      ocupacion: json['ocupacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idContratante': idContratante,
      'usuario': usuario?.toJson(),
      'ocupacion': ocupacion,
    };
  }
}

class Usuario {
  final int? idUsuario;
  final String? nombres;
  final String? apellidos;
  final String? cedula;
  final String? correo;
  final String? genero;
  final DateTime? fechaNacimiento;
  final String? rol;
  final String? foto;

  Usuario({
    this.idUsuario,
    this.nombres,
    this.apellidos,
    this.cedula,
    this.correo,
    this.genero,
    this.fechaNacimiento,
    this.rol,
    this.foto,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      cedula: json['cedula'],
      correo: json['correo'],
      genero: json['genero'],
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : null,
      rol: json['rol'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nombres': nombres,
      'apellidos': apellidos,
      'cedula': cedula,
      'correo': correo,
      'genero': genero,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'rol': rol,
      'foto': foto,
    };
  }
}

class Medicamento {
  final int? idListaMedicamentos;
  final bool? medicacion;
  final String? nombreMedicamento;
  final String? dosisMed;
  final String? frecuenciaMed;
  final String? viaAdministracion;
  final String? condicionTratada;
  final String? reaccionesEsp;

  Medicamento({
    this.idListaMedicamentos,
    this.medicacion,
    this.nombreMedicamento,
    this.dosisMed,
    this.frecuenciaMed,
    this.viaAdministracion,
    this.condicionTratada,
    this.reaccionesEsp,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      idListaMedicamentos: json['idListaMedicamentos'],
      medicacion: json['medicacion'],
      nombreMedicamento: json['nombremedicamento'],
      dosisMed: json['dosis_med'],
      frecuenciaMed: json['frecuencia_med'],
      viaAdministracion: json['via_administracion'],
      condicionTratada: json['condicion_tratada'],
      reaccionesEsp: json['reacciones_esp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idListaMedicamentos': idListaMedicamentos,
      'medicacion': medicacion,
      'nombremedicamento': nombreMedicamento,
      'dosis_med': dosisMed,
      'frecuencia_med': frecuenciaMed,
      'via_administracion': viaAdministracion,
      'condicion_tratada': condicionTratada,
      'reacciones_esp': reaccionesEsp,
    };
  }
}

class AlergiaAlimentaria {
  final int? idAlergiasAlimentarias;
  final String? alergiaAlimentaria;

  AlergiaAlimentaria({this.idAlergiasAlimentarias, this.alergiaAlimentaria});

  factory AlergiaAlimentaria.fromJson(Map<String, dynamic> json) {
    return AlergiaAlimentaria(
      idAlergiasAlimentarias: json['id_alergias_alimentarias'],
      alergiaAlimentaria: json['alergiaAlimentaria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alergias_alimentarias': idAlergiasAlimentarias,
      'alergiaAlimentaria': alergiaAlimentaria,
    };
  }
}

class TemaConversacion {
  final int? idTemaConversacion;
  final String? tema;

  TemaConversacion({this.idTemaConversacion, this.tema});

  factory TemaConversacion.fromJson(Map<String, dynamic> json) {
    return TemaConversacion(
      idTemaConversacion: json['idTemaConversacion'],
      tema: json['tema'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idTemaConversacion': idTemaConversacion,
      'tema': tema,
    };
  }
}

class InteresPersonal {
  final int? idInteresesPersonales;
  final String? interesPersonal;

  InteresPersonal({this.idInteresesPersonales, this.interesPersonal});

  factory InteresPersonal.fromJson(Map<String, dynamic> json) {
    return InteresPersonal(
      idInteresesPersonales: json['idInteresesPersonales'],
      interesPersonal: json['interesPersonal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idInteresesPersonales': idInteresesPersonales,
      'interesPersonal': interesPersonal,
    };
  }
}

class AlergiaMedicamento {
  final int? idAlergiaMed;
  final String? nombreMedicamento;

  AlergiaMedicamento({this.idAlergiaMed, this.nombreMedicamento});

  factory AlergiaMedicamento.fromJson(Map<String, dynamic> json) {
    return AlergiaMedicamento(
      idAlergiaMed: json['id_alergiamed'],
      nombreMedicamento: json['nombremedicamento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alergiamed': idAlergiaMed,
      'nombremedicamento': nombreMedicamento,
    };
  }
}