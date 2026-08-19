import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';

class JourneyService {
  final FirebaseFirestore _db;

  JourneyService({required FirebaseFirestore firestore}) : _db = firestore;

  Future<Map<String, dynamic>?> getJourney(String patientId) async {
    try {
      final snap = await _db
          .collection('therapy_journeys')
          .where('patient_id', isEqualTo: patientId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      return {'id': snap.docs.first.id, ...snap.docs.first.data()};
    } catch (e) {
      throw AppException('Erro ao buscar jornada: $e', originalError: e);
    }
  }

  Future<List<Map<String, dynamic>>> getSteps(String protocol) async {
    try {
      final snap = await _db
          .collection('journey_steps')
          .where('protocol', isEqualTo: protocol)
          .orderBy('phase')
          .get();

      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw AppException('Erro ao buscar passos: $e', originalError: e);
    }
  }

  Stream<Map<String, dynamic>?> streamJourney(String patientId) {
    return _db
        .collection('therapy_journeys')
        .where('patient_id', isEqualTo: patientId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return {'id': snap.docs.first.id, ...snap.docs.first.data()};
    });
  }
}