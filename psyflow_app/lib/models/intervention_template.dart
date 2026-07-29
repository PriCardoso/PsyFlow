class InterventionTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final String protocol;
  final String specialty; // psicologia, terapia_ocupacional, psicopedagogia, fonoaudiologia, etc.
  final int phase;
  final int difficultyLevel;
  final int estimatedMinutes;
  final String goal;
  final String reflectionQuestion;
  final int successThreshold;
  final int failureThreshold;
  final String? nextSuccessCode;
  final String? nextFailureCode;
  final String interventionCode;
  final bool isActive;

  const InterventionTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.protocol,
    this.specialty = 'psicologia',
    required this.phase,
    required this.difficultyLevel,
    required this.estimatedMinutes,
    required this.goal,
    required this.reflectionQuestion,
    required this.successThreshold,
    required this.failureThreshold,
    required this.nextSuccessCode,
    required this.nextFailureCode,
    required this.interventionCode,
    required this.isActive,
  });

  factory InterventionTemplate.fromMap(Map<String, dynamic> map) {
    return InterventionTemplate(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      protocol: map['protocol'] ?? '',
      specialty: map['specialty'] ?? 'psicologia',
      phase: map['phase'] ?? 1,
      difficultyLevel: map['difficulty_level'] ?? 1,
      estimatedMinutes: map['estimated_minutes'] ?? 10,
      goal: map['goal'] ?? '',
      reflectionQuestion: map['reflection_question'] ?? '',
      successThreshold: map['success_threshold'] ?? 80,
      failureThreshold: map['failure_threshold'] ?? 40,
      nextSuccessCode: map['next_success_code'],
      nextFailureCode: map['next_failure_code'],
      interventionCode: map['intervention_code'] ?? '',
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'protocol': protocol,
      'specialty': specialty,
      'phase': phase,
      'difficulty_level': difficultyLevel,
      'estimated_minutes': estimatedMinutes,
      'goal': goal,
      'reflection_question': reflectionQuestion,
      'success_threshold': successThreshold,
      'failure_threshold': failureThreshold,
      'next_success_code': nextSuccessCode,
      'next_failure_code': nextFailureCode,
      'intervention_code': interventionCode,
      'is_active': isActive,
    };
  }
}