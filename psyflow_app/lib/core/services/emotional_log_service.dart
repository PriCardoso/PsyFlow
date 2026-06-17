import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionalLogService {
  final supabase = Supabase.instance.client;

  Future<void> saveLog({
    required String patientId,
    required int mood,
    required int anxiety,
    required int energy,
    String? notes,
  }) async {
    await supabase.from('emotional_logs').insert({
      'patient_id': patientId,
      'mood_score': mood,
      'anxiety_score': anxiety,
      'energy_score': energy,
      'notes': notes,
    });
  }

  Future<List<Map<String, dynamic>>> getLogs(
    String patientId,
  ) async {
    final result = await supabase
        .from('emotional_logs')
        .select()
        .eq('patient_id', patientId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(result);
  }
}