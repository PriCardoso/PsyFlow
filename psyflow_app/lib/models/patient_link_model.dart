import 'package:cloud_firestore/cloud_firestore.dart';

class PatientProfile {
  final String id;
  final String fullName;
  final String email;
  final String? bio;
  final String? phone;

  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.bio,
    this.phone,
  });

  factory PatientProfile.fromMap(Map<String, dynamic> map) {
    return PatientProfile(
      id: map['id'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'Paciente',
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'P';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

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
          : PatientProfile(id: map['patient_id'] as String? ?? '', fullName: 'Paciente', email: ''),
    );
  }
}

