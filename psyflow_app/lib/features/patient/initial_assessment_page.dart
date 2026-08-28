import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/invite_service.dart';
import '../../core/di/service_locator.dart';

class InitialAssessmentPage extends StatefulWidget {
  final String psychologistId;
  final String psychologistName;
  final VoidCallback? onSubmitted;

  const InitialAssessmentPage({
    super.key,
    required this.psychologistId,
    required this.psychologistName,
    this.onSubmitted,
  });

  @override
  State<InitialAssessmentPage> createState() => _InitialAssessmentPageState();
}

class _InitialAssessmentPageState extends State<InitialAssessmentPage> {
  final _inviteService = sl<InviteService>();

  final _complaintController = TextEditingController();
  final _durationController = TextEditingController();
  final _previousTherapyDetailsController = TextEditingController();
  final _medicationDetailsController = TextEditingController();
  final _goalController = TextEditingController();

  bool _previousTherapy = false;
  bool _usingMedication = false;
  double _distressLevel = 6.0;
  bool _loading = false;

  @override
  void dispose() {
    _complaintController.dispose();
    _durationController.dispose();
    _previousTherapyDetailsController.dispose();
    _medicationDetailsController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_complaintController.text.trim().isEmpty) {
      _showError('Por favor, descreva o que te motivou a buscar acompanhamento.');
      return;
    }
    if (_durationController.text.trim().isEmpty) {
      _showError('Por favor, informe há quanto tempo sente esses sintomas.');
      return;
    }
    if (_goalController.text.trim().isEmpty) {
      _showError('Por favor, informe seu principal objetivo com a terapia.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _inviteService.submitInitialAssessment(
        psychologistId: widget.psychologistId,
        mainComplaint: _complaintController.text.trim(),
        symptomsDuration: _durationController.text.trim(),
        previousTherapy: _previousTherapy,
        previousTherapyDetails: _previousTherapy ? _previousTherapyDetailsController.text.trim() : null,
        usingMedication: _usingMedication,
        medicationDetails: _usingMedication ? _medicationDetailsController.text.trim() : null,
        mainGoal: _goalController.text.trim(),
        distressLevel: _distressLevel.round(),
      );

      if (mounted) {
        widget.onSubmitted?.call();
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Ficha inicial enviada com sucesso ao seu psicólogo!')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    }

    if (mounted) setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ficha de Avaliação Inicial'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner de Boas-vindas Pré-Consulta ────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.timer_outlined, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              '⏱️ Aproximadamente 5 minutos',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Antes da sua primeira consulta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gostaríamos que você respondesse algumas perguntas para ajudar ${widget.psychologistName} a conhecer melhor seu momento atual e preparar seu acolhimento.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Pergunta 1: Queixa Principal ─────────────────────
            _buildSectionCard(
              title: '1. O que motivou você a buscar acompanhamento agora?',
              subtitle: 'Descreva seus principais sentimentos, desafios ou acontecimentos recentes.',
              child: TextField(
                controller: _complaintController,
                maxLines: 4,
                decoration: _inputDecoration('Ex: Tenho me sentido muito sobrecarregado no trabalho, com ansiedade constante e crises de insônia...'),
              ),
            ),
            const SizedBox(height: 18),

            // ── Pergunta 2: Duração dos Sintomas ──────────────────
            _buildSectionCard(
              title: '2. Há quanto tempo percebe esses sintomas ou questões?',
              subtitle: 'Indique se é algo recente ou que já vem se repetindo há meses/anos.',
              child: TextField(
                controller: _durationController,
                decoration: _inputDecoration('Ex: Há cerca de 3 meses, desde que troquei de cargo...'),
              ),
            ),
            const SizedBox(height: 18),

            // ── Pergunta 3: Experiência Prévia com Terapia ────────
            _buildSectionCard(
              title: '3. Já fez psicoterapia anteriormente?',
              subtitle: 'Ajuda a compreender o que já funcionou para você no passado.',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Não')),
                          selected: !_previousTherapy,
                          selectedColor: AppColors.patient.withValues(alpha: 0.15),
                          onSelected: (v) => setState(() => _previousTherapy = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Sim')),
                          selected: _previousTherapy,
                          selectedColor: AppColors.patient.withValues(alpha: 0.15),
                          onSelected: (v) => setState(() => _previousTherapy = true),
                        ),
                      ),
                    ],
                  ),
                  if (_previousTherapy) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _previousTherapyDetailsController,
                      maxLines: 2,
                      decoration: _inputDecoration('Como foi a experiência? (Opcional)'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Pergunta 4: Uso de Medicamentos ──────────────────
            _buildSectionCard(
              title: '4. Faz uso de algum medicamento contínuo ou psiquiátrico?',
              subtitle: 'Informação confidencial para apoio ao raciocínio clínico.',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Não')),
                          selected: !_usingMedication,
                          selectedColor: AppColors.patient.withValues(alpha: 0.15),
                          onSelected: (v) => setState(() => _usingMedication = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Sim')),
                          selected: _usingMedication,
                          selectedColor: AppColors.patient.withValues(alpha: 0.15),
                          onSelected: (v) => setState(() => _usingMedication = true),
                        ),
                      ),
                    ],
                  ),
                  if (_usingMedication) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _medicationDetailsController,
                      maxLines: 2,
                      decoration: _inputDecoration('Quais medicamentos e dosagens? (Ex: Sertralina 50mg)'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Pergunta 5: Objetivo Principal ────────────────────
            _buildSectionCard(
              title: '5. Qual seu principal objetivo com a psicoterapia?',
              subtitle: 'O que você gostaria que fosse diferente na sua vida ao longo do processo?',
              child: TextField(
                controller: _goalController,
                maxLines: 3,
                decoration: _inputDecoration('Ex: Desenvolver estratégias para lidar com a ansiedade e melhorar minha autoconfiança...'),
              ),
            ),
            const SizedBox(height: 18),

            // ── Pergunta 6: Nível de Desconforto ─────────────────
            _buildSectionCard(
              title: '6. Qual seu nível de incômodo ou sofrimento atual?',
              subtitle: 'De 1 (muito leve) a 10 (muito intenso).',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nível atual:', style: TextStyle(fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.patient.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_distressLevel.round()}/10',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.patient),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _distressLevel,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppColors.patient,
                    onChanged: (v) => setState(() => _distressLevel = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Botão de Envio ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patient,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: const Text(
                  'Enviar Ficha de Avaliação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
