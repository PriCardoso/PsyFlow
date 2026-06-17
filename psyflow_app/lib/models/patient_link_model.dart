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
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? 'Paciente',
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
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
    return PatientLink(
      linkId: map['id'] as String,
      active: map['active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      patient: PatientProfile.fromMap(map['patient'] as Map<String, dynamic>),
    );
  }
}
