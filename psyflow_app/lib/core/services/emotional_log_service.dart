import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionalLogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveLog({
    required String patientId,
    required int mood,
    required int anxiety,
    required int energy,
    String? notes,
  }) async {
    await _db.collection('emotional_logs').add({
      'patient_id': patientId,
      'mood_score': mood,
      'anxiety_score': anxiety,
      'energy_score': energy,
      'notes': notes,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getLogs(
    String patientId,
  ) async {
    final snap = await _db
        .collection('emotional_logs')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at')
        .get();

    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}