import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/auth_error_translator.dart';
import 'complete_profile_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedRole; // 'psychologist' | 'patient'
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  Future<void> register() async {
    if (selectedRole == null) {
      _showError('Selecione se você é psicólogo ou paciente');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await AuthService.instance.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompleteProfilePage(role: selectedRole!),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError(AuthErrorTranslator.translate(e));
    }

    if (mounted) setState(() => loading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Criar conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passo 1 de 2 — Informações de acesso',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Seleção de perfil ────────────────────────
                    const Text(
                      'Você é...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            label: 'Psicólogo',
                            icon: Icons.psychology_rounded,
                            color: AppColors.psychologist,
                            selected: selectedRole == 'psychologist',
                            onTap: () => setState(() => selectedRole = 'psychologist'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleCard(
                            label: 'Paciente',
                            icon: Icons.person_rounded,
                            color: AppColors.patient,
                            selected: selectedRole == 'patient',
                            onTap: () => setState(() => selectedRole = 'patient'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── E-mail ───────────────────────────────────
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe seu e-mail';
                        if (!v.contains('@')) return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Senha ────────────────────────────────────
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe uma senha';
                        if (v.length < 6) return 'Mínimo de 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Confirmar senha ──────────────────────────
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v != passwordController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Botão continuar ──────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gradientStart, AppColors.gradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
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
                          onPressed: loading ? null : register,
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
                                    Text(
                                      'Continuar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : const Color(0xFFE0E7EF),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? color : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
