import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerProgress({
    required String patientId,
    required String interventionCode,
    required int completionScore,
    required int moodBefore,
    required int moodAfter,
    String? feedback,
    String? taskId,
  }) async {
    await _db.collection('patient_intervention_progress').add({
      'patient_id': patientId,
      'task_id': taskId,
      'intervention_code': interventionCode,
      'completion_score': completionScore,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'patient_feedback': feedback,
      'completed_at': FieldValue.serverTimestamp(),
    });
  }
}