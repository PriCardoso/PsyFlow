import 'package:cloud_firestore/cloud_firestore.dart';

class InitialAssessmentModel {
  final String id;
  final String patientId;
  final String psychologistId;
  final String mainComplaint;
  final String symptomsDuration;
  final bool previousTherapy;
  final String? previousTherapyDetails;
  final bool usingMedication;
  final String? medicationDetails;
  final String mainGoal;
  final int distressLevel; // 1-10
  final DateTime createdAt;
  final bool isCompleted;

  const InitialAssessmentModel({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    required this.mainComplaint,
    required this.symptomsDuration,
    required this.previousTherapy,
    this.previousTherapyDetails,
    required this.usingMedication,
    this.medicationDetails,
    required this.mainGoal,
    this.distressLevel = 5,
    required this.createdAt,
    this.isCompleted = true,
  });

  factory InitialAssessmentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return InitialAssessmentModel(
      id: id,
      patientId: (map['patient_id'] ?? '') as String,
      psychologistId: (map['psychologist_id'] ?? '') as String,
      mainComplaint: (map['main_complaint'] ?? '') as String,
      symptomsDuration: (map['symptoms_duration'] ?? '') as String,
      previousTherapy: map['previous_therapy'] as bool? ?? false,
      previousTherapyDetails: map['previous_therapy_details'] as String?,
      usingMedication: map['using_medication'] as bool? ?? false,
      medicationDetails: map['medication_details'] as String?,
      mainGoal: (map['main_goal'] ?? '') as String,
      distressLevel: (map['distress_level'] as num?)?.toInt() ?? 5,
      createdAt: parseDate(map['created_at']),
      isCompleted: map['is_completed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'psychologist_id': psychologistId,
      'main_complaint': mainComplaint,
      'symptoms_duration': symptomsDuration,
      'previous_therapy': previousTherapy,
      'previous_therapy_details': previousTherapyDetails,
      'using_medication': usingMedication,
      'medication_details': medicationDetails,
      'main_goal': mainGoal,
      'distress_level': distressLevel,
      'created_at': Timestamp.fromDate(createdAt),
      'is_completed': isCompleted,
    };
  }
}
