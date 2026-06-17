class ClinicalRecommendation {
  final String text;
  final String severity;

  const ClinicalRecommendation({
    required this.text,
    required this.severity,
  });
}

class ClinicalAIService {
  List<ClinicalRecommendation> generate({
    required double adherence,
    required double moodAverage,
    required int completedTasks,
  }) {
    final recommendations =
        <ClinicalRecommendation>[];

    if (adherence < 40) {
      recommendations.add(
        const ClinicalRecommendation(
          text:
              'Reduzir tarefas para micro intervenções.',
          severity: 'warning',
        ),
      );
    }

    if (moodAverage <= 3) {
      recommendations.add(
        const ClinicalRecommendation(
          text:
              'Monitorar sinais de humor deprimido.',
          severity: 'high',
        ),
      );
    }

    if (completedTasks >= 5 &&
        adherence > 80) {
      recommendations.add(
        const ClinicalRecommendation(
          text:
              'Paciente apto para avançar protocolo.',
          severity: 'positive',
        ),
      );
    }

    return recommendations;
  }
}