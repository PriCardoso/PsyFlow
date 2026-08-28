import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/mood_model.dart';
import '../../models/assessment_template_model.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/retry.dart';

class MoodService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  MoodService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  /// Paciente registra o check-in do dia com métricas completas (1 a 10)
  Future<void> addEntry({
    required int mood,
    required int anxiety,
    required int energy,
    int sleepQuality = 6,
    int stress = 5,
    String? notes,
    List<String> factors = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      await retry(() async {
        await _db.collection('mood_entries').add({
          'patient_id': user.uid,
          'mood': mood.clamp(1, 10),
          'anxiety': anxiety.clamp(1, 10),
          'energy': energy.clamp(1, 10),
          'sleep_quality': sleepQuality.clamp(1, 10),
          'stress': stress.clamp(1, 10),
          'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
          'factors': factors,
          'created_at': FieldValue.serverTimestamp(),
        });
      }, retries: 3, initialDelay: Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao registrar acompanhamento: $e', originalError: e);
    }
  }

  /// Paciente vê seu próprio histórico
  Future<List<MoodEntry>> getMyEntries({int limit = 60, DateTime? since}) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      return await retry(() async {
        Query query = _db
            .collection('mood_entries')
            .where('patient_id', isEqualTo: user.uid);

        if (since != null) {
          query = query.where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(since));
        }

        final snap = await query.orderBy('created_at', descending: true).limit(limit).get();

        return snap.docs
            .map((d) => MoodEntry.fromMap({'id': d.id, ...(d.data() as Map<String, dynamic>)}))
            .toList();
      }, retries: 3, initialDelay: Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao buscar histórico: $e', originalError: e);
    }
  }

  /// Stream em tempo real do histórico do paciente
  Stream<List<MoodEntry>> moodStreamForPatient(String patientId) {
    return _db
        .collection('mood_entries')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MoodEntry.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  /// Psicólogo busca histórico de um paciente vinculado por período
  Future<List<MoodEntry>> getPatientEntries(
    String patientId, {
    int limit = 90,
    DateTime? since,
  }) async {
    try {
      return await retry(() async {
        Query query = _db
            .collection('mood_entries')
            .where('patient_id', isEqualTo: patientId);

        if (since != null) {
          query = query.where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(since));
        }

        final snap = await query.orderBy('created_at', descending: true).limit(limit).get();

        return snap.docs
            .map((d) => MoodEntry.fromMap({'id': d.id, ...(d.data() as Map<String, dynamic>)}))
            .toList();
      }, retries: 3, initialDelay: Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao buscar histórico do paciente: $e', originalError: e);
    }
  }

  /// Verifica se o paciente já realizou check-in hoje
  Future<bool> hasEntryToday() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      return await retry(() async {
        final snap = await _db
            .collection('mood_entries')
            .where('patient_id', isEqualTo: user.uid)
            .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .limit(1)
            .get();

        return snap.docs.isNotEmpty;
      }, retries: 2, initialDelay: Duration(milliseconds: 200));
    } catch (_) {
      return false;
    }
  }

  /// Configuração de check-in para o paciente
  Future<AssessmentTemplate> getPatientAssessmentConfig(String patientId) async {
    try {
      return await retry(() async {
        final doc = await _db.collection('assessment_templates').doc(patientId).get();
        if (doc.exists && doc.data() != null) {
          return AssessmentTemplate.fromMap(doc.data()!, doc.id);
        }
        return AssessmentTemplate.defaultDaily;
      }, retries: 2, initialDelay: Duration(milliseconds: 200));
    } catch (_) {
      return AssessmentTemplate.defaultDaily;
    }
  }

  Future<void> savePatientAssessmentConfig(String patientId, AssessmentTemplate config) async {
    try {
      await retry(() async {
        await _db.collection('assessment_templates').doc(patientId).set(
              config.toMap(),
              SetOptions(merge: true),
            );
      }, retries: 3, initialDelay: Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao salvar configuração de check-in: $e', originalError: e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Métricas Analíticas e Cruzamentos (PsyFlow Insights)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Calcula médias dos indicadores
  Map<String, double> calculateAverages(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return {
        'mood': 0.0,
        'anxiety': 0.0,
        'energy': 0.0,
        'sleep': 0.0,
        'stress': 0.0,
      };
    }

    double sumMood = 0;
    double sumAnxiety = 0;
    double sumEnergy = 0;
    double sumSleep = 0;
    double sumStress = 0;

    for (final e in entries) {
      sumMood += e.mood;
      sumAnxiety += e.anxiety;
      sumEnergy += e.energy;
      sumSleep += e.sleepQuality;
      sumStress += e.stress;
    }

    final count = entries.length.toDouble();
    return {
      'mood': sumMood / count,
      'anxiety': sumAnxiety / count,
      'energy': sumEnergy / count,
      'sleep': sumSleep / count,
      'stress': sumStress / count,
    };
  }

  /// Calcula variação percentual entre a última semana e a semana anterior
  Map<String, double?> calculateWeeklyTrend(List<MoodEntry> entries) {
    if (entries.length < 2) {
      return {'moodDiff': null, 'anxietyDiff': null, 'sleepDiff': null};
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final recentEntries = entries.where((e) => e.createdAt.isAfter(sevenDaysAgo)).toList();
    final pastEntries = entries.where((e) => e.createdAt.isAfter(fourteenDaysAgo) && e.createdAt.isBefore(sevenDaysAgo)).toList();

    if (recentEntries.isEmpty || pastEntries.isEmpty) {
      return {'moodDiff': null, 'anxietyDiff': null, 'sleepDiff': null};
    }

    final recentAvg = calculateAverages(recentEntries);
    final pastAvg = calculateAverages(pastEntries);

    double percentDiff(double recent, double past) {
      if (past == 0) return 0;
      return ((recent - past) / past) * 100.0;
    }

    return {
      'moodDiff': percentDiff(recentAvg['mood']!, pastAvg['mood']!),
      'anxietyDiff': percentDiff(recentAvg['anxiety']!, pastAvg['anxiety']!),
      'sleepDiff': percentDiff(recentAvg['sleep']!, pastAvg['sleep']!),
    };
  }

  /// Identifica observações/correlações estatísticas sem fazer diagnóstico
  List<String> generateClinicalObservations(
    List<MoodEntry> entries, {
    int? completedTasks,
    int? totalTasks,
  }) {
    if (entries.isEmpty) return ['Nenhum registro suficiente no período selecionado.'];

    final observations = <String>[];

    // 1. Correlação Sono x Ansiedade
    final goodSleepDays = entries.where((e) => e.sleepQuality >= 7).toList();
    final poorSleepDays = entries.where((e) => e.sleepQuality <= 4).toList();

    if (goodSleepDays.isNotEmpty && poorSleepDays.isNotEmpty) {
      final avgAnxietyGoodSleep = goodSleepDays.map((e) => e.anxiety).reduce((a, b) => a + b) / goodSleepDays.length;
      final avgAnxietyPoorSleep = poorSleepDays.map((e) => e.anxiety).reduce((a, b) => a + b) / poorSleepDays.length;

      if (avgAnxietyGoodSleep < avgAnxietyPoorSleep) {
        final diff = ((avgAnxietyPoorSleep - avgAnxietyGoodSleep) / avgAnxietyPoorSleep * 100).round();
        observations.add(
          'Nos dias com boa qualidade de sono (≥ 7), a ansiedade média foi $diff% menor do que nos dias de sono ruim.',
        );
      }
    }

    // 2. Picos de ansiedade / estresse
    final highAnxietyDays = entries.where((e) => e.anxiety >= 8).toList();
    if (highAnxietyDays.isNotEmpty) {
      observations.add(
        'Foram registrados ${highAnxietyDays.length} picos de ansiedade elevada (nível ≥ 8) no período.',
      );
    }

    // 3. Fatores mais frequentes
    final factorCount = <String, int>{};
    for (final e in entries) {
      for (final f in e.factors) {
        factorCount[f] = (factorCount[f] ?? 0) + 1;
      }
    }
    if (factorCount.isNotEmpty) {
      final sorted = factorCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topFactors = sorted.take(3).map((e) => '${e.key} (${e.value}x)').join(', ');
      observations.add('Fatores com maior frequência de influência informada: $topFactors.');
    }

    // 4. Correlação com tarefas se houver dados
    if (completedTasks != null && totalTasks != null && totalTasks > 0) {
      final rate = (completedTasks / totalTasks * 100).toStringAsFixed(1);
      observations.add('Adesão às tarefas terapêuticas no período: $rate% ($completedTasks de $totalTasks concluídas).');
    }

    if (observations.isEmpty) {
      observations.add('Padrões de humor e sono mantiveram-se estáveis no período avaliado.');
    }

    return observations;
  }
}