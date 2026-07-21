import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) throw Exception('Usuário não encontrado.');

      // Re-autentica com a senha atual
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // Atualiza para a nova senha
      await user.updatePassword(_newController.text.trim());

      if (mounted) {
        _showSnack('Senha alterada com sucesso!');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final msg = e.code == 'wrong-password'
            ? 'Senha atual incorreta.'
            : e.message ?? 'Erro ao alterar senha.';
        _showSnack(msg, error: true);
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString().replaceAll('Exception: ', ''), error: true);
    }

    if (mounted) setState(() => _loading = false);
  }

  InputDecoration _inputDecor(String label, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: AppColors.textSecondary),
        onPressed: toggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alterar senha',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para sua segurança, confirme sua senha atual antes de definir uma nova.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7ECF1)),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _currentController,
                      obscureText: _obscureCurrent,
                      decoration: _inputDecor(
                        'Senha atual',
                        _obscureCurrent,
                        () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe sua senha atual';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE7ECF1)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newController,
                      obscureText: _obscureNew,
                      decoration: _inputDecor(
                        'Nova senha',
                        _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                        if (v == _currentController.text) return 'A nova senha deve ser diferente da atual';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: _inputDecor(
                        'Confirmar nova senha',
                        _obscureConfirm,
                        () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v != _newController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Dicas de senha
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.psychologist.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dicas para uma senha forte:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    ...[
                      'Mínimo de 6 caracteres',
                      'Misture letras, números e símbolos',
                      'Evite datas de nascimento e sequências simples',
                    ].map((tip) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_rounded, size: 14, color: AppColors.psychologist),
                              const SizedBox(width: 6),
                              Text(tip, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.psychologist,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Alterar senha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
