import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordResetService {
  final supabase = Supabase.instance.client;

  String generateCode() {
    final random = Random();

    return (100000 + random.nextInt(900000)).toString();
  }

  Future<String> createCode(String email) async {
    final code = generateCode();

    await supabase
        .from('password_reset_codes')
        .insert({
      'email': email,
      'code': code,
      'expires_at': DateTime.now()
          .add(const Duration(minutes: 15))
          .toIso8601String(),
    });

    return code;
  }

  Future<bool> validateCode({
    required String email,
    required String code,
  }) async {
    final result = await supabase
        .from('password_reset_codes')
        .select()
        .eq('email', email)
        .eq('code', code)
        .eq('used', false)
        .maybeSingle();

    if (result == null) {
      return false;
    }

    final expires =
        DateTime.parse(result['expires_at']);

    return expires.isAfter(DateTime.now());
  }

  Future<void> markAsUsed(
    String email,
    String code,
  ) async {
    await supabase
        .from('password_reset_codes')
        .update({
      'used': true,
    })
        .match({
      'email': email,
      'code': code,
    });
  }
}