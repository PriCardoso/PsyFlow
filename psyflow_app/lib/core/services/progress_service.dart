import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressService {
  final supabase = Supabase.instance.client;

  Future<void> registerProgress({
    required String patientId,
    required String interventionCode,
    required int completionScore,
    required int moodBefore,
    required int moodAfter,
    String? feedback,
    String? taskId,
  }) async {
    await supabase
        .from('patient_intervention_progress')
        .insert({
      'patient_id': patientId,
      'task_id': taskId,
      'intervention_code': interventionCode,
      'completion_score': completionScore,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'patient_feedback': feedback,
      'completed_at':
          DateTime.now().toIso8601String(),
    });
  }
}