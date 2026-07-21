// Static task templates for psychologist task creation
// These are pre-defined templates that can be used to quickly create tasks

import '../models/task_template_model.dart';

class TaskTemplates {
  static const List<TaskTemplate> all = [
    // TCC - Cognitive Behavioral Therapy
    TaskTemplate(
      id: 'tcc_thought_record',
      category: 'tcc',
      categoryLabel: 'TCC',
      title: 'Registro de Pensamentos Automáticos',
      description: 'Registre situações que geraram desconforto, identificando pensamentos automáticos, emoções e comportamentos.',
      reflectionQuestion: 'Quais evidências sustentam ou contradizem esse pensamento?',
      protocol: 'TCC',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'tcc_cognitive_restructuring',
      category: 'tcc',
      categoryLabel: 'TCC',
      title: 'Reestruturação Cognitiva',
      description: 'Pratique a identificação e questionamento de pensamentos distorcidos, substituindo por alternativas mais realistas.',
      reflectionQuestion: 'Qual seria um pensamento mais equilibrado sobre essa situação?',
      protocol: 'TCC',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'tcc_behavioral_experiment',
      category: 'tcc',
      categoryLabel: 'TCC',
      title: 'Experimento Comportamental',
      description: 'Teste uma crença através de uma ação planejada. Registre o que aconteceu e o que aprendeu.',
      reflectionQuestion: 'O resultado confirmou ou refutou sua crença inicial?',
      protocol: 'TCC',
      difficultyLevel: 3,
    ),

    // Behavioral Activation
    TaskTemplate(
      id: 'ba_activity_scheduling',
      category: 'ativacao_comportamental',
      categoryLabel: 'Ativação Comportamental',
      title: 'Agendamento de Atividades Prazerosas',
      description: 'Planeje e realize pelo menos uma atividade prazerosa ou significativa por dia. Registre como se sentiu antes e depois.',
      reflectionQuestion: 'Como seu humor mudou após a atividade?',
      protocol: 'Ativação Comportamental',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'ba_routine_building',
      category: 'ativacao_comportamental',
      categoryLabel: 'Ativação Comportamental',
      title: 'Construção de Rotina Saudável',
      description: 'Estabeleça horários regulares para acordar, refeições, exercícios e sono. Mantenha por uma semana.',
      reflectionQuestion: 'Quais mudanças percebeu na sua energia e disposição?',
      protocol: 'Ativação Comportamental',
      difficultyLevel: 2,
    ),

    // Mindfulness
    TaskTemplate(
      id: 'mindfulness_breathing',
      category: 'mindfulness',
      categoryLabel: 'Mindfulness',
      title: 'Respiração Consciente (5 min)',
      description: 'Pratique respiração diafragmática por 5 minutos, focando apenas na sensação do ar entrando e saindo.',
      reflectionQuestion: 'Como seu corpo e mente se sentem após a prática?',
      protocol: 'Mindfulness',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'mindfulness_body_scan',
      category: 'mindfulness',
      categoryLabel: 'Mindfulness',
      title: 'Body Scan (10 min)',
      description: 'Faça uma varredura corporal da cabeça aos pés, observando sensações sem julgamento.',
      reflectionQuestion: 'Quais áreas do corpo apresentavam mais tensão?',
      protocol: 'Mindfulness',
      difficultyLevel: 1,
    ),

    // Anxiety Management
    TaskTemplate(
      id: 'anxiety_worry_time',
      category: 'ansiedade',
      categoryLabel: 'Ansiedade',
      title: 'Tempo de Preocupação Programado',
      description: 'Reserve 15 minutos por dia para se preocupar deliberadamente. Fora desse horário, anote as preocupações para depois.',
      reflectionQuestion: 'O que percebeu sobre a natureza das suas preocupações?',
      protocol: 'Controle de Ansiedade',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'anxiety_exposure',
      category: 'ansiedade',
      categoryLabel: 'Ansiedade',
      title: 'Exposição Gradual',
      description: 'Encare uma situação evitada por ansiedade, começando pela menos assustadora. Permaneça até a ansiedade diminuir.',
      reflectionQuestion: 'Qual foi o nível máximo de ansiedade e quanto tempo levou para reduzir?',
      protocol: 'Terapia de Exposição',
      difficultyLevel: 3,
    ),

    // Depression
    TaskTemplate(
      id: 'depression_gratitude_journal',
      category: 'depressao',
      categoryLabel: 'Depressão',
      title: 'Diário de Gratidão',
      description: 'Antes de dormir, escreva 3 coisas pelas quais foi grato hoje, por menores que sejam.',
      reflectionQuestion: 'Como esse exercício afetou sua perspectiva sobre o dia?',
      protocol: 'Psicologia Positiva',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'depression_small_goals',
      category: 'depressao',
      categoryLabel: 'Depressão',
      title: 'Metas Micro-Diárias',
      description: 'Defina 3 micro-metas realizáveis para hoje (ex.: levantar da cama, tomar banho, sair 5 min). Marque ao concluir.',
      reflectionQuestion: 'Como se sentiu ao completar cada micro-meta?',
      protocol: 'Ativação Comportamental',
      difficultyLevel: 1,
    ),

    // Relaxation
    TaskTemplate(
      id: 'relaxation_progressive',
      category: 'relaxamento',
      categoryLabel: 'Relaxamento',
      title: 'Relaxamento Muscular Progressivo',
      description: 'Tension e relaxe cada grupo muscular dos pés à cabeça. Pratique por 10-15 minutos.',
      reflectionQuestion: 'Quais áreas guardavam mais tensão?',
      protocol: 'Técnicas de Relaxamento',
      difficultyLevel: 1,
    ),

    // Sleep Hygiene
    TaskTemplate(
      id: 'sleep_hygiene',
      category: 'sono',
      categoryLabel: 'Sono',
      title: 'Higiene do Sono',
      description: 'Siga uma rotina noturna: evite telas 1h antes de dormir, quarto escuro/silencioso, horário regular.',
      reflectionQuestion: 'Como foi a qualidade do sono após seguir a rotina?',
      protocol: 'Higiene do Sono',
      difficultyLevel: 1,
    ),

    // Interpersonal
    TaskTemplate(
      id: 'interpersonal_assertiveness',
      category: 'relacionamentos',
      categoryLabel: 'Relacionamentos',
      title: 'Comunicação Assertiva',
      description: 'Pratique expressar necessidades e limites usando "Eu sinto... quando... porque... preciso...".',
      reflectionQuestion: 'Como a outra pessoa reagiu à sua comunicação assertiva?',
      protocol: 'Habilidades Sociais',
      difficultyLevel: 2,
    ),
  ];

  static List<TaskTemplate> getByCategory(String category) {
    return all.where((t) => t.category == category).toList();
  }

  static List<String> get categories {
    return all.map((t) => t.category).toSet().toList()..sort();
  }

  static List<String> get categoryLabels {
    return all.map((t) => t.categoryLabel).toSet().toList()..sort();
  }

  static Map<String, String> get categoryToLabel {
    final map = <String, String>{};
    for (final t in all) {
      map[t.category] = t.categoryLabel;
    }
    return map;
  }
}