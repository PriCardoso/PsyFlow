import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── JourneyService ───────────────────────────────────────────────────────────

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

// ─── ProgressService ──────────────────────────────────────────────────────────

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerProgress({
    required String patientId,
    required String interventionCode,
    required int completionScore,
    required int moodBefore,
    required int moodAfter,
    String? feedback,
    String? taskId,
  }) async {
    await _db.collection('patient_intervention_progress').add({
      'patient_id': patientId,
      'task_id': taskId,
      'intervention_code': interventionCode,
      'completion_score': completionScore,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'patient_feedback': feedback,
      'completed_at': FieldValue.serverTimestamp(),
    });
  }
}

// ─── EmotionalLogService ──────────────────────────────────────────────────────

class EmotionalLogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveLog({
    required String patientId,
    required int mood,
    required int anxiety,
    required int energy,
    String? notes,
  }) async {
    await _db.collection('emotional_logs').add({
      'patient_id': patientId,
      'mood_score': mood,
      'anxiety_score': anxiety,
      'energy_score': energy,
      'notes': notes,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getLogs(String patientId) async {
    final snap = await _db
        .collection('emotional_logs')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at')
        .get();

    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}

// ─── InterventionService ──────────────────────────────────────────────────────

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

// ─── RecommendationService ────────────────────────────────────────────────────

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
      String patientId) async {
    final snap = await _db
        .collection('ai_recommendations')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}

// ─── PasswordResetService ─────────────────────────────────────────────────────
//
// ATENÇÃO: No Firebase o reset de senha oficial é via sendPasswordResetEmail().
// Este service mantém o fluxo customizado (código de 6 dígitos por e-mail)
// igual ao que existia no Supabase, mas o envio do e-mail precisa ser feito
// por uma Cloud Function ou serviço externo (ex: SendGrid, Resend).

class PasswordResetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Opção nativa do Firebase — mais simples, sem código customizado:
  Future<void> sendNativeResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Fluxo customizado (mantém código de 6 dígitos):
  Future<String> createCode(String email) async {
    final rnd = Random();
    final code = (100000 + rnd.nextInt(900000)).toString();

    await _db.collection('password_reset_codes').add({
      'email': email,
      'code': code,
      'used': false,
      'expires_at': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 15)),
      ),
      'created_at': FieldValue.serverTimestamp(),
    });

    return code;
  }

  Future<bool> validateCode({
    required String email,
    required String code,
  }) async {
    final snap = await _db
        .collection('password_reset_codes')
        .where('email', isEqualTo: email)
        .where('code', isEqualTo: code)
        .where('used', isEqualTo: false)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return false;

    final expires =
        (snap.docs.first.data()['expires_at'] as Timestamp).toDate();
    return expires.isAfter(DateTime.now());
  }

  Future<void> markAsUsed(String email, String code) async {
    final snap = await _db
        .collection('password_reset_codes')
        .where('email', isEqualTo: email)
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.update({'used': true});
    }
  }
}
