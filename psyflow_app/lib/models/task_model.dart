import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;

  final String patientId;

  final String psychologistId;

  final String title;

  final String description;

  final String category;

  final String protocol;

  final int difficulty;

  final DateTime createdAt;

  final DateTime? dueDate;

  final DateTime? completedAt;

  final String status;

  final String? response;

  final int? moodBefore;

  final int? moodAfter;

  final String? therapistNotes;

  const TaskModel({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    required this.title,
    required this.description,
    required this.category,
    required this.protocol,
    required this.difficulty,
    required this.createdAt,
    required this.status,
    this.completedAt,
    this.dueDate,
    this.response,
    this.moodBefore,
    this.moodAfter,
    this.therapistNotes,
  });

  bool get completed => status == "completed";

  bool get overdue {
    if (dueDate == null) return false;
    if (completed) return false;

    return DateTime.now().isAfter(dueDate!);
  }

  TaskModel copyWith({
    String? id,
    String? patientId,
    String? psychologistId,
    String? title,
    String? description,
    String? category,
    String? protocol,
    int? difficulty,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    String? status,
    String? response,
    int? moodBefore,
    int? moodAfter,
    String? therapistNotes,
  }) {
    return TaskModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      psychologistId: psychologistId ?? this.psychologistId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      protocol: protocol ?? this.protocol,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      response: response ?? this.response,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      therapistNotes: therapistNotes ?? this.therapistNotes,
    );
  }

  factory TaskModel.fromMap(
      String id,
      Map<String, dynamic> map) {
    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return TaskModel(
      id: id,
      patientId: map["patientId"] ?? map["patient_id"] ?? "",
      psychologistId: map["psychologistId"] ?? map["psychologist_id"] ?? "",
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      category: map["category"] ?? "geral",
      protocol: map["protocol"] ?? "",
      difficulty: (map["difficulty"] as num?)?.toInt() ?? 1,
      status: map["status"] ?? "pending",
      createdAt: parseNullableDate(map["createdAt"] ?? map["created_at"]) ?? DateTime.now(),
      completedAt: parseNullableDate(map["completedAt"] ?? map["completed_at"]),
      dueDate: parseNullableDate(map["dueDate"] ?? map["due_date"]),
      response: map["response"] ?? map["patient_response"],
      moodBefore: (map["moodBefore"] ?? map["mood_before"] as num?)?.toInt(),
      moodAfter: (map["moodAfter"] ?? map["mood_after"] as num?)?.toInt(),
      therapistNotes: map["therapistNotes"] ?? map["therapist_notes"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "patientId": patientId,
      "psychologistId": psychologistId,
      "title": title,
      "description": description,
      "category": category,
      "protocol": protocol,
      "difficulty": difficulty,
      "createdAt": createdAt,
      "completedAt": completedAt,
      "dueDate": dueDate,
      "status": status,
      "response": response,
      "moodBefore": moodBefore,
      "moodAfter": moodAfter,
      "therapistNotes": therapistNotes,
    };
  }
}