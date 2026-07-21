import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveRecommendation({
    required String patientId,
    required String recommendation,
    required String type,
    required String severity,
  }) async {
    await _db.collection('ai_recommendations').add({
      'patient_id': patientId,
      'recommendation': recommendation,
      'recommendation_type': type,
      'severity': severity,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getRecommendations(
    String patientId,
  ) async {
    final snap = await _db
        .collection('ai_recommendations')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}