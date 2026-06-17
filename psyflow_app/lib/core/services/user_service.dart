import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<void> saveProfile({
    required String role,
    required String fullName,
    String? phone,
    String? crp,
    String? bio,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    await supabase.from('users').upsert({
      'id': user.id,
      'email': user.email,
      'role': role,
      'full_name': fullName,
      'phone': phone,
      'crp': crp,
      'bio': bio,
      'profile_complete': true,
    });
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (e) {
      throw Exception('Erro ao carregar perfil: $e');
    }
  }
}
