import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mood_model.dart';

class MoodService {
  final supabase = Supabase.instance.client;

  /// Paciente registra como está se sentindo hoje
  Future<void> addEntry({
    required int mood,
    required int anxiety,
    required int energy,
    String? notes,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await supabase.from('mood_entries').insert({
        'patient_id': user.id,
        'mood': mood,
        'anxiety': anxiety,
        'energy': energy,
        'notes': notes,
      });
    } catch (e) {
      throw Exception('Erro ao registrar humor: $e');
    }
  }

  /// Paciente vê seu próprio histórico
  Future<List<MoodEntry>> getMyEntries({int limit = 30}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('mood_entries')
          .select()
          .eq('patient_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((item) => MoodEntry.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico: $e');
    }
  }

  /// Psicólogo vê o histórico de humor de um paciente vinculado
  Future<List<MoodEntry>> getPatientEntries(String patientId, {int limit = 30}) async {
    try {
      final data = await supabase
          .from('mood_entries')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((item) => MoodEntry.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico do paciente: $e');
    }
  }

  /// Verifica se o paciente já registrou hoje
  Future<bool> hasEntryToday() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    try {
      final data = await supabase
          .from('mood_entries')
          .select('id')
          .eq('patient_id', user.id)
          .gte('created_at', startOfDay)
          .limit(1);

      return (data as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
