import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/intervention_template.dart';
import '../../core/errors/app_exception.dart';

class InterventionService {
  final FirebaseFirestore _db;

  InterventionService({required FirebaseFirestore firestore}) : _db = firestore;

  Future<List<InterventionTemplate>> getTemplates() async {
    try {
      final snap = await _db
          .collection('intervention_templates')
          .where('is_active', isEqualTo: true)
          .orderBy('category')
          .get();

      return snap.docs
          .map((d) => InterventionTemplate.fromMap({'id': d.id, ...d.data()}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar templates: $e', originalError: e);
    }
  }

  Future<List<InterventionTemplate>> getByCategory(String category) async {
    try {
      final snap = await _db
          .collection('intervention_templates')
          .where('category', isEqualTo: category)
          .where('is_active', isEqualTo: true)
          .get();

      return snap.docs
          .map((d) => InterventionTemplate.fromMap({'id': d.id, ...d.data()}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar templates: $e', originalError: e);
    }
  }

  Stream<List<InterventionTemplate>> streamTemplates() {
    return _db
        .collection('intervention_templates')
        .where('is_active', isEqualTo: true)
        .orderBy('category')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InterventionTemplate.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }
}