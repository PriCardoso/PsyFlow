import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduz erros de autenticação do Supabase para mensagens em português,
/// mais claras para o usuário final.
class AuthErrorTranslator {
  static String translate(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();

      // Credenciais inválidas (e-mail não cadastrado OU senha errada —
      // o Supabase não diferencia por segurança, então usamos uma
      // mensagem que cobre os dois casos sem expor qual deles é)
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid email or password')) {
        return 'Usuário e/ou senha incorretos.';
      }

      // E-mail não confirmado
      if (msg.contains('email not confirmed')) {
        return 'Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.';
      }

      // Usuário já existe (no cadastro)
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return 'Este e-mail já está cadastrado. Tente fazer login.';
      }

      // E-mail inválido
      if (msg.contains('invalid email') || msg.contains('unable to validate email')) {
        return 'Informe um e-mail válido.';
      }

      // Senha muito curta / fraca
      if (msg.contains('password should be at least') || msg.contains('weak password')) {
        return 'A senha deve ter no mínimo 6 caracteres.';
      }

      // Muitas tentativas
      if (msg.contains('rate limit') || msg.contains('too many requests')) {
        return 'Muitas tentativas. Aguarde um momento e tente novamente.';
      }

      // Usuário não encontrado (alguns fluxos do Supabase retornam isso)
      if (msg.contains('user not found')) {
        return 'Usuário não cadastrado.';
      }

      return error.message;
    }

    return 'Ocorreu um erro. Tente novamente.';
  }
}
