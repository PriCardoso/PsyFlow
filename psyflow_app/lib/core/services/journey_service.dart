import 'package:cloud_firestore/cloud_firestore.dart';

class JourneyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getJourney(String patientId) async {
    final snap = await _db
        .collection('therapy_journeys')
        .where('patient_id', isEqualTo: patientId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return {'id': snap.docs.first.id, ...snap.docs.first.data()};
  }

  Future<List<Map<String, dynamic>>> getSteps(String protocol) async {
    final snap = await _db
        .collection('journey_steps')
        .where('protocol', isEqualTo: protocol)
        .orderBy('phase')
        .get();

    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}