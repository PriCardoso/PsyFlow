class AvailabilitySlot {
  final String id;
  final String psychologistId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String modality;
  final bool isActive;
  final bool isBooked;

  AvailabilitySlot({
    required this.id,
    required this.psychologistId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.modality,
    required this.isActive,
    required this.isBooked,
  });
 
  factory AvailabilitySlot.fromMap(Map<String, dynamic> map) {
    return AvailabilitySlot(
      id: map['id'],
      psychologistId: map['psychologist_id'],
      date: DateTime.parse(map['date']),
      startTime: DateTime.parse("${map['date']} ${map['start_time']}"),
      endTime: DateTime.parse("${map['date']} ${map['end_time']}"),
      modality: map['modality'],
      isActive: map['is_active'],
      isBooked: map['is_booked'] ?? false,
    );
  }
}
