import 'package:calma/configuracion/AppConfig.dart';
import 'package:calma/controlador/moduloaspirante/favorites/AsistenteIAScreen.dart';
import 'package:calma/servicios/FichaPaciente.dart';
import 'package:calma/servicios/FichaPacienteService.dart';
import 'package:flutter/material.dart';

class FichaPacienteScreen extends StatefulWidget {
  final int idPaciente;

  const FichaPacienteScreen({
    super.key,
    required this.idPaciente,
  });

  @override
  _FichaPacienteScreenState createState() => _FichaPacienteScreenState();
}

class _FichaPacienteScreenState extends State<FichaPacienteScreen> {
  final FichaPacienteService _fichaPacienteService = FichaPacienteService();
  FichaPaciente? _fichaPaciente;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFichaPaciente();
  }

  Future<void> _loadFichaPaciente() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ficha = await _fichaPacienteService.getFichaPacienteById(widget.idPaciente);

      if (mounted) {
        setState(() {
          _fichaPaciente = ficha;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar la ficha del paciente: $e';
        });
      }
    }
  }

  String? _getFotoUrl() {
    final foto = _fichaPaciente?.paciente?.foto;
    if (foto != null && foto.isNotEmpty) {
      return '${AppConfig.baseUrl}/api/registro/$foto';
    }
    return null;
  }

  void _abrirAsistenteIA() {
    if (_fichaPaciente?.paciente != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AsistenteIAScreen(
            idPaciente: widget.idPaciente,
            nombrePaciente: _fichaPaciente!.paciente!.nombreCompleto ?? 'Paciente',
          ),
        ),
      );
    } else {
      // Mostrar mensaje de error si no hay datos del paciente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede acceder al asistente sin datos del paciente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ficha del Paciente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF0E1E3A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFichaPaciente,
            tooltip: 'Actualizar ficha',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0E1E3A),
        ),
      )
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : _fichaPaciente == null
          ? _buildEmptyState()
          : _buildFichaContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar la ficha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E1E3A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFichaPaciente,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1E3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 80, color: Color(0xFF0E1E3A)),
            const SizedBox(height: 16),
            const Text(
              'No se encontró ficha',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E1E3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No se encontró información del paciente',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadFichaPaciente,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1E3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFichaContent() {
    final paciente = _fichaPaciente!.paciente;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header con información básica y foto (MODIFICADO)
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Información personal del paciente
          _buildSectionCard(
            title: 'Información Personal',
            icon: Icons.person,
            children: [
              _buildInfoRow('Cédula', paciente?.cedula ?? 'No especificada'),
              _buildInfoRow('Género', paciente?.genero ?? 'No especificado'),
              _buildInfoRow('Fecha de Nacimiento', _formatDate(paciente?.fechaNac)),
              _buildInfoRow('Dirección', paciente?.direccion ?? 'No especificada'),
              _buildInfoRow('Tipo de Sangre', paciente?.tipoSangre ?? 'No especificado'),
              if (paciente?.parroquia != null)
                _buildInfoRow('Ubicación', '${paciente!.parroquia!.nombre ?? ''}, ${paciente.parroquia!.canton?.nombre ?? ''}, ${paciente.parroquia!.canton?.provincia?.nombre ?? ''}'),
            ],
          ),
          const SizedBox(height: 16),

          // Información de contacto de emergencia
          _buildSectionCard(
            title: 'Contacto de Emergencia',
            icon: Icons.contact_phone,
            children: [
              _buildInfoRow('Contacto de Emergencia', paciente?.contactoEmergencia ?? 'No especificado'),
              _buildInfoRow('Parentesco', paciente?.parentesco ?? 'No especificado'),
            ],
          ),
          const SizedBox(height: 16),

          // Diagnóstico y condiciones
          _buildSectionCard(
            title: 'Diagnóstico y Condiciones',
            icon: Icons.medical_services,
            children: [
              _buildInfoRow('Diagnóstico Actual', _fichaPaciente!.diagnosticoMeActual ?? 'No especificado'),
              _buildInfoRow('Condiciones Físicas', _fichaPaciente!.condicionesFisicas ?? 'No especificadas'),
              _buildInfoRow('Estado de Ánimo', _fichaPaciente!.estadoAnimo ?? 'No especificado'),
              _buildInfoRow('Comunicación', _fichaPaciente!.comunicacion == true ? 'Sí' : 'No'),
              if (_fichaPaciente!.otrasComunicaciones != null && _fichaPaciente!.otrasComunicaciones!.isNotEmpty)
                _buildInfoRow('Otras Comunicaciones', _fichaPaciente!.otrasComunicaciones!),
              _buildInfoRow('Riesgo de Caídas', _fichaPaciente!.caidas ?? 'No especificado'),
            ],
          ),
          const SizedBox(height: 16),

          // Cuidados diarios
          _buildSectionCard(
            title: 'Cuidados Diarios',
            icon: Icons.schedule,
            children: [
              _buildInfoRow('Hora de Levantarse', _fichaPaciente!.horaLevantarse ?? 'No especificada'),
              _buildInfoRow('Hora de Acostarse', _fichaPaciente!.horaAcostarse ?? 'No especificada'),
              _buildInfoRow('Frecuencia de Siestas', _fichaPaciente!.frecuenciaSiestas ?? 'No especificada'),
              _buildInfoRow('Frecuencia de Baño', _fichaPaciente!.frecuenciaBano ?? 'No especificada'),
              _buildInfoRow('Rutina Médica', _fichaPaciente!.rutinaMedica ?? 'No especificada'),
              _buildInfoRow('Usa Pañal', _fichaPaciente!.usaPanal == true ? 'Sí' : 'No'),
              _buildInfoRow('Acompañado', _fichaPaciente!.acompanado == true ? 'Sí' : 'No'),
            ],
          ),
          const SizedBox(height: 16),

          // Alimentación
          _buildSectionCard(
            title: 'Alimentación',
            icon: Icons.restaurant,
            children: [
              _buildInfoRow('Tipo de Dieta', _fichaPaciente!.tipoDieta ?? 'No especificada'),
              _buildInfoRow('Alimentación Asistida', _fichaPaciente!.alimentacionAsistida ?? 'No especificada'),
            ],
          ),
          const SizedBox(height: 16),

          // Alergias
          if (paciente?.alergia != null || (_fichaPaciente!.alergiasAlimentarias?.isNotEmpty == true) || (_fichaPaciente!.alergiasMedicamentos?.isNotEmpty == true))
            _buildSectionCard(
              title: 'Alergias',
              icon: Icons.warning,
              children: [
                if (paciente?.alergia != null)
                  _buildInfoRow('Alergias Generales', paciente!.alergia!),
                if (_fichaPaciente!.alergiasAlimentarias?.isNotEmpty == true) ...[
                  const Text('Alergias Alimentarias:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E1E3A))),
                  const SizedBox(height: 8),
                  ..._fichaPaciente!.alergiasAlimentarias!.map((alergia) =>
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(alergia.alergiaAlimentaria ?? ''),
                          ],
                        ),
                      ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_fichaPaciente!.alergiasMedicamentos?.isNotEmpty == true) ...[
                  const Text('Alergias a Medicamentos:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E1E3A))),
                  const SizedBox(height: 8),
                  ..._fichaPaciente!.alergiasMedicamentos!.map((alergia) =>
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(alergia.nombreMedicamento ?? ''),
                          ],
                        ),
                      ),
                  ),
                ],
              ],
            ),

          const SizedBox(height: 16),

          // Medicamentos
          if (_fichaPaciente!.medicamentos?.isNotEmpty == true)
            _buildSectionCard(
              title: 'Medicamentos',
              icon: Icons.local_pharmacy,
              children: [
                ..._fichaPaciente!.medicamentos!.map((medicamento) =>
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicamento.nombreMedicamento ?? 'Medicamento sin nombre',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0E1E3A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (medicamento.dosisMed != null)
                            _buildMedicamentoInfo('Dosis', medicamento.dosisMed!),
                          if (medicamento.frecuenciaMed != null)
                            _buildMedicamentoInfo('Frecuencia', medicamento.frecuenciaMed!),
                          if (medicamento.viaAdministracion != null)
                            _buildMedicamentoInfo('Vía', medicamento.viaAdministracion!),
                          if (medicamento.condicionTratada != null)
                            _buildMedicamentoInfo('Para', medicamento.condicionTratada!),
                          if (medicamento.reaccionesEsp != null)
                            _buildMedicamentoInfo('Precauciones', medicamento.reaccionesEsp!),
                        ],
                      ),
                    ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Intereses y temas de conversación
          if ((_fichaPaciente!.interesesPersonales?.isNotEmpty == true) || (_fichaPaciente!.temasConversacion?.isNotEmpty == true))
            _buildSectionCard(
              title: 'Intereses Personales',
              icon: Icons.favorite,
              children: [
                if (_fichaPaciente!.interesesPersonales?.isNotEmpty == true) ...[
                  const Text('Intereses:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E1E3A))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fichaPaciente!.interesesPersonales!.map((interes) =>
                        Chip(
                          label: Text(interes.interesPersonal ?? ''),
                          backgroundColor: Colors.purple[100],
                          labelStyle: const TextStyle(color: Color(0xFF0E1E3A)),
                        ),
                    ).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_fichaPaciente!.temasConversacion?.isNotEmpty == true) ...[
                  const Text('Temas de Conversación:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0E1E3A))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fichaPaciente!.temasConversacion!.map((tema) =>
                        Chip(
                          label: Text(tema.tema ?? ''),
                          backgroundColor: Colors.green[100],
                          labelStyle: const TextStyle(color: Color(0xFF0E1E3A)),
                        ),
                    ).toList(),
                  ),
                ],
              ],
            ),

          const SizedBox(height: 16),

          // Observaciones
          if (_fichaPaciente!.observaciones != null && _fichaPaciente!.observaciones!.isNotEmpty)
            _buildSectionCard(
              title: 'Observaciones',
              icon: Icons.note,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Text(
                    _fichaPaciente!.observaciones!,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),

          // Información del contratante
          if (paciente?.contratante != null)
            Column(
              children: [
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Información del Contratante',
                  icon: Icons.business,
                  children: [
                    _buildInfoRow('Nombre', '${paciente!.contratante!.usuario?.nombres ?? ''} ${paciente.contratante!.usuario?.apellidos ?? ''}'),
                    _buildInfoRow('Cédula', paciente.contratante!.usuario?.cedula ?? 'No especificada'),
                    _buildInfoRow('Correo', paciente.contratante!.usuario?.correo ?? 'No especificado'),
                    _buildInfoRow('Ocupación', paciente.contratante!.ocupacion ?? 'No especificada'),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final paciente = _fichaPaciente!.paciente;
    final fotoUrl = _getFotoUrl();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0E1E3A), Color(0xFF1E3A5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // BOTÓN DE ASISTENTE IA - AGREGADO AQUÍ
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: _abrirAsistenteIA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0E1E3A),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                icon: const Icon(
                  Icons.smart_toy,
                  size: 20,
                ),
                label: const Text(
                  'Asistente IA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Foto del paciente o avatar por defecto
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: fotoUrl != null
                    ? Image.network(
                  fotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_circle,
                      size: 94,
                      color: Colors.white,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  },
                )
                    : const Icon(
                  Icons.account_circle,
                  size: 94,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              paciente?.nombreCompleto ?? 'Sin nombre',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0E1E3A), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E1E3A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0E1E3A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentoInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No especificada';
    return '${date.day}/${date.month}/${date.year}';
  }
}