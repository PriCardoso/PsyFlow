import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_service.dart';
import '../pages/login_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final crpController = TextEditingController();
  final bioController = TextEditingController();

  bool loading = true;
  bool saving = false;
  String? role;
  String? email;

  bool get isPsychologist => role == 'psychologist';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await UserService().getProfile();
    if (data != null && mounted) {
      setState(() {
        role = data['role'];
        email = data['email'];
        fullNameController.text = data['full_name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        crpController.text = data['crp'] ?? '';
        bioController.text = data['bio'] ?? '';
        loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);

    try {
      await UserService().saveProfile(
        role: role!,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        crp: crpController.text.trim().isEmpty ? null : crpController.text.trim(),
        bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError('Erro ao salvar: $e');
    }

    if (mounted) setState(() => saving = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    }
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

  String get _initials {
    final name = fullNameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header com avatar ───────────────────────
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
                        children: [
                          Row(
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
                              const Spacer(),
                              GestureDetector(
                                onTap: _logout,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Avatar com iniciais
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            fullNameController.text.isEmpty ? 'Seu nome' : fullNameController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email ?? '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPsychologist ? 'Psicólogo' : 'Paciente',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Formulário ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações pessoais',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nome
                          TextFormField(
                            controller: fullNameController,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Nome completo',
                              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Informe seu nome';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Telefone
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

                          // CRP — só psicólogo
                          if (isPsychologist) ...[
                            TextFormField(
                              controller: crpController,
                              decoration: const InputDecoration(
                                labelText: 'CRP',
                                prefixIcon: Icon(Icons.verified_outlined, color: AppColors.textSecondary),
                                hintText: 'Ex: 06/123456',
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Bio
                          TextFormField(
                            controller: bioController,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: isPsychologist
                                  ? 'Apresentação profissional'
                                  : 'Sobre você',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 40),
                                child: Icon(Icons.notes_rounded, color: AppColors.textSecondary),
                              ),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Botão salvar
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
                                onPressed: saving ? null : _save,
                                child: saving
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
                                          Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Salvar alterações',
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

                          const SizedBox(height: 16),

                          // Botão sair
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _logout,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sair da conta',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
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