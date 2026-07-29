import 'package:cloud_firestore/cloud_firestore.dart';

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
    String dateStr = map['date'] ?? DateTime.now().toIso8601String().split('T')[0];
    String startStr = map['start_time'] ?? '09:00';
    String endStr = map['end_time'] ?? '10:00';

    DateTime parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
    DateTime parsedStart = DateTime.tryParse("${dateStr}T$startStr") ?? parsedDate;
    DateTime parsedEnd = DateTime.tryParse("${dateStr}T$endStr") ?? parsedDate.add(const Duration(hours: 1));

    return AvailabilitySlot(
      id: map['id'] ?? '',
      psychologistId: map['psychologist_id'] ?? '',
      date: parsedDate,
      startTime: parsedStart,
      endTime: parsedEnd,
      modality: map['modality'] ?? 'online',
      isActive: map['is_active'] ?? true,
      isBooked: map['is_booked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psychologist_id': psychologistId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime.toIso8601String().split('T')[1].substring(0, 5),
      'end_time': endTime.toIso8601String().split('T')[1].substring(0, 5),
      'modality': modality,
      'is_active': isActive,
      'is_booked': isBooked,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
