class AvailabilitySlot {
  final String id;
  final String psychologistId;
  final DateTime? date;
  final int? weekday; // 0=Dom, 1=Seg ... 6=Sáb
  final String startTime; // "HH:mm"
  final String endTime;
  final bool isRecurring;
  final String modality; // 'presencial', 'online', 'both'
  final bool isActive;
  final DateTime createdAt;

  // join com users
  final String? psychologistName;

  const AvailabilitySlot({
    required this.id,
    required this.psychologistId,
    this.date,
    this.weekday,
    required this.startTime,
    required this.endTime,
    required this.isRecurring,
    required this.modality,
    required this.isActive,
    required this.createdAt,
    this.psychologistName,
  });

  factory AvailabilitySlot.fromMap(Map<String, dynamic> map) {
    return AvailabilitySlot(
      id: map['id'],
      psychologistId: map['psychologist_id'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      weekday: map['weekday'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      isRecurring: map['is_recurring'] ?? false,
      modality: map['modality'] ?? 'both',
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      psychologistName: map['psychologist']?['full_name'],
    );
  }

  static const List<String> weekdayLabels = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  String get weekdayLabel =>
      weekday != null ? weekdayLabels[weekday!] : '';
}

class Appointment {
  final String id;
  final String patientId;
  final String psychologistId;
  final String? slotId;
  final DateTime scheduledDate;
  final String startTime;
  final String endTime;
  final String modality;
  final String status;
  final String? notes;
  final DateTime createdAt;

  // joins
  final String? patientName;
  final String? psychologistName;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    this.slotId,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.modality,
    required this.status,
    this.notes,
    required this.createdAt,
    this.patientName,
    this.psychologistName,
  });

  bool get isScheduled => status == 'scheduled';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patient_id'],
      psychologistId: map['psychologist_id'],
      slotId: map['slot_id'],
      scheduledDate: DateTime.parse(map['scheduled_date']),
      startTime: map['start_time'],
      endTime: map['end_time'],
      modality: map['modality'],
      status: map['status'] ?? 'scheduled',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      patientName: map['patient']?['full_name'],
      psychologistName: map['psychologist']?['full_name'],
    );
  }
}