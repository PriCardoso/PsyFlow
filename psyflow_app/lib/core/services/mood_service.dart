import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/mood_model.dart';

class MoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Paciente registra como está se sentindo hoje
  Future<void> addEntry({
    required int mood,
    required int anxiety,
    required int energy,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await _db.collection('mood_entries').add({
        'patient_id': user.uid,
        'mood': mood,
        'anxiety': anxiety,
        'energy': energy,
        'notes': notes,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao registrar humor: $e');
    }
  }

  /// Paciente vê seu próprio histórico
  Future<List<MoodEntry>> getMyEntries({int limit = 30}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('mood_entries')
          .where('patient_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map((d) => MoodEntry.fromMap({'id': d.id, ...d.data()}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico: $e');
    }
  }

  /// Psicólogo vê o histórico de humor de um paciente vinculado
  Future<List<MoodEntry>> getPatientEntries(String patientId,
      {int limit = 30}) async {
    try {
      final snap = await _db
          .collection('mood_entries')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map((d) => MoodEntry.fromMap({'id': d.id, ...d.data()}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar histórico do paciente: $e');
    }
  }

  /// Verifica se o paciente já registrou hoje
  Future<bool> hasEntryToday() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final snap = await _db
          .collection('mood_entries')
          .where('patient_id', isEqualTo: user.uid)
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .limit(1)
          .get();

      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
