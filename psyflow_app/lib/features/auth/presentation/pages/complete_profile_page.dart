import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/user_service.dart';
import '../../../dashboard/pages/psychologist_dashboard_page.dart';
import '../../../dashboard/pages/patient_dashboard_page.dart';

class CompleteProfilePage extends StatefulWidget {
  final String role;

  const CompleteProfilePage({super.key, required this.role});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final crpController = TextEditingController();
  final bioController = TextEditingController();

  bool loading = false;

  bool get isPsychologist => widget.role == 'psychologist';

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await UserService().saveProfile(
        role: widget.role,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        crp: crpController.text.trim().isEmpty ? null : crpController.text.trim(),
        bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => isPsychologist
                ? const PsychologistDashboardPage()
                : const PatientDashboardPage(),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perfil: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    crpController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = isPsychologist ? AppColors.psychologist : AppColors.patient;
    final roleLabel = isPsychologist ? 'Psicólogo' : 'Paciente';
    final roleIcon = isPsychologist ? Icons.psychology_rounded : Icons.person_rounded;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [roleColor, AppColors.gradientEnd],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(roleIcon, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            roleLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Complete seu perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passo 2 de 2 — Quase lá!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome completo
                    TextFormField(
                      controller: fullNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe seu nome';
                        if (v.trim().length < 3) return 'Nome muito curto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Telefone (opcional)
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone (opcional)',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                        hintText: '(11) 99999-9999',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CRP — apenas para psicólogos
                    if (isPsychologist) ...[
                      TextFormField(
                        controller: crpController,
                        decoration: const InputDecoration(
                          labelText: 'CRP',
                          prefixIcon: Icon(Icons.verified_outlined, color: AppColors.textSecondary),
                          hintText: 'Ex: 06/123456',
                        ),
                        validator: isPsychologist
                            ? (v) {
                                if (v == null || v.trim().isEmpty) return 'Informe seu CRP';
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Breve apresentação (opcional)
                    TextFormField(
                      controller: bioController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: isPsychologist
                            ? 'Apresentação profissional (opcional)'
                            : 'Sobre você (opcional)',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes_rounded, color: AppColors.textSecondary),
                        ),
                        hintText: isPsychologist
                            ? 'Ex: Especialista em TCC com 5 anos de experiência...'
                            : 'Ex: Busco apoio para lidar com ansiedade...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botão salvar e acessar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [roleColor, AppColors.gradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: roleColor.withValues(alpha: 0.35),
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
                          onPressed: loading ? null : saveProfile,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Salvar e acessar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
