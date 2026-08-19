class PsychologistSummary {
  final String id;
  final String fullName;
  final String modality;
  final String? crp;
  final String? bio;

  PsychologistSummary({
    required this.id,
    required this.fullName,
    required this.modality,
    this.crp,
    this.bio,
  });

  factory PsychologistSummary.fromMap(Map<String, dynamic> map) {
    return PsychologistSummary(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      modality: map['modality'] as String? ?? 'both',
      crp: map['crp'] as String?,
      bio: map['bio'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'modality': modality,
      'crp': crp,
      'bio': bio,
    };
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}