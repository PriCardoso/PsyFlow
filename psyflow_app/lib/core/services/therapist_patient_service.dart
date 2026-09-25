import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';
import '../../models/patient_link_model.dart';

/// Serviço canônico de vínculo psicólogo ↔ paciente.
///
/// Regras de negócio:
/// - Um paciente pode ter N profissionais (N:N).
/// - Um profissional pode ter N pacientes.
/// - Somente um vínculo ATIVO por par (psicólogo, paciente) é permitido.
/// - O código de convite expira em 7 dias; status muda para "expired".
/// - Coleção canônica: `therapist_patient_links`.
/// - As coleções legadas `links` e `invites` são read-only após migração.
class TherapistPatientService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static const String _col = 'therapist_patient_links';

  TherapistPatientService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Gera código numérico de 6 dígitos (ex: 842716)
  String _generateCode() {
    final rnd = Random.secure();
    return (100000 + rnd.nextInt(900000)).toString();
  }

  String _inviteLinkId(String psychologistId, String code) =>
      '${psychologistId}_$code';

  String _activeLinkId(String psychologistId, String patientId) =>
      '${psychologistId}_$patientId';

  User get _currentUser {
    final u = _auth.currentUser;
    if (u == null) throw AppException('Usuário não autenticado.');
    return u;
  }

  Future<PatientProfile?> _fetchPatientProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return PatientProfile.fromMap({'id': doc.id, ...doc.data()!});
    } catch (_) {
      return null;
    }
  }

  Future<TherapistProfile?> _fetchTherapistProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return TherapistProfile.fromMap({'id': doc.id, ...doc.data()!});
    } catch (_) {
      return null;
    }
  }

  Future<({double? avgMood, double? avgAnxiety})> _fetchMoodMetrics(String patientId) async {
    try {
      final snap = await _db
          .collection('mood_entries')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();

      if (snap.docs.isEmpty) return (avgMood: null, avgAnxiety: null);

      double sumMood = 0;
      double sumAnxiety = 0;
      for (final m in snap.docs) {
        final d = m.data();
        sumMood += (d['mood'] as num?)?.toDouble() ?? 5.0;
        sumAnxiety += (d['anxiety'] as num?)?.toDouble() ?? 4.0;
      }
      return (
        avgMood: sumMood / snap.docs.length,
        avgAnxiety: sumAnxiety / snap.docs.length,
      );
    } catch (_) {
      return (avgMood: null, avgAnxiety: null);
    }
  }

  Future<({int completed, int total})> _fetchTaskMetrics(
    String patientId,
    String psychologistId,
  ) async {
    try {
      final snap = await _db
          .collection('tasks')
          .where('patient_id', isEqualTo: patientId)
          .where('psychologist_id', isEqualTo: psychologistId)
          .get();

      final total = snap.docs.length;
      final completed =
          snap.docs.where((t) => t.data()['status'] == 'completed').length;
      return (completed: completed, total: total);
    } catch (_) {
      return (completed: 0, total: 0);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Psicólogo gera código de convite
  // ──────────────────────────────────────────────────────────────────────────

  Future<String> generateInviteCode() async {
    final user = _currentUser;

    // Buscar nome do profissional para desnormalizar
    String? therapistName;
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        therapistName = (d['full_name'] ?? d['fullName'] ?? d['name']) as String?;
      }
    } catch (_) {}

    final code = _generateCode();
    final now = DateTime.now();

    try {
      await _db.collection(_col).doc(_inviteLinkId(user.uid, code)).set({
        'psychologistId': user.uid,
        'patientId': null,
        'inviteCode': code,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 7))),
        'acceptedAt': null,
        'patientName': null,
        'therapistName': therapistName,
      });

      return code;
    } catch (e) {
      throw AppException('Erro ao gerar código de vínculo: $e', originalError: e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Paciente aceita o código de 6 dígitos
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> acceptInviteCode(String code) async {
    final patient = _currentUser;
    final cleanCode = code.trim();

    if (cleanCode.length != 6) {
      throw AppException('O código de vínculo deve conter exatamente 6 dígitos.');
    }

    try {
      // Buscar o convite pendente
      final snap = await _db
          .collection(_col)
          .where('inviteCode', isEqualTo: cleanCode)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        throw AppException('Código inválido ou já utilizado.');
      }

      final doc = snap.docs.first;
      final data = doc.data();

      // Validar expiração
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        await doc.reference.update({'status': 'expired'});
        throw AppException(
            'Este código expirou. Solicite um novo código ao seu profissional.');
      }

      // Evitar auto-vínculo
      final psychologistId = data['psychologistId'] as String;
      if (psychologistId == patient.uid) {
        throw AppException('Você não pode utilizar seu próprio código de profissional.');
      }

      final activeLink = _db
          .collection(_col)
          .doc(_activeLinkId(psychologistId, patient.uid));

      final duplicateSnap = await _db
          .collection(_col)
          .where('psychologistId', isEqualTo: psychologistId)
          .where('patientId', isEqualTo: patient.uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (duplicateSnap.docs.isNotEmpty) {
        throw AppException('Você já está vinculado a este profissional.');
      }

      // Buscar nome do paciente para desnormalizar
      String? patientName;
      try {
        final userDoc = await _db.collection('users').doc(patient.uid).get();
        if (userDoc.exists) {
          final d = userDoc.data()!;
          patientName = (d['full_name'] ?? d['fullName'] ?? d['name']) as String?;
        }
      } catch (_) {}

      // O ID determinístico impede duplicatas e permite que as Security Rules
      // validem o vínculo entre um profissional e um paciente específico.
      await _db.runTransaction((transaction) async {
        transaction.set(activeLink, {
          ...data,
          'patientId': patient.uid,
          'status': 'active',
          'acceptedAt': FieldValue.serverTimestamp(),
          'patientName': patientName,
        });
        transaction.update(doc.reference, {'status': 'accepted'});
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Erro ao ativar vínculo: $e', originalError: e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Psicólogo — lista pacientes vinculados (one-shot com métricas)
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<TherapistPatientLink>> getMyPatients() async {
    final user = _currentUser;
    try {
      final snap = await _db
          .collection(_col)
          .where('psychologistId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'active')
          .get();

      return await _enrichLinks(snap.docs, forPsychologist: true);
    } catch (e) {
      throw AppException('Erro ao carregar pacientes vinculados: $e', originalError: e);
    }
  }

  /// Stream em tempo real dos pacientes do profissional
  Stream<List<TherapistPatientLink>> watchMyPatients() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection(_col)
        .where('psychologistId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snap) => _enrichLinks(snap.docs, forPsychologist: true));
  }

  /// Retorna lista simples de vínculos ativos (usado para contagem no dashboard)
  Future<List<TherapistPatientLink>> getMyPatientsLinks() async {
    final user = _currentUser;
    try {
      final snap = await _db
          .collection(_col)
          .where('psychologistId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'active')
          .get();

      return snap.docs
          .map((doc) => TherapistPatientLink.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar vínculos: $e', originalError: e);
    }
  }

  /// Verifica o vínculo ativo canônico entre um profissional e um paciente.
  Future<bool> isLinked(String psychologistId, String patientId) async {
    try {
      final link = await _db
          .collection(_col)
          .doc(_activeLinkId(psychologistId, patientId))
          .get();
      return link.exists && link.data()?['status'] == 'active';
    } catch (_) {
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Paciente — lista profissionais vinculados (N:N)
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<TherapistPatientLink>> getMyTherapists() async {
    final user = _currentUser;
    try {
      final snap = await _db
          .collection(_col)
          .where('patientId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'active')
          .get();

      return await _enrichLinks(snap.docs, forPsychologist: false);
    } catch (e) {
      throw AppException('Erro ao buscar profissionais vinculados: $e', originalError: e);
    }
  }

  /// Stream em tempo real dos profissionais do paciente
  Stream<List<TherapistPatientLink>> watchMyTherapists() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection(_col)
        .where('patientId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snap) => _enrichLinks(snap.docs, forPsychologist: false));
  }

  /// Retrocompatibilidade: retorna o primeiro profissional vinculado (para partes
  /// do app que assumem 1 psicólogo por paciente).
  Future<Map<String, dynamic>?> getMyTherapistLink() async {
    final therapists = await getMyTherapists();
    if (therapists.isEmpty) return null;
    final link = therapists.first;
    return {
      'linkId': link.id,
      'status': link.status.name,
      'acceptedAt': link.acceptedAt,
      'psychologistId': link.psychologistId,
      'psychologist': link.therapistProfile != null
          ? {
              'id': link.therapistProfile!.id,
              'full_name': link.therapistProfile!.fullName,
              'email': link.therapistProfile!.email,
              'specialty': link.therapistProfile!.specialty,
              'professional_registration': link.therapistProfile!.professionalRegistration,
              'photo_url': link.therapistProfile!.photoUrl,
            }
          : null,
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Verificação de vínculo ativo entre dois usuários
  // ──────────────────────────────────────────────────────────────────────────

  /// Busca o linkId do vínculo ativo entre dois usuários (null se não existir)
  Future<String?> getActiveLinkId(String psychologistId, String patientId) async {
    try {
      final snap = await _db
          .collection(_col)
          .where('psychologistId', isEqualTo: psychologistId)
          .where('patientId', isEqualTo: patientId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      return snap.docs.isNotEmpty ? snap.docs.first.id : null;
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 6. Convites pendentes do profissional
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<TherapistPatientLink>> getMyPendingInvites() async {
    final user = _currentUser;
    try {
      final snap = await _db
          .collection(_col)
          .where('psychologistId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs
          .map((doc) => TherapistPatientLink.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw AppException('Erro ao carregar convites pendentes: $e', originalError: e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 7. Ativar / Desativar vínculo
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> deactivateLink(String linkId) async {
    try {
      await _db.collection(_col).doc(linkId).update({'status': 'inactive'});
    } catch (e) {
      throw AppException('Erro ao desativar vínculo: $e', originalError: e);
    }
  }

  Future<void> reactivateLink(String linkId) async {
    try {
      await _db.collection(_col).doc(linkId).update({'status': 'active'});
    } catch (e) {
      throw AppException('Erro ao reativar vínculo: $e', originalError: e);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helper interno: enriquece links com perfis e métricas
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<TherapistPatientLink>> _enrichLinks(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    required bool forPsychologist,
  }) async {
    final links = <TherapistPatientLink>[];

    for (final doc in docs) {
      final data = doc.data();
      final patientId = data['patientId'] as String?;
      final psychologistId = data['psychologistId'] as String?;

      PatientProfile? patientProfile;
      TherapistProfile? therapistProfile;
      double? avgMood;
      double? avgAnxiety;
      int completedTasks = 0;
      int totalTasks = 0;

      if (forPsychologist && patientId != null) {
        // Psicólogo quer ver dados do paciente
        patientProfile = await _fetchPatientProfile(patientId);
        final mood = await _fetchMoodMetrics(patientId);
        avgMood = mood.avgMood;
        avgAnxiety = mood.avgAnxiety;
        final tasks = await _fetchTaskMetrics(
            patientId, psychologistId ?? _auth.currentUser!.uid);
        completedTasks = tasks.completed;
        totalTasks = tasks.total;
      } else if (!forPsychologist && psychologistId != null) {
        // Paciente quer ver dados do profissional
        therapistProfile = await _fetchTherapistProfile(psychologistId);
      }

      links.add(TherapistPatientLink.fromMap(
        data,
        doc.id,
        patientProfile: patientProfile,
        therapistProfile: therapistProfile,
        avgMood: avgMood,
        avgAnxiety: avgAnxiety,
        completedTasks: completedTasks,
        totalTasks: totalTasks,
      ));
    }

    return links;
  }
}
