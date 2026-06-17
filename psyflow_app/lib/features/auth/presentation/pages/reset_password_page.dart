import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? code; // 👈 recebe o code da URL

  const ResetPasswordPage({super.key, this.code});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;
  bool sessionReady = false; // 👈 controla se o code foi trocado

  @override
  void initState() {
    super.initState();
    _exchangeCode(); // 👈 troca o code por sessão ao abrir a página
  }

  Future<void> _exchangeCode() async {
    final code = widget.code;
    if (code == null || code.isEmpty) {
      debugPrint('Nenhum code recebido');
      return;
    }

    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(code);
      setState(() => sessionReady = true);
    } catch (e) {
      debugPrint('Erro ao trocar code: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link inválido ou expirado.')),
      );
    }
  }

  Future<void> updatePassword() async {
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter pelo menos 6 caracteres')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: passwordController.text),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );

      // 👇 vai para login e limpa a pilha de navegação
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      debugPrint('Erro ao atualizar senha: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar senha. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 👇 avisa se o code ainda está sendo processado
            if (!sessionReady)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),

            TextField(
              controller: passwordController,
              obscureText: true,
              enabled: sessionReady, // 👈 desabilita até a sessão estar pronta
              decoration: const InputDecoration(labelText: 'Nova senha'),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: confirmController,
              obscureText: true,
              enabled: sessionReady,
              decoration: const InputDecoration(labelText: 'Confirmar senha'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: (loading || !sessionReady) ? null : updatePassword,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar senha'),
            ),
          ],
        ),
      ),
    );
  }
}