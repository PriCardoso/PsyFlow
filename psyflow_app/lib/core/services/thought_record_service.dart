import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/thought_record_model.dart';
import '../errors/app_exception.dart';

class ThoughtRecordService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ThoughtRecordService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  /// 1. Cria um novo Registro de Pensamento (RPD)
  Future<String> createThoughtRecord({
    required String situation,
    String? location,
    String? trigger,
    required List<EmotionIntensityItem> emotions,
    required String automaticThought,
    int beliefInitial = 80,
    required List<String> cognitiveDistortions,
    String? evidenceFor,
    String? evidenceAgainst,
    required String rationalResponse,
    int? beliefFinal,
    List<EmotionIntensityItem> emotionsAfter = const [],
    String? behavior,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final docRef = _db.collection('thought_records').doc();
      final record = ThoughtRecordEntry(
        id: docRef.id,
        patientId: user.uid,
        patientName: user.displayName ?? 'Paciente',
        createdAt: DateTime.now(),
        situation: situation.trim(),
        location: location?.trim(),
        trigger: trigger?.trim(),
        emotions: emotions,
        automaticThought: automaticThought.trim(),
        beliefInitial: beliefInitial,
        cognitiveDistortions: cognitiveDistortions,
        evidenceFor: evidenceFor?.trim(),
        evidenceAgainst: evidenceAgainst?.trim(),
        rationalResponse: rationalResponse.trim(),
        beliefFinal: beliefFinal,
        emotionsAfter: emotionsAfter,
        behavior: behavior?.trim(),
        tags: tags,
      );

      await docRef.set(record.toMap());
      return docRef.id;
    } catch (e) {
      throw AppException('Erro ao salvar Registro de Pensamento: $e', originalError: e);
    }
  }

  /// 2. Busca os RPDs do paciente autenticado
  Future<List<ThoughtRecordEntry>> getMyThoughtRecords() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    return getPatientThoughtRecords(user.uid);
  }

  /// 3. Busca os RPDs de um paciente específico (para o psicólogo)
  Future<List<ThoughtRecordEntry>> getPatientThoughtRecords(String patientId) async {
    try {
      final snap = await _db
          .collection('thought_records')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs
          .map((d) => ThoughtRecordEntry.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      // Fallback sem ordenação caso índice composto esteja provisionando
      try {
        final snap = await _db
            .collection('thought_records')
            .where('patient_id', isEqualTo: patientId)
            .get();

        final list = snap.docs
            .map((d) => ThoughtRecordEntry.fromMap(d.data(), d.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      } catch (_) {
        return [];
      }
    }
  }

  /// 4. Exclui um RPD
  Future<void> deleteThoughtRecord(String id) async {
    try {
      await _db.collection('thought_records').doc(id).delete();
    } catch (e) {
      throw AppException('Erro ao excluir Registro de Pensamento: $e', originalError: e);
    }
  }

  /// ─── Métodos Analíticos & Estatísticos para o Psicólogo (Estilo Cogni) ───

  /// Calcula a distribuição de frequência de cada distorção cognitiva
  Map<String, int> getDistortionDistribution(List<ThoughtRecordEntry> records) {
    final map = <String, int>{};
    for (final r in records) {
      for (final d in r.cognitiveDistortions) {
        map[d] = (map[d] ?? 0) + 1;
      }
    }
    return map;
  }

  /// Calcula a taxa média (%) de alívio / redução emocional obtida pelos RPDs
  double getAverageEmotionReduction(List<ThoughtRecordEntry> records) {
    if (records.isEmpty) return 0.0;
    int sum = 0;
    int count = 0;

    for (final r in records) {
      final relief = r.averageRelief;
      if (relief > 0) {
        sum += relief;
        count++;
      }
    }

    return count > 0 ? (sum / count) : 0.0;
  }

  /// Identifica os principais gatilhos e contextos problemáticos
  Map<String, int> getTopTriggers(List<ThoughtRecordEntry> records) {
    final map = <String, int>{};
    for (final r in records) {
      if (r.trigger != null && r.trigger!.trim().isNotEmpty) {
        map[r.trigger!.trim()] = (map[r.trigger!.trim()] ?? 0) + 1;
      }
      for (final tag in r.tags) {
        if (tag.trim().isNotEmpty) {
          map[tag.trim()] = (map[tag.trim()] ?? 0) + 1;
        }
      }
    }
    return map;
  }
}
