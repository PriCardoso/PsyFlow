import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';

class EmotionalLogService {
  final FirebaseFirestore _db;

  EmotionalLogService({required FirebaseFirestore firestore}) : _db = firestore;

  Future<void> saveLog({
    required String patientId,
    required int mood,
    required int anxiety,
    required int energy,
    String? notes,
  }) async {
    try {
      await _db.collection('emotional_logs').add({
        'patient_id': patientId,
        'mood_score': mood,
        'anxiety_score': anxiety,
        'energy_score': energy,
        'notes': notes,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException('Erro ao salvar registro: $e', originalError: e);
    }
  }

  Future<List<Map<String, dynamic>>> getLogs(
    String patientId,
  ) async {
    try {
      final snap = await _db
          .collection('emotional_logs')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at')
          .get();

      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw AppException('Erro ao buscar registros: $e', originalError: e);
    }
  }

  Stream<List<Map<String, dynamic>>> streamLogs(String patientId) {
    return _db
        .collection('emotional_logs')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at')
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}