import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';
import '../../models/patient_link_model.dart';

class TherapistPatientLink {
  final String id;
  final String psychologistId;
  final String? patientId;
  final String inviteCode;
  final String status; // 'pending', 'active', 'inactive', 'expired'
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final PatientProfile? patientProfile;

  // Métricas rápidas para o card do paciente no dashboard
  final double? avgMood;
  final double? avgAnxiety;
  final int completedTasks;
  final int totalTasks;

  const TherapistPatientLink({
    required this.id,
    required this.psychologistId,
    this.patientId,
    required this.inviteCode,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.patientProfile,
    this.avgMood,
    this.avgAnxiety,
    this.completedTasks = 0,
    this.totalTasks = 0,
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';

  factory TherapistPatientLink.fromMap(Map<String, dynamic> map, String id, {PatientProfile? profile, double? avgMood, double? avgAnxiety, int completedTasks = 0, int totalTasks = 0}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return TherapistPatientLink(
      id: id,
      psychologistId: (map['psychologistId'] ?? map['psychologist_id'] ?? '') as String,
      patientId: map['patientId'] as String? ?? map['patient_id'] as String?,
      inviteCode: (map['inviteCode'] ?? map['invite_code'] ?? '') as String,
      status: (map['status'] ?? 'pending') as String,
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      expiresAt: parseDate(map['expiresAt'] ?? map['expires_at']),
      acceptedAt: map['acceptedAt'] != null || map['accepted_at'] != null
          ? parseDate(map['acceptedAt'] ?? map['accepted_at'])
          : null,
      patientProfile: profile,
      avgMood: avgMood,
      avgAnxiety: avgAnxiety,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psychologistId': psychologistId,
      'patientId': patientId,
      'inviteCode': inviteCode,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }
}

class TherapistPatientService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  TherapistPatientService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  /// Gera código numérico de 6 dígitos (ex: 842716)
  String _generateNumeric6DigitCode() {
    final rnd = Random.secure();
    return (100000 + rnd.nextInt(900000)).toString();
  }

  /// 1. Psicólogo gera código de vínculo pré-consulta
  Future<String> generateInviteCode() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final code = _generateNumeric6DigitCode();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 7));

      await _db.collection('therapist_patient_links').add({
        'psychologistId': user.uid,
        'patientId': null,
        'inviteCode': code,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'acceptedAt': null,
      });

      return code;
    } catch (e) {
      throw AppException('Erro ao gerar código de vínculo: $e', originalError: e);
    }
  }

  /// 2. Paciente aceita o código de 6 dígitos
  Future<void> acceptInviteCode(String code) async {
    final patient = _auth.currentUser;
    if (patient == null) throw AppException('Usuário não autenticado.');

    final cleanCode = code.trim();
    if (cleanCode.length != 6) {
      throw AppException('O código de vínculo deve conter exatamente 6 dígitos.');
    }

    try {
      final snap = await _db
          .collection('therapist_patient_links')
          .where('inviteCode', isEqualTo: cleanCode)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        throw AppException('Código inválido ou já utilizado.');
      }

      final doc = snap.docs.first;
      final data = doc.data();

      // Validação de expiração
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        await doc.reference.update({'status': 'expired'});
        throw AppException('Este código expirou. Solicite um novo código ao seu psicólogo.');
      }

      // Evita vincular consigo mesmo
      if (data['psychologistId'] == patient.uid) {
        throw AppException('Você não pode utilizar seu próprio código de psicólogo.');
      }

      // Atualização atômica para ativo
      await doc.reference.update({
        'patientId': patient.uid,
        'status': 'active',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Erro ao ativar vínculo: $e', originalError: e);
    }
  }

  /// 3. Lista de pacientes vinculados do psicólogo (com métricas para o card)
  Future<List<TherapistPatientLink>> getMyPatientsLinks() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('therapist_patient_links')
          .where('psychologistId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'active')
          .get();

      final links = <TherapistPatientLink>[];

      for (final doc in snap.docs) {
        final data = doc.data();
        final patientId = data['patientId'] as String?;

        PatientProfile? profile;
        double? avgMood;
        double? avgAnxiety;
        int completedTasks = 0;
        int totalTasks = 0;

        if (patientId != null) {
          // Dados do usuário paciente
          final userDoc = await _db.collection('users').doc(patientId).get();
          if (userDoc.exists && userDoc.data() != null) {
            profile = PatientProfile.fromMap({'id': userDoc.id, ...userDoc.data()!});
          }

          // Métricas recentes de humor (últimos 7 registros)
          try {
            final moodSnap = await _db
                .collection('mood_entries')
                .where('patient_id', isEqualTo: patientId)
                .orderBy('created_at', descending: true)
                .limit(7)
                .get();

            if (moodSnap.docs.isNotEmpty) {
              double sumMood = 0;
              double sumAnxiety = 0;
              for (final m in moodSnap.docs) {
                final d = m.data();
                sumMood += (d['mood'] as num?)?.toDouble() ?? 5.0;
                sumAnxiety += (d['anxiety'] as num?)?.toDouble() ?? 4.0;
              }
              avgMood = sumMood / moodSnap.docs.length;
              avgAnxiety = sumAnxiety / moodSnap.docs.length;
            }
          } catch (_) {}

          // Métricas de tarefas
          try {
            final tasksSnap = await _db
                .collection('tasks')
                .where('patient_id', isEqualTo: patientId)
                .get();

            totalTasks = tasksSnap.docs.length;
            completedTasks = tasksSnap.docs
                .where((t) => t.data()['status'] == 'completed')
                .length;
          } catch (_) {}
        }

        links.add(
          TherapistPatientLink.fromMap(
            data,
            doc.id,
            profile: profile,
            avgMood: avgMood,
            avgAnxiety: avgAnxiety,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
          ),
        );
      }

      return links;
    } catch (e) {
      throw AppException('Erro ao carregar pacientes vinculados: $e', originalError: e);
    }
  }

  /// 4. Paciente busca seu psicólogo vinculado
  Future<Map<String, dynamic>?> getMyTherapistLink() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('therapist_patient_links')
          .where('patientId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;

      final doc = snap.docs.first;
      final data = doc.data();

      final psychDoc = await _db.collection('users').doc(data['psychologistId']).get();
      return {
        'linkId': doc.id,
        'status': data['status'],
        'acceptedAt': data['acceptedAt'],
        'psychologistId': data['psychologistId'],
        'psychologist': psychDoc.exists ? {'id': psychDoc.id, ...psychDoc.data()!} : null,
      };
    } catch (e) {
      throw AppException('Erro ao buscar psicólogo vinculado: $e', originalError: e);
    }
  }

  /// Desativa vínculo
  Future<void> deactivateLink(String linkId) async {
    try {
      await _db.collection('therapist_patient_links').doc(linkId).update({'status': 'inactive'});
    } catch (e) {
      throw AppException('Erro ao desativar vínculo: $e', originalError: e);
    }
  }

  /// Reativa vínculo
  Future<void> reactivateLink(String linkId) async {
    try {
      await _db.collection('therapist_patient_links').doc(linkId).update({'status': 'active'});
    } catch (e) {
      throw AppException('Erro ao reativar vínculo: $e', originalError: e);
    }
  }
}
