class AssessmentTemplate {
  final String id;
  final String title;
  final String description;
  final String frequency; // 'daily', 'weekly', 'custom'
  final String? reminderTime; // ex: '08:00'
  final bool trackMood;
  final bool trackAnxiety;
  final bool trackEnergy;
  final bool trackSleep;
  final bool trackStress;
  final bool allowNotes;
  final bool allowFactors;

  const AssessmentTemplate({
    required this.id,
    required this.title,
    required this.description,
    this.frequency = 'daily',
    this.reminderTime = '08:00',
    this.trackMood = true,
    this.trackAnxiety = true,
    this.trackEnergy = true,
    this.trackSleep = true,
    this.trackStress = true,
    this.allowNotes = true,
    this.allowFactors = true,
  });

  factory AssessmentTemplate.fromMap(Map<String, dynamic> map, String id) {
    return AssessmentTemplate(
      id: id,
      title: (map['title'] ?? 'Check-in Diário') as String,
      description: (map['description'] ?? 'Acompanhe como você está se sentindo.') as String,
      frequency: (map['frequency'] ?? 'daily') as String,
      reminderTime: map['reminder_time'] as String? ?? '08:00',
      trackMood: map['track_mood'] as bool? ?? true,
      trackAnxiety: map['track_anxiety'] as bool? ?? true,
      trackEnergy: map['track_energy'] as bool? ?? true,
      trackSleep: map['track_sleep'] as bool? ?? true,
      trackStress: map['track_stress'] as bool? ?? true,
      allowNotes: map['allow_notes'] as bool? ?? true,
      allowFactors: map['allow_factors'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'frequency': frequency,
      'reminder_time': reminderTime,
      'track_mood': trackMood,
      'track_anxiety': trackAnxiety,
      'track_energy': trackEnergy,
      'track_sleep': trackSleep,
      'track_stress': trackStress,
      'allow_notes': allowNotes,
      'allow_factors': allowFactors,
    };
  }

  static const defaultDaily = AssessmentTemplate(
    id: 'default_daily',
    title: 'Check-in Diário',
    description: 'Como você está hoje? Leva menos de 2 minutos para registrar.',
    frequency: 'daily',
    reminderTime: '08:00',
  );
}
