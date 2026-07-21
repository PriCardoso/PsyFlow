import 'package:firebase_auth/firebase_auth.dart';

/// Traduz erros de autenticação do Firebase para mensagens em português,
/// mais claras para o usuário final.
class AuthErrorTranslator {
  static String translate(Object error) {
    if (error is FirebaseAuthException) {
      final code = error.code;

      // Credenciais inválidas
      if (code == 'user-not-found' || code == 'wrong-password' || code == 'invalid-credential') {
        return 'Usuário e/ou senha incorretos.';
      }

      // E-mail não confirmado
      if (code == 'unverified-email') {
        return 'Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.';
      }

      // Usuário já existe (no cadastro)
      if (code == 'email-already-in-use') {
        return 'Este e-mail já está cadastrado. Tente fazer login.';
      }

      // E-mail inválido
      if (code == 'invalid-email') {
        return 'Informe um e-mail válido.';
      }

      // Senha muito curta / fraca
      if (code == 'weak-password') {
        return 'A senha deve ter no mínimo 6 caracteres.';
      }

      // Muitas tentativas
      if (code == 'too-many-requests') {
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      }

      // Operação não permitida
      if (code == 'operation-not-allowed') {
        return 'Esta operação não está habilitada. Contate o suporte.';
      }

      return error.message ?? 'Ocorreu um erro de autenticação.';
    }

    return 'Ocorreu um erro. Tente novamente.';
  }
}
