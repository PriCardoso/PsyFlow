import '../../models/user_model.dart';

class ClinicalRecommendation {
  final String text;
  final String severity; // positive, warning, high

  const ClinicalRecommendation({
    required this.text,
    required this.severity,
  });
}

class AiTaskSuggestion {
  final String title;
  final String description;
  final String category;
  final int estimatedMinutes;
  final String rationale;

  const AiTaskSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedMinutes,
    required this.rationale,
  });
}

class ClinicalAIService {
  /// Gera alertas e insights de monitoramento clínico
  List<ClinicalRecommendation> generate({
    required double adherence,
    required double moodAverage,
    required int completedTasks,
  }) {
    final recommendations = <ClinicalRecommendation>[];

    if (adherence < 40) {
      recommendations.add(
        const ClinicalRecommendation(
          text: 'Baixa adesão detectada (<40%). Sugere-se fracionar tarefas em micro-intervenções de 3 minutos.',
          severity: 'warning',
        ),
      );
    }

    if (moodAverage <= 2.5) {
      recommendations.add(
        const ClinicalRecommendation(
          text: 'Humor médio em nível crítico (<= 2.5). Recomenda-se agendar sessão de acolhimento e aplicar escala GAD-7/PHQ-9.',
          severity: 'high',
        ),
      );
    }

    if (completedTasks >= 5 && adherence > 80) {
      recommendations.add(
        const ClinicalRecommendation(
          text: 'Excelente engajamento (>80% adesão). Paciente apto para progressão de fase no protocolo.',
          severity: 'positive',
        ),
      );
    }

    return recommendations;
  }

  /// Sugere tarefas customizadas com base nas metas informadas e especialidade profissional
  List<AiTaskSuggestion> suggestTasksFromClinicalGoals({
    required String clinicalGoals,
    ProfessionalSpecialty specialty = ProfessionalSpecialty.psychology,
  }) {
    final suggestions = <AiTaskSuggestion>[];

    if (specialty == ProfessionalSpecialty.occupationalTherapy) {
      suggestions.add(AiTaskSuggestion(
        title: 'Mapeamento de Rotina de Autocuidado (AVDs)',
        description: 'Registrar horários de sono, alimentação e momentos de pausa sensorial ao longo de 3 dias.',
        category: 'Rotina Ocupacional',
        estimatedMinutes: 15,
        rationale: 'Fortalece o engajamento em AVDs com base nas metas: $clinicalGoals',
      ));
    } else if (specialty == ProfessionalSpecialty.psychopedagogy) {
      suggestions.add(AiTaskSuggestion(
        title: 'Organizador Visual de Tarefas Escolares/Trabalho',
        description: 'Dividir um projeto grande em 3 etapas com alarmes e recompensas visuais.',
        category: 'Funções Executivas',
        estimatedMinutes: 10,
        rationale: 'Estimulação de planejamento e controle inibitório para: $clinicalGoals',
      ));
    } else {
      suggestions.add(AiTaskSuggestion(
        title: 'Diário Sintético de Reestruturação Cognitiva',
        description: 'Identificar a situação gatilho e listar duas interpretações alternativas mais equilibradas.',
        category: 'TCC',
        estimatedMinutes: 10,
        rationale: 'Auxilia na modulação de esquemas associados a: $clinicalGoals',
      ));
    }

    return suggestions;
  }

  /// Converte notas de sessão brutas em um resumo estruturado de prontuário
  String generateSessionSummary({
    required String rawNotes,
    required String patientName,
  }) {
    if (rawNotes.trim().isEmpty) return 'Nenhuma anotação fornecida.';

    final now = DateTime.now();
    final formattedDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    return '''
[SÍNTESE DE SESSÃO CLÍNICA — PROCESSO TERAPÊUTICO]
Data do Encontro: $formattedDate
Paciente: $patientName

1. RESUMO DOS TEMAS ABORDADOS:
${rawNotes.trim()}

2. IMPRESSÃO CLÍNICA & ESTADO EMOCIONAL:
Paciente demonstrou colaboração no processo. Estratégias de reflexão foram propostas e acolhidas.

3. PLANO DE AÇÃO & COMBINADOS:
Manter acompanhamento dos registros de diário emocional e conclusão dos exercícios atribuídos.
''';
  }

  /// Gera minuta de relatório evolutivo para emissão de laudo ou parecer
  String draftClinicalReport({
    required String patientName,
    required String professionalName,
    required String specialtyLabel,
    required int totalSessions,
    required double adherenceRate,
    required String clinicalSummary,
  }) {
    final now = DateTime.now();
    final formattedDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    return '''
RELATÓRIO DE EVOLUÇÃO MULTIDISCIPLINAR COM APOIO DE IA

Paciente: $patientName
Profissional Responsável: $professionalName ($specialtyLabel)
Data de Emissão: $formattedDate

1. HISTÓRICO E FREQUÊNCIA:
O(A) paciente participou de um total de $totalSessions sessões/encontros terapêuticos até a presente data, apresentando uma taxa de adesão estimada em ${adherenceRate.toStringAsFixed(0)}%.

2. ANÁLISE DE EVOLUÇÃO E SÍNTESE CLÍNICA:
$clinicalSummary

3. RECOMENDAÇÕES E SEGUIMENTO:
Recomenda-se a continuidade do acompanhamento para consolidação dos ganhos terapêuticos e fortalecimento das estratégias de autonomia.

___________________________________________
$professionalName — $specialtyLabel
PsyFlow Platform
''';
  }
}