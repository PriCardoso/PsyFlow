import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../../models/intervention_template.dart';
import '../../core/errors/app_exception.dart';

// ─── ProgressService ──────────────────────────────────────────────────────────

class ProgressService {
  final FirebaseFirestore _db;

  ProgressService({required FirebaseFirestore firestore}) : _db = firestore;

  Future<void> registerProgress({
    required String patientId,
    required String interventionCode,
    required int completionScore,
    required int moodBefore,
    required int moodAfter,
    String? feedback,
    String? taskId,
  }) async {
    try {
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
    } catch (e) {
      throw AppException('Erro ao registrar progresso: $e', originalError: e);
    }
  }
}

// ─── RecommendationService ────────────────────────────────────────────────────

class RecommendationService {
  final FirebaseFirestore _db;

  RecommendationService({required FirebaseFirestore firestore}) : _db = firestore;

  Future<void> saveRecommendation({
    required String patientId,
    required String recommendation,
    required String type,
    required String severity,
  }) async {
    try {
      await _db.collection('ai_recommendations').add({
        'patient_id': patientId,
        'recommendation': recommendation,
        'recommendation_type': type,
        'severity': severity,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException('Erro ao salvar recomendação: $e', originalError: e);
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendations(
      String patientId) async {
    try {
      final snap = await _db
          .collection('ai_recommendations')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw AppException('Erro ao buscar recomendações: $e', originalError: e);
    }
  }
}

// ─── PasswordResetService ─────────────────────────────────────────────────────
//
// ATENÇÃO: No Firebase o reset de senha oficial é via sendPasswordResetEmail().
// Este service mantém o fluxo customizado (código de 6 dígitos por e-mail)
// igual ao que existia no Supabase, mas o envio do e-mail precisa ser feito
// por uma Cloud Function ou serviço externo (ex: SendGrid, Resend).

class PasswordResetService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  PasswordResetService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  // Opção nativa do Firebase — mais simples, sem código customizado:
  Future<void> sendNativeResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AppException('Erro ao enviar e-mail de recuperação: $e', originalError: e);
    }
  }

  // Fluxo customizado (mantém código de 6 dígitos):
  Future<String> createCode(String email) async {
    try {
      final rnd = Random.secure();
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
    } catch (e) {
      throw AppException('Erro ao criar código: $e', originalError: e);
    }
  }

  Future<bool> validateCode({
    required String email,
    required String code,
  }) async {
    try {
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
    } catch (e) {
      throw AppException('Erro ao validar código: $e', originalError: e);
    }
  }

  Future<void> markAsUsed(String email, String code) async {
    try {
      final snap = await _db
          .collection('password_reset_codes')
          .where('email', isEqualTo: email)
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      for (final doc in snap.docs) {
        await doc.reference.update({'used': true});
      }
    } catch (e) {
      throw AppException('Erro ao marcar código como usado: $e', originalError: e);
    }
  }
}

// ─── ReportService ────────────────────────────────────────────────────────────

class ReportService {
  final FirebaseFirestore _db;

  ReportService({required FirebaseFirestore firestore}) : _db = firestore;

  Future<void> generateReport({
    required String patientId,
    required String professionalId,
    required String reportType,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection('reports').add({
        'patient_id': patientId,
        'professional_id': professionalId,
        'report_type': reportType,
        'data': data,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException('Erro ao gerar relatório: $e', originalError: e);
    }
  }

  Future<List<Map<String, dynamic>>> getReports({
    required String patientId,
  }) async {
    try {
      final snap = await _db
          .collection('reports')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw AppException('Erro ao buscar relatórios: $e', originalError: e);
    }
  }
}