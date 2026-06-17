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
    return MoodEntry(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      mood: map['mood'] as int,
      anxiety: map['anxiety'] as int,
      energy: map['energy'] as int,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static const moodEmojis = ['😢', '😕', '😐', '🙂', '😄'];
  static const moodLabels = ['Muito mal', 'Mal', 'Neutro', 'Bem', 'Muito bem'];

  String get moodEmoji => moodEmojis[mood - 1];
  String get moodLabel => moodLabels[mood - 1];
}
