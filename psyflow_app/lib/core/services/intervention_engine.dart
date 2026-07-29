import '../../models/intervention_template.dart';
import '../../models/user_model.dart';

class InterventionRecommendation {
  final String title;
  final String description;
  final String category;
  final String rationale; // Motivo da recomendação
  final int recommendedMinutes;
  final ProfessionalSpecialty specialty;

  const InterventionRecommendation({
    required this.title,
    required this.description,
    required this.category,
    required this.rationale,
    required this.recommendedMinutes,
    this.specialty = ProfessionalSpecialty.psychology,
  });
}

class InterventionEngine {
  const InterventionEngine();

  /// Determina o código da próxima intervenção com base na taxa de sucesso
  String? getNextIntervention({
    required InterventionTemplate current,
    required int completionScore,
  }) {
    if (completionScore >= current.successThreshold) {
      return current.nextSuccessCode;
    }
    if (completionScore <= current.failureThreshold) {
      return current.nextFailureCode;
    }
    return current.interventionCode;
  }

  /// Gera recomendações inteligentes de intervenção baseadas no nível de humor (1 a 5) e histórico recente
  List<InterventionRecommendation> recommendInterventionsForMood({
    required int averageMoodScore,
    ProfessionalSpecialty specialty = ProfessionalSpecialty.psychology,
  }) {
    final list = <InterventionRecommendation>[];

    if (averageMoodScore <= 2) {
      // Humor baixo / Crise de Ansiedade / Estresse elevado
      if (specialty == ProfessionalSpecialty.occupationalTherapy) {
        list.add(const InterventionRecommendation(
          title: 'Pausa para Reorganização Sensorial',
          description: 'Exercício de compressão articular e respiração ritmada de 5 minutos.',
          category: 'Sensorial / AVD',
          rationale: 'Detectada oscilação de humor negativa. Recomendada atividade de auto-regulação sensorial.',
          recommendedMinutes: 5,
          specialty: ProfessionalSpecialty.occupationalTherapy,
        ));
      } else if (specialty == ProfessionalSpecialty.speechTherapy) {
        list.add(const InterventionRecommendation(
          title: 'Exercício de Ritmo e Respiração Vocal',
          description: 'Relaxamento de musculatura laringofaringea com sons facilitadores.',
          category: 'Vocal',
          rationale: 'Redução da tensão vocal associada ao estresse emocional.',
          recommendedMinutes: 8,
          specialty: ProfessionalSpecialty.speechTherapy,
        ));
      } else {
        // Psicologia / Padrão
        list.add(const InterventionRecommendation(
          title: 'Técnica de Aterramento (Grounding 5-4-3-2-1)',
          description: 'Identifique 5 coisas que vê, 4 que pode tocar, 3 que ouve, 2 que cheira e 1 sabor.',
          category: 'Reestruturação / Mindfulness',
          rationale: 'Detectado picos de ansiedade ou queda no diário de humor.',
          recommendedMinutes: 10,
          specialty: ProfessionalSpecialty.psychology,
        ));
        list.add(const InterventionRecommendation(
          title: 'Diário de Registro de Pensamentos Automáticos (RPA)',
          description: 'Anote a situação, o pensamento automático e a emoção sentida no momento.',
          category: 'TCC',
          rationale: 'Auxilia na identificação de distorções cognitivas ativas.',
          recommendedMinutes: 15,
          specialty: ProfessionalSpecialty.psychology,
        ));
      }
    } else if (averageMoodScore == 3) {
      // Humor Neutro
      list.add(InterventionRecommendation(
        title: 'Check-in Diário de Metas Ocupacionais',
        description: 'Revisão pequena de conquistas do dia e organização da rotina.',
        category: 'Rotina / Metas',
        rationale: 'Manutenção de engajamento e acompanhamento de rotina.',
        recommendedMinutes: 10,
        specialty: specialty,
      ));
    } else {
      // Humor Positivo (4 ou 5)
      list.add(InterventionRecommendation(
        title: 'Ancoragem de Conquistas e Gratidão',
        description: 'Registro das estratégias de enfrentamento funcionais utilizadas no dia.',
        category: 'Psicologia Positiva',
        rationale: 'Reforço positivo de comportamentos adaptativos.',
        recommendedMinutes: 5,
        specialty: specialty,
      ));
    }

    return list;
  }
}