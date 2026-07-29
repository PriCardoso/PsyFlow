import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_link_model.dart';

abstract class PatientRepository {
  Future<List<PatientLink>> getPatientsForProfessional(String professionalId);
  Future<Map<String, dynamic>?> getProfessionalForPatient(String patientId);
  Future<void> deactivateLink(String linkId);
  Future<void> reactivateLink(String linkId);
}

class FirestorePatientRepository implements PatientRepository {
  final FirebaseFirestore _db;

  FirestorePatientRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<PatientLink>> getPatientsForProfessional(String professionalId) async {
    final snap = await _db
        .collection('links')
        .where('psychologist_id', isEqualTo: professionalId)
        .orderBy('created_at', descending: true)
        .get();

    if (snap.docs.isEmpty) return [];

    final links = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    final patientIds = links
        .map((l) => l['patient_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (patientIds.isEmpty) return [];

    // Otimização de N+1 queries usando batch whereIn (máximo 30 por batch)
    final Map<String, Map<String, dynamic>> userMap = {};
    for (var i = 0; i < patientIds.length; i += 30) {
      final chunk = patientIds.sublist(
        i,
        i + 30 > patientIds.length ? patientIds.length : i + 30,
      );
      final usersSnap = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in usersSnap.docs) {
        userMap[doc.id] = {'id': doc.id, ...doc.data()};
      }
    }

    // Enriquecer vínculos com os dados dos usuários
    for (final link in links) {
      final pId = link['patient_id'] as String?;
      if (pId != null && userMap.containsKey(pId)) {
        link['patient'] = userMap[pId];
      }
    }

    return links.map((m) => PatientLink.fromMap(m)).toList();
  }

  @override
  Future<Map<String, dynamic>?> getProfessionalForPatient(String patientId) async {
    final snap = await _db
        .collection('links')
        .where('patient_id', isEqualTo: patientId)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final link = {'id': snap.docs.first.id, ...snap.docs.first.data()};
    final psychId = link['psychologist_id'] as String?;

    if (psychId != null) {
      final psychDoc = await _db.collection('users').doc(psychId).get();
      if (psychDoc.exists && psychDoc.data() != null) {
        link['psychologist'] = {'id': psychDoc.id, ...psychDoc.data()!};
      }
    }

    return link;
  }

  @override
  Future<void> deactivateLink(String linkId) async {
    await _db.collection('links').doc(linkId).update({'active': false});
  }

  @override
  Future<void> reactivateLink(String linkId) async {
    await _db.collection('links').doc(linkId).update({'active': true});
  }
}
