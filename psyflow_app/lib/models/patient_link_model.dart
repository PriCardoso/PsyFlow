import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PatientProfile — snapshot desnormalizado do paciente
// ─────────────────────────────────────────────────────────────────────────────

class PatientProfile {
  final String id;
  final String fullName;
  final String email;
  final String? bio;
  final String? phone;
  final String? photoUrl;

  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.bio,
    this.phone,
    this.photoUrl,
  });

  factory PatientProfile.fromMap(Map<String, dynamic> map) {
    final name = (map['full_name'] ?? map['fullName'] ?? map['name'] ?? 'Paciente') as String;
    return PatientProfile(
      id: map['id'] as String? ?? '',
      fullName: name.isNotEmpty ? name : 'Paciente',
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
      photoUrl: (map['photo_url'] ?? map['photoUrl']) as String?,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'P';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TherapistProfile — snapshot desnormalizado do profissional
// ─────────────────────────────────────────────────────────────────────────────

class TherapistProfile {
  final String id;
  final String fullName;
  final String email;
  final String? specialty;
  final String? professionalRegistration;
  final String? photoUrl;
  final String? phone;
  final String? bio;

  const TherapistProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.specialty,
    this.professionalRegistration,
    this.photoUrl,
    this.phone,
    this.bio,
  });

  factory TherapistProfile.fromMap(Map<String, dynamic> map) {
    final name = (map['full_name'] ?? map['fullName'] ?? map['name'] ?? 'Profissional') as String;
    return TherapistProfile(
      id: map['id'] as String? ?? '',
      fullName: name.isNotEmpty ? name : 'Profissional',
      email: map['email'] as String? ?? '',
      specialty: map['specialty'] as String?,
      professionalRegistration: (map['professional_registration'] ??
          map['professionalRegistration'] ??
          map['crp']) as String?,
      photoUrl: (map['photo_url'] ?? map['photoUrl']) as String?,
      phone: map['phone'] as String?,
      bio: map['bio'] as String?,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'T';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TherapistPatientLink — documento canônico de vínculo
// ─────────────────────────────────────────────────────────────────────────────

enum LinkStatus { pending, active, inactive, expired }

class TherapistPatientLink {
  final String id;
  final String psychologistId;
  final String? patientId;
  final String inviteCode;
  final LinkStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;

  /// Nome desnormalizado do paciente (snapshot no momento do aceite)
  final String? patientName;

  /// Nome desnormalizado do profissional (snapshot na criação do convite)
  final String? therapistName;

  /// Perfil completo do paciente — carregado pelo serviço quando necessário
  final PatientProfile? patientProfile;

  /// Perfil completo do profissional — carregado pelo serviço quando necessário
  final TherapistProfile? therapistProfile;

  /// Métricas rápidas para o card do paciente no dashboard
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
    this.patientName,
    this.therapistName,
    this.patientProfile,
    this.therapistProfile,
    this.avgMood,
    this.avgAnxiety,
    this.completedTasks = 0,
    this.totalTasks = 0,
  });

  bool get isActive => status == LinkStatus.active;
  bool get isPending => status == LinkStatus.pending;
  bool get isExpired => status == LinkStatus.expired;

  String get displayPatientName =>
      patientProfile?.fullName ?? patientName ?? 'Paciente';
  String get displayTherapistName =>
      therapistProfile?.fullName ?? therapistName ?? 'Profissional';

  static LinkStatus _parseStatus(String? s) {
    switch (s) {
      case 'active':
        return LinkStatus.active;
      case 'inactive':
        return LinkStatus.inactive;
      case 'expired':
        return LinkStatus.expired;
      default:
        return LinkStatus.pending;
    }
  }

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  factory TherapistPatientLink.fromMap(
    Map<String, dynamic> map,
    String id, {
    PatientProfile? patientProfile,
    TherapistProfile? therapistProfile,
    double? avgMood,
    double? avgAnxiety,
    int completedTasks = 0,
    int totalTasks = 0,
  }) {
    return TherapistPatientLink(
      id: id,
      psychologistId: (map['psychologistId'] ?? map['psychologist_id'] ?? '') as String,
      patientId: map['patientId'] as String? ?? map['patient_id'] as String?,
      inviteCode: (map['inviteCode'] ?? map['invite_code'] ?? '') as String,
      status: _parseStatus(map['status'] as String?),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      expiresAt: _parseDate(map['expiresAt'] ?? map['expires_at']),
      acceptedAt: map['acceptedAt'] != null || map['accepted_at'] != null
          ? _parseDate(map['acceptedAt'] ?? map['accepted_at'])
          : null,
      patientName: map['patientName'] as String?,
      therapistName: map['therapistName'] as String?,
      patientProfile: patientProfile,
      therapistProfile: therapistProfile,
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
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'patientName': patientName,
      'therapistName': therapistName,
    };
  }
}

// Mantido para retrocompatibilidade (usado em InviteService legado)
class PatientLink {
  final String linkId;
  final bool active;
  final DateTime createdAt;
  final PatientProfile patient;

  const PatientLink({
    required this.linkId,
    required this.active,
    required this.createdAt,
    required this.patient,
  });

  factory PatientLink.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PatientLink(
      linkId: map['id'] as String? ?? '',
      active: map['active'] as bool? ?? true,
      createdAt: parseDate(map['created_at']),
      patient: map['patient'] != null
          ? PatientProfile.fromMap(map['patient'] as Map<String, dynamic>)
          : PatientProfile(
              id: map['patient_id'] as String? ?? '',
              fullName: 'Paciente',
              email: '',
            ),
    );
  }
}
