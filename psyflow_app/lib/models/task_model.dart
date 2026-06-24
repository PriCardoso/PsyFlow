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

  final DateTime createdAt;
  final DateTime? completedAt;

  final DateTime? dueDate;

  final String? patientResponse;
  final String? therapistNotes;

  final int? moodBefore;
  final int? moodAfter;

  final String? patientName;

  const TaskItem({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    required this.title,
    this.description,
    required this.category,
    required this.protocol,
    required this.difficultyLevel,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.patientResponse,
    this.therapistNotes,
    this.moodBefore,
    this.moodAfter,
    this.patientName,
  });

  bool get isCompleted => status == 'completed';

  bool get isOverdue {
    if (isCompleted) return false;
    if (dueDate == null) return false;

    return dueDate!.isBefore(DateTime.now());
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    String? patientName;

    if (map['patient'] != null) {
      final users = map['patient']['users'];
      if (users != null) {
        patientName = users['full_name'];
      }
    }

  return TaskItem(
      id: map['id'],
      patientId: map['patient_id'],
      psychologistId: map['psychologist_id'],

      title: map['title'] ?? '',
      description: map['description'],

      category: map['category'] ?? 'geral',
      protocol: map['protocol'] ?? '',

      difficultyLevel: map['difficulty_level'] ?? 1,

      status: map['status'] ?? 'pending',

      createdAt: DateTime.parse(map['created_at']),

      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,

      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'])
          : null,

      patientResponse: map['patient_response'],
      therapistNotes: map['therapist_notes'],

      moodBefore: map['mood_before'],
      moodAfter: map['mood_after'],

      patientName: patientName,
    );
  }
}