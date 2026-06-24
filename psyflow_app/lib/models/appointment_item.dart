
class AppointmentItem {
  final String id;
  final String patientId;
  final String psychologistId;
  final DateTime scheduledDate;
  final DateTime startTime;
  final DateTime endTime;
  final String modality;
  final String status;
  final String? notes;

  AppointmentItem({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.modality,
    required this.status,
    this.notes,
  });
 
  bool get isUpcoming => scheduledDate.isAfter(DateTime.now());

  String? get otherPartyName => psychologistId; // depois podemos mapear para nome real

  factory AppointmentItem.fromMap(Map<String, dynamic> map) {
    return AppointmentItem(
      id: map['id'],
      patientId: map['patient_id'],
      psychologistId: map['psychologist_id'],
      scheduledDate: DateTime.parse(map['scheduled_date']),
      startTime: DateTime.parse("${map['scheduled_date']} ${map['start_time']}"),
      endTime: DateTime.parse("${map['scheduled_date']} ${map['end_time']}"),
      modality: map['modality'],
      status: map['status'],
      notes: map['notes'],
    );
  }
}
