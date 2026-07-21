import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/invite_service.dart';
import '../../models/patient_link_model.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  final _inviteService = InviteService();
  String? generatedCode;
  bool generating = false;
  List<Map<String, dynamic>> invites = [];
  List<PatientLink> patients = [];
  bool loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loadingData = true);
    try {
      final i = await _inviteService.getMyInvites();
      final p = await _inviteService.getMyPatients();
      if (mounted) setState(() { invites = i; patients = p; });
    } catch (_) {}
    if (mounted) setState(() => loadingData = false);
  }

  Future<void> _generateCode() async {
    setState(() => generating = true);
    try {
      final code = await _inviteService.generateInvite();
      if (mounted) {
        setState(() => generatedCode = code);
        _loadData();
      }
    } catch (e) {
      if (mounted) _showError('Erro ao gerar convite: $e');
    }
    if (mounted) setState(() => generating = false);
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Código copiado!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
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
        title: const Text('Vincular Paciente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loadingData
          ? const Center(child: CircularProgressIndicator(color: AppColors.psychologist))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Gerar convite ────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code_rounded, color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Gerar código de convite',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'O paciente usa o código para se vincular a você. Válido por 7 dias.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Código gerado
                        if (generatedCode != null) ...[
                          GestureDetector(
                            onTap: () => _copyCode(generatedCode!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    generatedCode!,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: 6,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Botão gerar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: generating ? null : _generateCode,
                            child: generating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    generatedCode == null ? 'Gerar código' : 'Gerar novo código',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Pacientes vinculados ─────────────────────
                  const Text(
                    'Pacientes vinculados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (patients.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E7EF)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 40, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 10),
                          const Text(
                            'Nenhum paciente vinculado ainda',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  else
                    ...patients.map((link) {
                      final patient = link.patient;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.patient.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: AppColors.patient, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    patient.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Ativo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}