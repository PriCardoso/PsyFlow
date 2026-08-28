import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  final String id;
  final String taskId;
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
  final int order;

  TaskItem({
    required this.id,
    required this.taskId,
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
    this.order = 0,
  });

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return TaskItem(
      id: (map['id'] ?? '') as String,
      taskId: (map['task_id'] ?? '') as String,
      patientId: (map['patient_id'] ?? '') as String,
      psychologistId: (map['psychologist_id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: map['description'] as String?,
      category: map['category'] as String? ?? 'geral',
      protocol: map['protocol'] as String? ?? '',
      difficultyLevel: (map['difficulty_level'] as num?)?.toInt() ?? 1,
      status: map['status'] as String? ?? 'pending',
      dueDate: parseNullableDate(map['due_date']),
      createdAt: parseNullableDate(map['created_at']),
      completedAt: parseNullableDate(map['completed_at']),
      patientResponse: map['patient_response'] as String?,
      therapistNotes: map['therapist_notes'] as String?,
      moodBefore: (map['mood_before'] as num?)?.toInt(),
      moodAfter: (map['mood_after'] as num?)?.toInt(),
      patientName: map['patient_name'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  TaskItem copyWith({
    String? id,
    String? taskId,
    String? patientId,
    String? psychologistId,
    String? title,
    String? description,
    String? category,
    String? protocol,
    int? difficultyLevel,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    String? patientResponse,
    String? therapistNotes,
    int? moodBefore,
    int? moodAfter,
    String? patientName,
    int? order,
  }) {
    return TaskItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      patientId: patientId ?? this.patientId,
      psychologistId: psychologistId ?? this.psychologistId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      protocol: protocol ?? this.protocol,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      patientResponse: patientResponse ?? this.patientResponse,
      therapistNotes: therapistNotes ?? this.therapistNotes,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      patientName: patientName ?? this.patientName,
      order: order ?? this.order,
    );
  }

  bool get isCompleted => status == 'completed';

  bool get isOverdue {
    if (dueDate == null) return false;
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}