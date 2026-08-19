import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentItem {
  final String id;
  final String patientId;
  final String psychologistId;
  final String? psychologistName;
  final String? psychologistCrp;
  final String? patientName;
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
    this.psychologistName,
    this.psychologistCrp,
    this.patientName,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.modality,
    required this.status,
    this.notes,
  });

  bool get isUpcoming => scheduledDate.isAfter(DateTime.now().subtract(const Duration(hours: 1)));

  String get otherPartyName {
    if (psychologistName != null && psychologistName!.trim().isNotEmpty) {
      return psychologistName!;
    }
    if (patientName != null && patientName!.trim().isNotEmpty) {
      return patientName!;
    }
    return 'Dr(a). Psicólogo(a)';
  }

  AppointmentItem copyWith({
    String? id,
    String? patientId,
    String? psychologistId,
    String? psychologistName,
    String? psychologistCrp,
    String? patientName,
    DateTime? scheduledDate,
    DateTime? startTime,
    DateTime? endTime,
    String? modality,
    String? status,
    String? notes,
  }) {
    return AppointmentItem(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      psychologistId: psychologistId ?? this.psychologistId,
      psychologistName: psychologistName ?? this.psychologistName,
      psychologistCrp: psychologistCrp ?? this.psychologistCrp,
      patientName: patientName ?? this.patientName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      modality: modality ?? this.modality,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  factory AppointmentItem.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final sDate = parseDate(map['scheduled_date']);
    DateTime sTime;
    if (map['start_time'] != null && map['scheduled_date'] is String) {
      sTime = DateTime.tryParse("${map['scheduled_date']} ${map['start_time']}") ?? sDate;
    } else {
      sTime = parseDate(map['start_time'] ?? map['scheduled_date']);
    }

    DateTime eTime;
    if (map['end_time'] != null && map['scheduled_date'] is String) {
      eTime = DateTime.tryParse("${map['scheduled_date']} ${map['end_time']}") ?? sTime.add(const Duration(minutes: 50));
    } else {
      eTime = parseDate(map['end_time'] ?? map['scheduled_date']);
    }

    return AppointmentItem(
      id: map['id']?.toString() ?? '',
      patientId: map['patient_id']?.toString() ?? '',
      psychologistId: map['psychologist_id']?.toString() ?? '',
      psychologistName: map['psychologist_name'] as String?,
      psychologistCrp: map['psychologist_crp'] as String?,
      patientName: map['patient_name'] as String?,
      scheduledDate: sDate,
      startTime: sTime,
      endTime: eTime,
      modality: map['modality']?.toString() ?? 'online',
      status: map['status']?.toString() ?? 'scheduled',
      notes: map['notes']?.toString(),
    );
  }
}
