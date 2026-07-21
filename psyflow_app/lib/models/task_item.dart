import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  final String id;
  final String patientId;
  final String psychologistId;
  final String title;
  final String? description;
  final String category;
  final String protocol;
  final int difficultyLevel;
  final String status;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final String? patientResponse;
  final String? therapistNotes;
  final int? moodBefore;
  final int? moodAfter;
  final String? patientName;

  TaskItem({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    required this.title,
    this.description,
    required this.category,
    required this.protocol,
    required this.difficultyLevel,
    required this.status,
    this.dueDate,
    this.createdAt,
    this.completedAt,
    this.patientResponse,
    this.therapistNotes,
    this.moodBefore,
    this.moodAfter,
    this.patientName,
  });

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      psychologistId: map['psychologist_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String? ?? 'geral',
      protocol: map['protocol'] as String? ?? '',
      difficultyLevel: map['difficulty_level'] as int? ?? 1,
      status: map['status'] as String? ?? 'pending',
      dueDate: map['due_date'] != null 
          ? (map['due_date'] as Timestamp).toDate() 
          : null,
      createdAt: map['created_at'] != null 
          ? (map['created_at'] as Timestamp).toDate() 
          : null,
      completedAt: map['completed_at'] != null 
          ? (map['completed_at'] as Timestamp).toDate() 
          : null,
      patientResponse: map['patient_response'] as String?,
      therapistNotes: map['therapist_notes'] as String?,
      moodBefore: map['mood_before'] as int?,
      moodAfter: map['mood_after'] as int?,
      patientName: map['patient_name'] as String?,
    );
  }

  bool get isCompleted => status == 'completed';

  bool get isOverdue {
    if (dueDate == null) return false;
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}