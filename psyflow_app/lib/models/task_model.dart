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

  factory TaskModel.fromMap(
      String id,
      Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      patientId: map["patientId"],
      psychologistId: map["psychologistId"],
      title: map["title"],
      description: map["description"],
      category: map["category"],
      protocol: map["protocol"],
      difficulty: map["difficulty"],
      status: map["status"],
      createdAt:
          (map["createdAt"] as Timestamp).toDate(),
      completedAt: map["completedAt"] != null
          ? (map["completedAt"] as Timestamp).toDate()
          : null,
      dueDate: map["dueDate"] != null
          ? (map["dueDate"] as Timestamp).toDate()
          : null,
      response: map["response"],
      moodBefore: map["moodBefore"],
      moodAfter: map["moodAfter"],
      therapistNotes: map["therapistNotes"],
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