import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/patient_link_model.dart';

class InviteService {
  final supabase = Supabase.instance.client;

  /// Gera um código de convite único para o psicólogo
  Future<String> generateInvite() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final codeResult = await supabase.rpc('generate_invite_code');
      final code = codeResult as String;

      await supabase.from('invites').insert({
        'psychologist_id': user.id,
        'code': code,
      });

      return code;
    } catch (e) {
      throw Exception('Erro ao gerar convite: $e');
    }
  }

  /// Lista todos os convites do psicólogo
  Future<List<Map<String, dynamic>>> getMyInvites() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('invites')
          .select()
          .eq('psychologist_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erro ao buscar convites: $e');
    }
  }

  /// Paciente usa o código para se vincular ao psicólogo
  Future<void> useInvite(String code) async {
    final patient = supabase.auth.currentUser;
    if (patient == null) throw Exception('Usuário não autenticado.');

    try {
      final invite = await supabase
          .from('invites')
          .select()
          .eq('code', code.toUpperCase().trim())
          .eq('used', false)
          .maybeSingle();

      if (invite == null) {
        throw Exception('Código inválido ou já utilizado.');
      }

      final expiresAt = DateTime.parse(invite['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Este código expirou. Peça um novo ao seu psicólogo.');
      }

      if (invite['psychologist_id'] == patient.id) {
        throw Exception('Você não pode usar seu próprio convite.');
      }

      await supabase.from('links').insert({
        'psychologist_id': invite['psychologist_id'],
        'patient_id': patient.id,
        'invite_id': invite['id'],
      });

      await supabase.from('invites').update({
        'used': true,
        'used_by': patient.id,
      }).eq('id', invite['id']);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao usar convite: $e');
    }
  }

  /// Lista pacientes vinculados ao psicólogo (ativos e inativos)
  Future<List<PatientLink>> getMyPatients() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('links')
          .select('*, patient:patient_id(id, full_name, email, bio, phone)')
          .eq('psychologist_id', user.id)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => PatientLink.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar pacientes: $e');
    }
  }

  /// Desativa o vínculo com um paciente
  Future<void> deactivateLink(String linkId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await supabase
          .from('links')
          .update({'active': false})
          .eq('id', linkId)
          .eq('psychologist_id', user.id); // segurança: só o próprio psicólogo pode desvincular
    } catch (e) {
      throw Exception('Erro ao desvincular paciente: $e');
    }
  }

  /// Reativa o vínculo com um paciente
  Future<void> reactivateLink(String linkId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await supabase
          .from('links')
          .update({'active': true})
          .eq('id', linkId)
          .eq('psychologist_id', user.id);
    } catch (e) {
      throw Exception('Erro ao reativar vínculo: $e');
    }
  }

  /// Retorna o psicólogo vinculado ao paciente
  Future<Map<String, dynamic>?> getMyPsychologist() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('links')
          .select('*, psychologist:psychologist_id(id, full_name, email, crp, bio)')
          .eq('patient_id', user.id)
          .eq('active', true)
          .maybeSingle();

      return data;
    } catch (e) {
      throw Exception('Erro ao buscar psicólogo: $e');
    }
  }
}
