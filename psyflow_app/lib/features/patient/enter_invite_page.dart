import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/invite_service.dart';

class EnterInvitePage extends StatefulWidget {
  const EnterInvitePage({super.key});

  @override
  State<EnterInvitePage> createState() => _EnterInvitePageState();
}

class _EnterInvitePageState extends State<EnterInvitePage> {
  final codeController = TextEditingController();
  final _inviteService = InviteService();
  bool loading = false;
  Map<String, dynamic>? linkedPsychologist;

  @override
  void initState() {
    super.initState();
    _checkExistingLink();
  }

  Future<void> _checkExistingLink() async {
    try {
      final link = await _inviteService.getMyPsychologist();
      if (mounted) setState(() => linkedPsychologist = link);
    } catch (_) {}
  }

  Future<void> _useInvite() async {
    if (codeController.text.trim().isEmpty) {
      _showError('Digite o código do convite');
      return;
    }

    setState(() => loading = true);

    try {
      await _inviteService.useInvite(codeController.text);
      if (mounted) {
        codeController.clear();
        _checkExistingLink();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vínculo criado com sucesso! 🎉'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Psicólogo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Psicólogo vinculado ──────────────────────────
            if (linkedPsychologist != null) ...[
              const Text(
                'Psicólogo vinculado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.psychologist.withValues(alpha: 0.08),
                      AppColors.gradientEnd.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.psychologist.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.psychology_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            linkedPsychologist!['psychologist']['full_name'] ?? 'Psicólogo',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (linkedPsychologist!['psychologist']['crp'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'CRP: ${linkedPsychologist!['psychologist']['crp']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (linkedPsychologist!['psychologist']['bio'] != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              linkedPsychologist!['psychologist']['bio'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ── Inserir código ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  const Icon(Icons.key_rounded, color: AppColors.patient, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    linkedPsychologist == null
                        ? 'Inserir código de convite'
                        : 'Alterar psicólogo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Peça o código ao seu psicólogo e insira abaixo para criar o vínculo.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
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
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.patient, AppColors.accentLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.patient.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: loading ? null : _useInvite,
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Confirmar código',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
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