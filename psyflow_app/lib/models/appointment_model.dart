class PsychologistSummary {
  final String id;
  final String fullName;
  final String email;
  final String? crp;
  final String? bio;

  const PsychologistSummary({
    required this.id,
    required this.fullName,
    required this.email,
    this.crp,
    this.bio,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  factory PsychologistSummary.fromMap(Map<String, dynamic> map) {
    return PsychologistSummary(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? 'Psicólogo',
      email: map['email'] as String? ?? '',
      crp: map['crp'] as String?,
      bio: map['bio'] as String?,
    );
  }
}

class AvailabilitySlot {
  final String id;
  final String psychologistId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  const AvailabilitySlot({
    required this.id,
    required this.psychologistId,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory AvailabilitySlot.fromMap(Map<String, dynamic> map) {
    return AvailabilitySlot(
      id: map['id'] as String,
      psychologistId: map['psychologist_id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      isBooked: map['is_booked'] as bool? ?? false,
    );
  }
}

class AppointmentItem {
  final String id;
  final String psychologistId;
  final String patientId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // scheduled | cancelled | completed
  final String? notes;
  final String? otherPartyName; // nome do psicólogo (visão paciente) ou paciente (visão psicólogo)

  const AppointmentItem({
    required this.id,
    required this.psychologistId,
    required this.patientId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    this.otherPartyName,
  });

  bool get isUpcoming => status == 'scheduled' && startTime.isAfter(DateTime.now());
  bool get isPast => startTime.isBefore(DateTime.now());

  factory AppointmentItem.fromMap(Map<String, dynamic> map, {required bool isPsychologistView}) {
    String? otherPartyName;
    if (isPsychologistView) {
      final patient = map['patient'];
      if (patient is Map<String, dynamic>) otherPartyName = patient['full_name'] as String?;
    } else {
      final psychologist = map['psychologist'];
      if (psychologist is Map<String, dynamic>) otherPartyName = psychologist['full_name'] as String?;
    }

    return AppointmentItem(
      id: map['id'] as String,
      psychologistId: map['psychologist_id'] as String,
      patientId: map['patient_id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      status: map['status'] as String? ?? 'scheduled',
      notes: map['notes'] as String?,
      otherPartyName: otherPartyName,
    );
  }
}
