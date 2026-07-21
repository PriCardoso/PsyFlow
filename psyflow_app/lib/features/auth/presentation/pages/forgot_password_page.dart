import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final emailController = TextEditingController();

  bool loading = false;

  Future<void> sendResetEmail() async {
    try {
      setState(() {
        loading = true;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email enviado com sucesso',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recuperar Senha',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading
                  ? null
                  : sendResetEmail,
              child: const Text(
                'Enviar Email',
              ),
            ),
          ],
        ),
      ),
    );
  }
}