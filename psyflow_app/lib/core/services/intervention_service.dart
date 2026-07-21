import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/intervention_template.dart';

class InterventionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<InterventionTemplate>> getTemplates() async {
    final snap = await _db
        .collection('intervention_templates')
        .where('is_active', isEqualTo: true)
        .orderBy('category')
        .get();

    return snap.docs
        .map((d) => InterventionTemplate.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<InterventionTemplate>> getByCategory(String category) async {
    final snap = await _db
        .collection('intervention_templates')
        .where('category', isEqualTo: category)
        .where('is_active', isEqualTo: true)
        .get();

    return snap.docs
        .map((d) => InterventionTemplate.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }
}