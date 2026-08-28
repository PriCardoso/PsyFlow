import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/invite_service.dart';
import '../../core/di/service_locator.dart';
import '../mood/mood_page.dart';
import 'initial_assessment_page.dart';

class EnterInvitePage extends StatefulWidget {
  const EnterInvitePage({super.key});

  @override
  State<EnterInvitePage> createState() => _EnterInvitePageState();
}

class _EnterInvitePageState extends State<EnterInvitePage> {
  final codeController = TextEditingController();
  final _inviteService = sl<InviteService>();
  bool loading = false;
  Map<String, dynamic>? linkedPsychologist;
  Map<String, dynamic>? initialAssessment;
  bool checkingData = true;

  @override
  void initState() {
    super.initState();
    _checkExistingLink();
  }

  Future<void> _checkExistingLink() async {
    setState(() => checkingData = true);
    try {
      final link = await _inviteService.getMyPsychologist();
      Map<String, dynamic>? assessment;
      if (link != null) {
        assessment = await _inviteService.getMyInitialAssessment();
      }
      if (mounted) {
        setState(() {
          linkedPsychologist = link;
          initialAssessment = assessment;
          checkingData = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => checkingData = false);
    }
  }

  Future<void> _useInvite() async {
    if (codeController.text.trim().isEmpty) {
      _showError('Digite o código de 6 dígitos');
      return;
    }

    setState(() => loading = true);

    try {
      await _inviteService.useInvite(codeController.text);
      if (mounted) {
        codeController.clear();
        await _checkExistingLink();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Vínculo criado com sucesso! 🟢 Ativo')),
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

    if (mounted) setState(() => loading = false);
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
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final psych = linkedPsychologist?['psychologist'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Psicólogo & Vínculo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: checkingData
          ? const Center(child: CircularProgressIndicator(color: AppColors.patient))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Se JÁ ESTÁ VINCULADO ──────────────────────────
                  if (linkedPsychologist != null && psych != null) ...[
                    // Card do Psicólogo Vinculado
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            psych['full_name'] ?? 'Psicólogo(a)',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
                                              SizedBox(width: 4),
                                              Text(
                                                'Vínculo Ativo',
                                                style: TextStyle(
                                                  color: AppColors.success,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (psych['crp'] != null && psych['crp'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'CRP: ${psych['crp']}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                    if (psych['email'] != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        psych['email'],
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (psych['bio'] != null && psych['bio'].toString().isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              psych['bio'],
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Card da Ficha de Avaliação Inicial Pré-Consulta ──
                    if (initialAssessment == null)
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
                                  child: const Text(
                                    '📋 Etapa Pré-Consulta',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  '⏱️ ~5 min',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Ficha de Avaliação Inicial',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Antes da sua primeira consulta, responda algumas perguntas para ajudar seu psicólogo a conhecer melhor seu momento atual.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0D9488),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InitialAssessmentPage(
                                        psychologistId: linkedPsychologist!['psychologist_id'],
                                        psychologistName: psych['full_name'] ?? 'seu psicólogo',
                                        onSubmitted: _checkExistingLink,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Começar avaliação inicial',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.task_alt_rounded, color: AppColors.success, size: 24),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ficha Inicial Respondida',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Seu psicólogo já tem acesso aos seus dados pré-consulta.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ── Atalhos de Acompanhamento Pré-Consulta ──────
                    const Text(
                      'Recursos de Acompanhamento Liberados',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodPage())),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                              ),
                              child: const Column(
                                children: [
                                  Text('😊', style: TextStyle(fontSize: 24)),
                                  SizedBox(height: 6),
                                  Text('Check-in de Humor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodPage())),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                              ),
                              child: const Column(
                                children: [
                                  Text('😴', style: TextStyle(fontSize: 24)),
                                  SizedBox(height: 6),
                                  Text('Monitorar Sono', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ── Inserir código de 6 dígitos ───────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.key_rounded, color: AppColors.patient, size: 28),
                        const SizedBox(height: 10),
                        Text(
                          linkedPsychologist == null
                              ? 'Vincular ao psicólogo (Código de 6 dígitos)'
                              : 'Vincular a outro psicólogo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Insira o código de 6 dígitos fornecido pelo seu profissional antes ou depois da primeira consulta.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: '• • • • • •',
                            hintStyle: TextStyle(
                              fontSize: 24,
                              letterSpacing: 6,
                              color: AppColors.textSecondary,
                            ),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.patient,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: loading ? null : _useInvite,
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Ativar Vínculo',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}