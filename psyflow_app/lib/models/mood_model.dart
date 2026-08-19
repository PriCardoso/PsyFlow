import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String patientId;
  final int mood; // 1-5
  final int anxiety; // 1-5
  final int energy; // 1-5
  final String? notes;
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.patientId,
    required this.mood,
    required this.anxiety,
    required this.energy,
    this.notes,
    required this.createdAt,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MoodEntry(
      id: (map['id'] ?? '') as String,
      patientId: (map['patient_id'] ?? '') as String,
      mood: (map['mood'] as num?)?.toInt() ?? 3,
      anxiety: (map['anxiety'] as num?)?.toInt() ?? 3,
      energy: (map['energy'] as num?)?.toInt() ?? 3,
      notes: map['notes'] as String?,
      createdAt: parseDate(map['created_at']),
    );
  }

  static const moodEmojis = ['😢', '😕', '😐', '🙂', '😄'];
  static const moodLabels = ['Muito mal', 'Mal', 'Neutro', 'Bem', 'Muito bem'];

  String get moodEmoji => (mood >= 1 && mood <= 5) ? moodEmojis[mood - 1] : '😐';
  String get moodLabel => (mood >= 1 && mood <= 5) ? moodLabels[mood - 1] : 'Neutro';
}

