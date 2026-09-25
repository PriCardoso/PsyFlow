// Catálogo oficial de questionários clínicos, escalas de rastreio e tarefas terapêuticas por faixa etária
// Desenvolvido para o módulo de acompanhamento terapêutico do PsyFlow

class TaskFormFieldConfig {
  final int ordem;
  final String label;
  final String tipo; // 'texto_longo', 'texto_curto', 'escala_linear', 'selecao_unica', 'emoji_picker', 'multipla_escolha'
  final String? placeholder;
  final int? min;
  final int? max;
  final String? labelMin;
  final String? labelMax;
  final List<String>? options;
  final List<int>? optionValues;

  const TaskFormFieldConfig({
    required this.ordem,
    required this.label,
    required this.tipo,
    this.placeholder,
    this.min,
    this.max,
    this.labelMin,
    this.labelMax,
    this.options,
    this.optionValues,
  });

  Map<String, dynamic> toMap() {
    return {
      'ordem': ordem,
      'label': label,
      'tipo': tipo,
      if (placeholder != null) 'placeholder': placeholder,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (labelMin != null) 'label_min': labelMin,
      if (labelMax != null) 'label_max': labelMax,
      if (options != null) 'options': options,
      if (optionValues != null) 'option_values': optionValues,
    };
  }

  factory TaskFormFieldConfig.fromMap(Map<String, dynamic> map) {
    return TaskFormFieldConfig(
      ordem: (map['ordem'] as num?)?.toInt() ?? 1,
      label: (map['label'] ?? '') as String,
      tipo: (map['tipo'] ?? 'texto_longo') as String,
      placeholder: map['placeholder'] as String?,
      min: (map['min'] as num?)?.toInt(),
      max: (map['max'] as num?)?.toInt(),
      labelMin: map['label_min'] as String?,
      labelMax: map['label_max'] as String?,
      options: (map['options'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      optionValues: (map['option_values'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    );
  }
}

class CatalogTaskTemplate {
  final String id;
  final String title;
  final String description;
  final String category; // 'ansiedade', 'depressao', 'tdah', 'tea', 'transdiagnostico', 'cognitiva', 'comportamental', 'mindfulness', 'autonomia'
  final String categoryLabel;
  final String ageGroup; // 'crianca', 'adolescente', 'adulto', 'idoso', 'todas'
  final String ageGroupLabel;
  final String protocol;
  final int difficultyLevel;
  final String tipoInput; // 'formulario_multiplo', 'escala_clinica', 'exercicio_guiado', 'texto_simples'
  final List<TaskFormFieldConfig> campos;

  const CatalogTaskTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryLabel,
    required this.ageGroup,
    required this.ageGroupLabel,
    required this.protocol,
    this.difficultyLevel = 1,
    this.tipoInput = 'formulario_multiplo',
    required this.campos,
  });
}

class TaskCatalog {
  TaskCatalog._();

  // Categorias disponíveis
  static const Map<String, String> categories = {
    'todas': 'Todas as Categorias',
    'ansiedade': 'Ansiedade',
    'depressao': 'Depressão',
    'tdah': 'TDAH',
    'tea': 'TEA (Autismo)',
    'transdiagnostico': 'Transdiagnósticas',
    'cognitiva': 'Cognitiva (TCC)',
    'comportamental': 'Comportamental',
    'mindfulness': 'Mindfulness & Regulação',
    'autonomia': 'Autonomia & Gratidão',
  };

  // Faixas etárias disponíveis
  static const Map<String, String> ageGroups = {
    'todas': 'Todas as Idades',
    'crianca': 'Crianças (Até 11 anos)',
    'adolescente': 'Adolescentes (12 a 17 anos)',
    'adulto': 'Adultos (18 a 59 anos)',
    'idoso': 'Idosos (60+ anos)',
  };

  static List<CatalogTaskTemplate> get allTemplates => [
        // =========================================================================
        // 1. QUESTIONÁRIOS E ESCALAS CLÍNICAS DE RASTREIO
        // =========================================================================

        // --- ANSIEDADE ---
        CatalogTaskTemplate(
          id: 'escala_gad7',
          title: 'GAD-7 (Generalized Anxiety Disorder-7)',
          description: 'Questionário breve com 7 perguntas focado em rastrear o transtorno de ansiedade generalizada nas últimas 2 semanas.',
          category: 'ansiedade',
          categoryLabel: 'Ansiedade',
          ageGroup: 'todas',
          ageGroupLabel: 'Adolescentes & Adultos',
          protocol: 'Escala de Rastreio',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: '1. Sentir-se nervoso, ansioso ou no limite', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: '2. Não conseguir parar ou controlar as preocupações', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: '3. Preocupar-se demais com coisas diferentes', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: '4. Dificuldade para relaxar', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 5, label: '5. Ficar tão inquieto que é difícil ficar sentado', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 6, label: '6. Ficar facilmente irritado ou aborrecido', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 7, label: '7. Sentir medo como se algo terrível fosse acontecer', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_bai',
          title: 'BAI (Beck Anxiety Inventory)',
          description: 'Inventário de autoavaliação com itens voltados aos sintomas físicos e cognitivos da ansiedade.',
          category: 'ansiedade',
          categoryLabel: 'Ansiedade',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos',
          protocol: 'Inventário de Beck',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Dormência ou formigamento', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: 'Sensação de calor / ondas de calor', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: 'Tremores nas pernas ou braços', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: 'Incapacidade de relaxar', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 5, label: 'Medo de que o pior aconteça', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 6, label: 'Tonturas ou sensação de desmaio', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 7, label: 'Coração acelerado ou palpitações', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 8, label: 'Sensação de sufocação ou aperto no peito', tipo: 'selecao_unica', options: ['Absolutamente não', 'Levemente', 'Moderadamente', 'Gravemente'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_hama',
          title: 'HAM-A (Hamilton Anxiety Rating Scale)',
          description: 'Escala detalhada para mensurar a gravidade da ansiedade física e psíquica.',
          category: 'ansiedade',
          categoryLabel: 'Ansiedade',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos',
          protocol: 'Escala de Hamilton',
          difficultyLevel: 2,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Humor Ansioso (preocupações, antecipação do pior, apreensão)', tipo: 'selecao_unica', options: ['Ausente', 'Leve', 'Moderado', 'Grave', 'Muito grave'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 2, label: 'Tensão (fadiga, sobressalto, choro fácil, tremores)', tipo: 'selecao_unica', options: ['Ausente', 'Leve', 'Moderado', 'Grave', 'Muito grave'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 3, label: 'Medos (de escuro, estranhos, multidão, solidão)', tipo: 'selecao_unica', options: ['Ausente', 'Leve', 'Moderado', 'Grave', 'Muito grave'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 4, label: 'Insônia (dificuldade para adormecer, sono interrompido)', tipo: 'selecao_unica', options: ['Ausente', 'Leve', 'Moderado', 'Grave', 'Muito grave'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 5, label: 'Sintomas Somáticos Musculares (dores, rigidez, ranger de dentes)', tipo: 'selecao_unica', options: ['Ausente', 'Leve', 'Moderado', 'Grave', 'Muito grave'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 6, label: 'Sintomas Cardiovasculares (taquicardia, palpitações, dor no peito)', tipo: 'selecao_unica', options: ['Ausente', 'Leve', 'Moderado', 'Grave', 'Muito grave'], optionValues: [0, 1, 2, 3, 4]),
          ],
        ),

        // --- DEPRESSÃO ---
        CatalogTaskTemplate(
          id: 'escala_phq9',
          title: 'PHQ-9 (Patient Health Questionnaire-9)',
          description: 'O instrumento de rastreio de depressão mais utilizado no mundo, baseado em 9 critérios diagnósticos nas últimas 2 semanas.',
          category: 'depressao',
          categoryLabel: 'Depressão',
          ageGroup: 'todas',
          ageGroupLabel: 'Adolescentes & Adultos',
          protocol: 'Escala de Rastreio',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: '1. Pouco interesse ou prazer em fazer coisas', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: '2. Sentir-se para baixo, deprimido ou sem esperança', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: '3. Dificuldade para adormecer, permanecer dormindo ou dormir demais', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: '4. Sentir-se cansado ou com pouca energia', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 5, label: '5. Apetite reduzido ou comer em excesso', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 6, label: '6. Sentir-se mal consigo mesmo — ou que é um fracasso', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 7, label: '7. Dificuldade para se concentrar nas coisas (como ler ou ver TV)', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 8, label: '8. Movimentar-se ou falar tão devagar que os outros notaram, ou agitação motora', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 9, label: '9. Pensamentos de que seria melhor estar morto ou de se ferir de alguma forma', tipo: 'selecao_unica', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_bdi',
          title: 'BDI (Beck Depression Inventory)',
          description: 'Inventário clássico de autoavaliação da severidade dos sintomas depressivos.',
          category: 'depressao',
          categoryLabel: 'Depressão',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos',
          protocol: 'Inventário de Beck',
          difficultyLevel: 2,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Tristeza e Desânimo', tipo: 'selecao_unica', options: ['Não me sinto triste', 'Sinto-me triste na maior parte do tempo', 'Estou sempre triste e não consigo sair disso', 'Estou tão triste que não suporto'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: 'Pessimismo em relação ao Futuro', tipo: 'selecao_unica', options: ['Não estou desanimado quanto ao meu futuro', 'Sinto-me mais desanimado quanto ao futuro que o normal', 'Não espero que nada dê certo para mim', 'Sinto que o futuro é sem esperança'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: 'Sensação de Fracasso', tipo: 'selecao_unica', options: ['Não me sinto um fracassado', 'Sinto que fracassei mais que a maioria', 'Quando olho para trás, vejo muitos fracassos', 'Sinto que sou um fracasso total como pessoa'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: 'Perda de Prazer (Anedonia)', tipo: 'selecao_unica', options: ['Sinto o mesmo prazer de sempre nas coisas', 'Não sinto tanto prazer nas coisas como antes', 'Tenho muito pouco prazer com as coisas que gostava', 'Não consigo sentir prazer com nada'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_cesd',
          title: 'CES-D (Center for Epidemiologic Studies Depression Scale)',
          description: 'Escala de rastreio para sintomas depressivos na população geral.',
          category: 'depressao',
          categoryLabel: 'Depressão',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos & Idosos',
          protocol: 'Rastreio Populacional',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Fiquei incomodado com coisas que habitualmente não me incomodam', tipo: 'selecao_unica', options: ['Raramente (<1 dia)', 'Pouco (1-2 dias)', 'Moderadamente (3-4 dias)', 'Maior parte (5-7 dias)'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: 'Senti que não conseguia afastar a tristeza mesmo com ajuda de familiares', tipo: 'selecao_unica', options: ['Raramente (<1 dia)', 'Pouco (1-2 dias)', 'Moderadamente (3-4 dias)', 'Maior parte (5-7 dias)'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: 'Senti que tudo o que fazia exigia um esforço enorme', tipo: 'selecao_unica', options: ['Raramente (<1 dia)', 'Pouco (1-2 dias)', 'Moderadamente (3-4 dias)', 'Maior parte (5-7 dias)'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: 'Senti esperança em relação ao futuro (Item invertido)', tipo: 'selecao_unica', options: ['Maior parte (5-7 dias)', 'Moderadamente (3-4 dias)', 'Pouco (1-2 dias)', 'Raramente (<1 dia)'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        // --- TRANSTORNO DO ESPECTRO AUTISTA (TEA) ---
        CatalogTaskTemplate(
          id: 'escala_mchat',
          title: 'M-CHAT (Modified Checklist for Autism in Toddlers)',
          description: 'Escala de rastreio precoce aplicada em crianças pequenas (de 16 a 30 meses) respondida pelos pais/cuidadores.',
          category: 'tea',
          categoryLabel: 'TEA (Autismo)',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças (16 a 30 meses)',
          protocol: 'Triagem Precoce TEA',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Se você aponta para algo no quarto, a criança olha para lá?', tipo: 'selecao_unica', options: ['Sim', 'Não'], optionValues: [0, 1]),
            TaskFormFieldConfig(ordem: 2, label: 'Você já se perguntou se sua criança pode ser surda?', tipo: 'selecao_unica', options: ['Não', 'Sim'], optionValues: [0, 1]),
            TaskFormFieldConfig(ordem: 3, label: 'A criança brinca de faz-de-conta (ex: alimentar boneca, falar ao telefone de brinquedo)?', tipo: 'selecao_unica', options: ['Sim', 'Não'], optionValues: [0, 1]),
            TaskFormFieldConfig(ordem: 4, label: 'A criança gosta de subir em coisas (móveis, escadas)?', tipo: 'selecao_unica', options: ['Sim', 'Não'], optionValues: [0, 1]),
            TaskFormFieldConfig(ordem: 5, label: 'A criança faz movimentos estranhos com os dedos perto dos olhos?', tipo: 'selecao_unica', options: ['Não', 'Sim'], optionValues: [0, 1]),
            TaskFormFieldConfig(ordem: 6, label: 'A criança aponta com o indicador para pedir algo ou para mostrar interesse?', tipo: 'selecao_unica', options: ['Sim', 'Não'], optionValues: [0, 1]),
            TaskFormFieldConfig(ordem: 7, label: 'A criança olha nos seus olhos quando você fala ou brinca com ela?', tipo: 'selecao_unica', options: ['Sim', 'Não'], optionValues: [0, 1]),
            TaskFormFieldConfig(ordem: 8, label: 'A criança responde quando é chamada pelo nome?', tipo: 'selecao_unica', options: ['Sim', 'Não'], optionValues: [0, 1]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_aq10',
          title: 'AQ-10 (Autism Spectrum Quotient - Versão Breve)',
          description: 'Questionário de autoavaliação e triagem rápida de traços autistas em adolescentes e adultos.',
          category: 'tea',
          categoryLabel: 'TEA (Autismo)',
          ageGroup: 'todas',
          ageGroupLabel: 'Adolescentes & Adultos',
          protocol: 'Triagem de Traços Autistas',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Frequentemente percebo pequenos sons que os outros não notam.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [1, 1, 0, 0]),
            TaskFormFieldConfig(ordem: 2, label: 'Costumo me concentrar mais na imagem geral do que nos pequenos detalhes.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [0, 0, 1, 1]),
            TaskFormFieldConfig(ordem: 3, label: 'Acho fácil fazer mais de uma coisa ao mesmo tempo.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [0, 0, 1, 1]),
            TaskFormFieldConfig(ordem: 4, label: 'Se há interrupções, consigo voltar rapidamente ao que estava fazendo.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [0, 0, 1, 1]),
            TaskFormFieldConfig(ordem: 5, label: 'Acho fácil "ler nas entrelinhas" quando alguém conversa comigo.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [0, 0, 1, 1]),
            TaskFormFieldConfig(ordem: 6, label: 'Sei perceber se a pessoa que está me ouvindo está ficando entediada.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [0, 0, 1, 1]),
            TaskFormFieldConfig(ordem: 7, label: 'Quando estou lendo uma história, acho difícil descobrir as intenções dos personagens.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [1, 1, 0, 0]),
            TaskFormFieldConfig(ordem: 8, label: 'Gosto de colecionar informações sobre categorias de coisas.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [1, 1, 0, 0]),
            TaskFormFieldConfig(ordem: 9, label: 'Acho fácil descobrir o que alguém está sentindo apenas olhando para o rosto da pessoa.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [0, 0, 1, 1]),
            TaskFormFieldConfig(ordem: 10, label: 'Acho difícil fazer novos amigos.', tipo: 'selecao_unica', options: ['Concordo totalmente', 'Concordo parcialmente', 'Discordo parcialmente', 'Discordo totalmente'], optionValues: [1, 1, 0, 0]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_catq',
          title: 'CAT-Q (Camouflaging Autistic Traits Questionnaire)',
          description: 'Avalia o esforço de camuflagem, compensação e mascaramento de traços autistas em situações sociais.',
          category: 'tea',
          categoryLabel: 'TEA (Autismo)',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adolescentes & Adultos',
          protocol: 'Camuflagem Social TEA',
          difficultyLevel: 2,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Em interações sociais, monitoro constantemente minha linguagem corporal e expressões faciais.', tipo: 'selecao_unica', options: ['Discordo fortemente', 'Discordo', 'Neutro', 'Concordo', 'Concordo fortemente'], optionValues: [1, 2, 3, 4, 5]),
            TaskFormFieldConfig(ordem: 2, label: 'Copio comportamentos, frases ou piadas de outras pessoas para me entrosar.', tipo: 'selecao_unica', options: ['Discordo fortemente', 'Discordo', 'Neutro', 'Concordo', 'Concordo fortemente'], optionValues: [1, 2, 3, 4, 5]),
            TaskFormFieldConfig(ordem: 3, label: 'Preparo com antecedência tópicos ou roteiros mentais antes de interagir.', tipo: 'selecao_unica', options: ['Discordo fortemente', 'Discordo', 'Neutro', 'Concordo', 'Concordo fortemente'], optionValues: [1, 2, 3, 4, 5]),
            TaskFormFieldConfig(ordem: 4, label: 'Sinto uma exaustão intensa após eventos sociais por ter que "atuar" o tempo todo.', tipo: 'selecao_unica', options: ['Discordo fortemente', 'Discordo', 'Neutro', 'Concordo', 'Concordo fortemente'], optionValues: [1, 2, 3, 4, 5]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_raads',
          title: 'RAADS-R (Ritvo Autism Asperger Diagnostic Scale-Revised)',
          description: 'Escala ampla de triagem para traços autistas na vida adulta (linguagem, sensorialidade e sociabilidade).',
          category: 'tea',
          categoryLabel: 'TEA (Autismo)',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos',
          protocol: 'Triagem Adulta TEA',
          difficultyLevel: 2,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Tenho sensibilidade incomum a texturas de roupas, luzes fortes ou ruídos específicos.', tipo: 'selecao_unica', options: ['Nunca', 'Apenas na infância', 'Apenas agora', 'Sempre foi verdadeiro'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: 'Fico confuso quando as pessoas usam sarcasmo ou metáforas sem explicar.', tipo: 'selecao_unica', options: ['Nunca', 'Apenas na infância', 'Apenas agora', 'Sempre foi verdadeiro'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: 'Prefiro passar o tempo com meus interesses especiais do que em conversas casuais.', tipo: 'selecao_unica', options: ['Nunca', 'Apenas na infância', 'Apenas agora', 'Sempre foi verdadeiro'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        // --- TDAH ---
        CatalogTaskTemplate(
          id: 'escala_asrs18',
          title: 'ASRS-18 (Adult ADHD Self-Report Scale - OMS)',
          description: 'Lista validada pela OMS para rastreio de TDAH em adultos com 18 sintomas (destaque para a Parte A de 6 itens).',
          category: 'tdah',
          categoryLabel: 'TDAH',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos',
          protocol: 'Escala OMS TDAH Adulto',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Parte A: Com que frequência você tem dificuldade para finalizar os detalhes de um projeto depois que as partes mais desafiadoras foram feitas?', tipo: 'selecao_unica', options: ['Nunca', 'Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 2, label: 'Parte A: Com que frequência tem dificuldade para pôr as coisas em ordem quando precisa fazer algo que exige organização?', tipo: 'selecao_unica', options: ['Nunca', 'Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 3, label: 'Parte A: Com que frequência você tem problemas para lembrar de compromissos ou obrigações?', tipo: 'selecao_unica', options: ['Nunca', 'Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 4, label: 'Parte A: Quando precisa fazer algo que exige muito pensamento, com que frequência evita ou adia o início?', tipo: 'selecao_unica', options: ['Nunca', 'Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 5, label: 'Parte A: Com que frequência fica se mexendo ou batendo pés/mãos quando precisa ficar sentado muito tempo?', tipo: 'selecao_unica', options: ['Nunca', 'Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3, 4]),
            TaskFormFieldConfig(ordem: 6, label: 'Parte A: Com que frequência se sente excessivamente ativo e compelido a fazer coisas, como se estivesse "ligado por um motor"?', tipo: 'selecao_unica', options: ['Nunca', 'Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3, 4]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_snapiv',
          title: 'SNAP-IV (TDAH & TOD em Crianças e Adolescentes)',
          description: 'Escala muito utilizada por pais e professores para rastrear sintomas de Desatenção, Hiperatividade/Impulsividade e Oposicionismo.',
          category: 'tdah',
          categoryLabel: 'TDAH',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças & Adolescentes',
          protocol: 'Avaliação SNAP-IV',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: '1. Não consegue prestar muita atenção a detalhes ou comete erros por descuido nas tarefas.', tipo: 'selecao_unica', options: ['Nem um pouco', 'Só um pouco', 'Bastante', 'Demais'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: '2. Tem dificuldade de manter a atenção em tarefas escolares ou em brincadeiras.', tipo: 'selecao_unica', options: ['Nem um pouco', 'Só um pouco', 'Bastante', 'Demais'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: '3. Parece não escutar quando se fala diretamente com ele(a).', tipo: 'selecao_unica', options: ['Nem um pouco', 'Só um pouco', 'Bastante', 'Demais'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: '4. Não segue instruções até o fim e não consegue terminar tarefas ou deveres.', tipo: 'selecao_unica', options: ['Nem um pouco', 'Só um pouco', 'Bastante', 'Demais'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 5, label: '5. Tem dificuldade para organizar tarefas e atividades.', tipo: 'selecao_unica', options: ['Nem um pouco', 'Só um pouco', 'Bastante', 'Demais'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 6, label: '6. Mexe com as mãos ou pés ou se remexe na cadeira.', tipo: 'selecao_unica', options: ['Nem um pouco', 'Só um pouco', 'Bastante', 'Demais'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 7, label: '7. Sai do lugar em sala de aula ou em outras situações em que se espera que fique sentado.', tipo: 'selecao_unica', options: ['Nem um pouco', 'Só um pouco', 'Bastante', 'Demais'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_etdah_diva',
          title: 'DIVA-5 / ETDAH-AD (Rastreio de TDAH no Adulto)',
          description: 'Itens diagnósticos chave para avaliação semiestruturada do impacto do TDAH na vida adulta e rotina profissional.',
          category: 'tdah',
          categoryLabel: 'TDAH',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos',
          protocol: 'Investigação Clínica TDAH',
          difficultyLevel: 2,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Dificuldade crônica em estimar o tempo necessário para executar tarefas e cumprir prazos.', tipo: 'selecao_unica', options: ['Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: 'Perda frequente de foco durante conversas longas, reuniões ou leituras densas.', tipo: 'selecao_unica', options: ['Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: 'Sensação constante de inquietação interna ou necessidade de estar sempre ocupado com algo.', tipo: 'selecao_unica', options: ['Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: 'Dificuldade para gerenciar finanças, papeladas e rotinas administrativas cotidianas.', tipo: 'selecao_unica', options: ['Raramente', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        // --- TRANSDIAGNÓSTICAS (MÚLTIPLOS SINTOMAS) ---
        CatalogTaskTemplate(
          id: 'escala_dass21',
          title: 'DASS-21 (Depression, Anxiety and Stress Scale)',
          description: 'Mede e diferencia simultaneamente os níveis e severidade de sintomas de Depressão, Ansiedade e Estresse.',
          category: 'transdiagnostico',
          categoryLabel: 'Transdiagnósticas',
          ageGroup: 'todas',
          ageGroupLabel: 'Adolescentes & Adultos',
          protocol: 'DASS-21 Triagem Tríplice',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: '[Ansiedade] Senti minha boca seca ou batimentos acelerados sem esforço físico.', tipo: 'selecao_unica', options: ['Não se aplicou a mim', 'Aplicou-se em algum grau', 'Aplicou-se em grau considerável', 'Aplicou-se muito'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 2, label: '[Depressão] Não consegui vivenciar nenhum sentimento positivo ou entusiasmo.', tipo: 'selecao_unica', options: ['Não se aplicou a mim', 'Aplicou-se em algum grau', 'Aplicou-se em grau considerável', 'Aplicou-se muito'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 3, label: '[Estresse] Achei difícil me acalmar e relaxar após situações tensas.', tipo: 'selecao_unica', options: ['Não se aplicou a mim', 'Aplicou-se em algum grau', 'Aplicou-se em grau considerável', 'Aplicou-se muito'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 4, label: '[Ansiedade] Senti tremores nas mãos ou sensação de pânico iminente.', tipo: 'selecao_unica', options: ['Não se aplicou a mim', 'Aplicou-se em algum grau', 'Aplicou-se em grau considerável', 'Aplicou-se muito'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 5, label: '[Depressão] Senti que não tinha nada pelo que esperar ou me animar.', tipo: 'selecao_unica', options: ['Não se aplicou a mim', 'Aplicou-se em algum grau', 'Aplicou-se em grau considerável', 'Aplicou-se muito'], optionValues: [0, 1, 2, 3]),
            TaskFormFieldConfig(ordem: 6, label: '[Estresse] Fui intolerante ou reagi de forma exagerada a pequenos contratempos.', tipo: 'selecao_unica', options: ['Não se aplicou a mim', 'Aplicou-se em algum grau', 'Aplicou-se em grau considerável', 'Aplicou-se muito'], optionValues: [0, 1, 2, 3]),
          ],
        ),

        CatalogTaskTemplate(
          id: 'escala_sdq',
          title: 'SDQ (Questionário de Forças e Dificuldades)',
          description: 'Triagem ampla de saúde mental, sintomas emocionais e comportamentais voltada para crianças e jovens.',
          category: 'transdiagnostico',
          categoryLabel: 'Transdiagnósticas',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças & Jovens',
          protocol: 'SDQ Triagem Comportamental',
          difficultyLevel: 1,
          tipoInput: 'escala_clinica',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Costuma considerar os sentimentos de outras pessoas e ser prestativo.', tipo: 'selecao_unica', options: ['Falso', 'Mais ou menos verdadeiro', 'Verdadeiro'], optionValues: [0, 1, 2]),
            TaskFormFieldConfig(ordem: 2, label: 'Tem muitas dores de cabeça, de estômago ou enjoos quando sob pressão.', tipo: 'selecao_unica', options: ['Falso', 'Mais ou menos verdadeiro', 'Verdadeiro'], optionValues: [0, 1, 2]),
            TaskFormFieldConfig(ordem: 3, label: 'Tem acessos de raiva ou perde a calma facilmente.', tipo: 'selecao_unica', options: ['Falso', 'Mais ou menos verdadeiro', 'Verdadeiro'], optionValues: [0, 1, 2]),
            TaskFormFieldConfig(ordem: 4, label: 'Geralmente brinca sozinho ou parece preferir a solidão.', tipo: 'selecao_unica', options: ['Falso', 'Mais ou menos verdadeiro', 'Verdadeiro'], optionValues: [0, 1, 2]),
          ],
        ),

        // =========================================================================
        // 2. TAREFAS TERAPÊUTICAS POR FAIXA ETÁRIA (CONFORME ESPECIFICAÇÃO DO PRODUTO)
        // =========================================================================

        // --- CRIANÇAS (Até 11 anos) ---
        CatalogTaskTemplate(
          id: 'crianca_diario_emocoes',
          title: '🎨 Diário das Emoções Visual',
          description: 'Escolher o emoji ou cor que representa o sentimento dominante do dia e contar o que aconteceu.',
          category: 'cognitiva',
          categoryLabel: 'Cognitiva (TCC)',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças (Até 11 anos)',
          protocol: 'TCC Infantil',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual carinha mais combina com seu sentimento de hoje?', tipo: 'emoji_picker', options: ['😄 Muito Feliz', '🙂 Bem/Calmo', '😐 Mais ou menos', '😢 Triste', '😡 Bravo/Irritado', '😨 Assustado']),
            TaskFormFieldConfig(ordem: 2, label: 'O que aconteceu hoje para você se sentir assim?', tipo: 'texto_longo', placeholder: 'Conte um pouquinho do que você fez ou do que aconteceu...'),
            TaskFormFieldConfig(ordem: 3, label: 'Se você pudesse dar uma cor para o seu dia, qual seria?', tipo: 'texto_curto', placeholder: 'Ex: Amarelo sol, azul calmo, cinza nuvem...'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'crianca_termometro_raiva',
          title: '🌡️ Termômetro da Raiva',
          description: 'Marcar visualmente em uma escala o nível de irritação nos momentos de frustração e o que ajudou a esfriar.',
          category: 'mindfulness',
          categoryLabel: 'Mindfulness & Regulação',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças (Até 11 anos)',
          protocol: 'Regulação Emocional Infantil',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual situação deixou você bravo ou chateado?', tipo: 'texto_longo', placeholder: 'Ex: Quando tive que parar de brincar ou quando alguém pegou meu brinquedo.'),
            TaskFormFieldConfig(ordem: 2, label: 'Em que nível o seu termômetro da raiva subiu?', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Calminho)', labelMax: '10 (Explodindo!)'),
            TaskFormFieldConfig(ordem: 3, label: 'O que você fez que ajudou o termômetro a esfriar?', tipo: 'texto_longo', placeholder: 'Ex: Bebi água, respirei fundo, abracei meu ursinho...'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'crianca_caca_sentidos',
          title: '🔍 Caça ao Tesouro dos Sentidos',
          description: 'Encontrar no ambiente 3 coisas bonitas para olhar, 2 texturas para tocar e 1 som para ouvir (Aterramento sensorial 3-2-1).',
          category: 'mindfulness',
          categoryLabel: 'Mindfulness & Regulação',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças (Até 11 anos)',
          protocol: 'Aterramento Sensorial',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: '👁️ 3 coisas bonitas ou coloridas que você viu ao seu redor:', tipo: 'texto_longo', placeholder: '1. ...\n2. ...\n3. ...'),
            TaskFormFieldConfig(ordem: 2, label: '✋ 2 coisas gostosas de tocar que você sentiu:', tipo: 'texto_longo', placeholder: '1. Macio como...\n2. Lisinho como...'),
            TaskFormFieldConfig(ordem: 3, label: '👂 1 som diferente que você escutou ao prestar atenção:', tipo: 'texto_curto', placeholder: 'Ex: O passarinho cantando, o barulho do vento...'),
            TaskFormFieldConfig(ordem: 4, label: 'Como seu corpinho ficou depois dessa caça ao tesouro?', tipo: 'selecao_unica', options: ['Mais calmo e tranquilo', 'Divertido e curioso', 'Igual antes']),
          ],
        ),

        CatalogTaskTemplate(
          id: 'crianca_pote_gratidao',
          title: '🏺 Pote da Gratidão',
          description: 'Registrar um acontecimento legal e especial do dia para guardar no seu pote virtual de coisas boas.',
          category: 'autonomia',
          categoryLabel: 'Autonomia & Gratidão',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças (Até 11 anos)',
          protocol: 'Psicologia Positiva Infantil',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual foi a melhor coisa que aconteceu com você hoje?', tipo: 'texto_longo', placeholder: 'Pode ser uma brincadeira legal, um abraço, um lanche gostoso...'),
            TaskFormFieldConfig(ordem: 2, label: 'Quem estava com você ou ajudou a tornar esse momento especial?', tipo: 'texto_curto', placeholder: 'Ex: Minha mãe, meu amigo, meu cachorrinho...'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'crianca_respiracao_bexiga',
          title: '🎈 Respiração da Bexiga',
          description: 'Exercício guiado na tela para simular encher uma bexiga (puxar o ar pelo nariz e soltar devagar pela boca 5 vezes).',
          category: 'mindfulness',
          categoryLabel: 'Mindfulness & Regulação',
          ageGroup: 'crianca',
          ageGroupLabel: 'Crianças (Até 11 anos)',
          protocol: 'Respiração Diafragmática Lúdica',
          difficultyLevel: 1,
          tipoInput: 'exercicio_guiado',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Você conseguiu fazer as 5 respirações lentas enchendo a bexiga imaginária?', tipo: 'selecao_unica', options: ['Sim, enchi 5 bexigas grandes!', 'Fiz algumas', 'Tive um pouquinho de dificuldade']),
            TaskFormFieldConfig(ordem: 2, label: 'Como você sentiu seu peito e sua barriga após a brincadeira?', tipo: 'texto_longo', placeholder: 'Ex: Ficou levinho e relaxado...'),
          ],
        ),

        // --- ADOLESCENTES (12 a 17 anos) ---
        CatalogTaskTemplate(
          id: 'adolescente_playlist_humor',
          title: '🎧 Playlist do Humor',
          description: 'Criar e anexar links de playlists musicais focadas em acalmar a ansiedade ou gerar ativação/energia.',
          category: 'mindfulness',
          categoryLabel: 'Mindfulness & Regulação',
          ageGroup: 'adolescente',
          ageGroupLabel: 'Adolescentes (12 a 17 anos)',
          protocol: 'Musicoterapia & Regulação',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual era seu objetivo com a playlist hoje?', tipo: 'selecao_unica', options: ['Acalmar a mente / desacelerar', 'Ganhar energia e disposição', 'Desabafar sentimentos / acolhimento', 'Foco nos estudos']),
            TaskFormFieldConfig(ordem: 2, label: 'Quais músicas ou artistas você escolheu?', tipo: 'texto_longo', placeholder: 'Cite 2 ou 3 faixas especiais ou o link da playlist...'),
            TaskFormFieldConfig(ordem: 3, label: 'Como seu nível de ansiedade ou energia mudou após ouvir?', tipo: 'escala_linear', min: 1, max: 10, labelMin: 'Piorou / Ficou pesado', labelMax: 'Melhorou muito / Alívio'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adolescente_desconexao',
          title: '📵 Desconexão Programada',
          description: 'Interromper o uso de telas 1 hora antes de dormir e monitorar o impacto na qualidade do sono.',
          category: 'comportamental',
          categoryLabel: 'Comportamental',
          ageGroup: 'adolescente',
          ageGroupLabel: 'Adolescentes (12 a 17 anos)',
          protocol: 'Higiene do Sono',
          difficultyLevel: 2,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'A que horas você desligou as telas ontem à noite?', tipo: 'texto_curto', placeholder: 'Ex: 22:30'),
            TaskFormFieldConfig(ordem: 2, label: 'O que você fez na hora livre sem celular/telas?', tipo: 'texto_longo', placeholder: 'Ex: Li um livro, tomei banho morno, conversei, escutei música...'),
            TaskFormFieldConfig(ordem: 3, label: 'Como foi a facilidade para pegar no sono?', tipo: 'escala_linear', min: 1, max: 10, labelMin: 'Muito difícil / Demorei horas', labelMax: 'Adormeci rápido e tranquilo'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adolescente_desafio_assertividade',
          title: '💬 Desafio da Assertividade',
          description: 'Praticar expressar uma opinião sincera ou dizer um "não" educado em uma interação de baixo risco.',
          category: 'cognitiva',
          categoryLabel: 'Cognitiva (TCC)',
          ageGroup: 'adolescente',
          ageGroupLabel: 'Adolescentes (12 a 17 anos)',
          protocol: 'Treino de Assertividade',
          difficultyLevel: 2,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual foi a situação onde você precisou se posicionar?', tipo: 'texto_longo', placeholder: 'Ex: Um amigo pediu para fazer o trabalho por ele ou me convidou para algo que eu não queria ir.'),
            TaskFormFieldConfig(ordem: 2, label: 'O que você disse (sua resposta assertiva)?', tipo: 'texto_longo', placeholder: 'Ex: "Valeu pelo convite, mas hoje preciso descansar."'),
            TaskFormFieldConfig(ordem: 3, label: 'Qual medo você sentiu antes e como foi o resultado real depois?', tipo: 'texto_longo', placeholder: 'Descreva a diferença entre a sua previsão negativa e o que realmente ocorreu...'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adolescente_mural_valores',
          title: '🌟 Mural dos Valores & Metas',
          description: 'Registrar e organizar metas de futuro, interesses pessoais, hobbies e o que realmente importa para você.',
          category: 'autonomia',
          categoryLabel: 'Autonomia & Gratidão',
          ageGroup: 'adolescente',
          ageGroupLabel: 'Adolescentes (12 a 17 anos)',
          protocol: 'Terapia de Aceitação e Compromisso (ACT)',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Quais são 3 valores ou coisas mais importantes na sua vida hoje?', tipo: 'texto_longo', placeholder: 'Ex: Lealdade com amigos, liberdade criativa, aprender coisas novas...'),
            TaskFormFieldConfig(ordem: 2, label: 'Qual meta ou sonho você gostaria de conquistar nos próximos meses?', tipo: 'texto_longo', placeholder: 'Descreva algo que você quer tentar ou aprender...'),
            TaskFormFieldConfig(ordem: 3, label: 'Que pequeno passo você pode dar esta semana nessa direção?', tipo: 'texto_longo', placeholder: 'Um passo simples e viável...'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adolescente_gatilhos_sociais',
          title: '📱 Identificação de Gatilhos nas Redes',
          description: 'Monitorar se postagens específicas em redes sociais dispararam sentimentos de inferioridade, FOMO ou ansiedade.',
          category: 'cognitiva',
          categoryLabel: 'Cognitiva (TCC)',
          ageGroup: 'adolescente',
          ageGroupLabel: 'Adolescentes (12 a 17 anos)',
          protocol: 'TCC - Reestruturação',
          difficultyLevel: 2,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual aplicativo ou tipo de publicação disparou o desconforto?', tipo: 'texto_longo', placeholder: 'Ex: Stories de uma festa que não fui, fotos de corpos perfeitos...'),
            TaskFormFieldConfig(ordem: 2, label: 'Qual foi o pensamento automático que surgiu?', tipo: 'texto_longo', placeholder: 'Ex: "A vida de todo mundo é mais legal que a minha" / "Eu não sou suficiente"'),
            TaskFormFieldConfig(ordem: 3, label: 'Qual é uma forma mais realista e justa de ver essa situação?', tipo: 'texto_longo', placeholder: 'Ex: "As pessoas só postam os melhores 1% da vida delas, ninguém posta as dificuldades."'),
          ],
        ),

        // --- ADULTOS (18 a 59 anos) ---
        CatalogTaskTemplate(
          id: 'adulto_rpd_digital',
          title: '🧠 RPD Digital (Registro de Pensamentos)',
          description: 'Registrar episódios de oscilação emocional divididos em: Situação, Pensamento Automático, Emoção e Resposta Racional.',
          category: 'cognitiva',
          categoryLabel: 'Cognitiva (TCC)',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos (18 a 59 anos)',
          protocol: 'TCC Clássica (RPD)',
          difficultyLevel: 2,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: '1. Situação (Onde você estava, com quem e o que aconteceu?)', tipo: 'texto_longo', placeholder: 'Ex: Meu gestor mandou mensagem pedindo uma reunião urgente.'),
            TaskFormFieldConfig(ordem: 2, label: '2. Pensamento Automático (O que passou pela sua cabeça exatamente?)', tipo: 'texto_longo', placeholder: 'Ex: "Fiz alguma besteira grave e serei demitido."'),
            TaskFormFieldConfig(ordem: 3, label: '3. Emoção predominante & Intensidade', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Leve desconforto)', labelMax: '10 (Pânico / Desespero)'),
            TaskFormFieldConfig(ordem: 4, label: '4. Resposta Racional / Pensamento Alternativo', tipo: 'texto_longo', placeholder: 'Ex: "Reuniões acontecem rotineiramente. Meu trabalho recente foi elogiado e não há evidências concretas de demissão."'),
            TaskFormFieldConfig(ordem: 5, label: '5. Intensidade da emoção após a reflexão', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Calmo / Centrado)', labelMax: '10 (Inalterado)'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adulto_prazer_maestria',
          title: '📊 Gráfico de Prazer e Maestria',
          description: 'Registrar atividades do dia avaliando de 0 a 10 os índices de satisfação/prazer (P) e senso de competência/maestria (M).',
          category: 'comportamental',
          categoryLabel: 'Comportamental',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos (18 a 59 anos)',
          protocol: 'Ativação Comportamental',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual atividade relevante você realizou?', tipo: 'texto_longo', placeholder: 'Ex: Concluí o relatório de vendas / Preparei uma refeição saudável / Fui caminhar'),
            TaskFormFieldConfig(ordem: 2, label: 'Nível de Prazer experimentado (0 = nenhum, 10 = máximo)', tipo: 'escala_linear', min: 0, max: 10, labelMin: '0 (Nenhum)', labelMax: '10 (Máximo prazer)'),
            TaskFormFieldConfig(ordem: 3, label: 'Nível de Maestria / Senso de Competência (0 = nenhum, 10 = alto domínio)', tipo: 'escala_linear', min: 0, max: 10, labelMin: '0 (Incompetente)', labelMax: '10 (Alto senso de conquista)'),
            TaskFormFieldConfig(ordem: 4, label: 'Reflexão sobre o impacto dessa atividade no seu humor:', tipo: 'texto_longo', placeholder: 'Como você se sentiu antes versus depois de finalizar?'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adulto_pausa_estruturada',
          title: '🧘 Pausa Estruturada & Respiração',
          description: 'Configurar dois alertas dedicados no dia para realizar 3 minutos de respiração diafragmática profunda.',
          category: 'mindfulness',
          categoryLabel: 'Mindfulness & Regulação',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos (18 a 59 anos)',
          protocol: 'Regulação Autonômica',
          difficultyLevel: 1,
          tipoInput: 'exercicio_guiado',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Em quais momentos do dia você realizou as pausas estruturadas?', tipo: 'texto_longo', placeholder: 'Ex: Às 11:00 após a reunião e às 16:30 no meio do expediente.'),
            TaskFormFieldConfig(ordem: 2, label: 'Nível de tensão física antes da pausa:', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Relaxado)', labelMax: '10 (Extrema tensão)'),
            TaskFormFieldConfig(ordem: 3, label: 'Nível de tensão física após os 3 minutos de respiração:', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Relaxado)', labelMax: '10 (Extrema tensão)'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adulto_experimento_comportamental',
          title: '🧪 Experimento Comportamental',
          description: 'Testar uma previsão negativa ou catastrófica em uma situação real e documentar o resultado empírico versus o esperado.',
          category: 'cognitiva',
          categoryLabel: 'Cognitiva (TCC)',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos (18 a 59 anos)',
          protocol: 'TCC - Teste Empírico',
          difficultyLevel: 3,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Crença ou previsão negativa que foi testada:', tipo: 'texto_longo', placeholder: 'Ex: "Se eu fizer uma pergunta na reunião, todos vão achar que sou incompetente."'),
            TaskFormFieldConfig(ordem: 2, label: 'Qual ação você realizou para testar essa crença?', tipo: 'texto_longo', placeholder: 'Ex: Levantei a mão e fiz uma pergunta sobre o novo cronograma.'),
            TaskFormFieldConfig(ordem: 3, label: 'O que realmente aconteceu (evidências observáveis)?', tipo: 'texto_longo', placeholder: 'Ex: O coordenador respondeu com naturalidade e dois colegas concordaram com a dúvida.'),
            TaskFormFieldConfig(ordem: 4, label: 'O que você concluiu a partir desse resultado?', tipo: 'texto_longo', placeholder: 'Qual foi o aprendizado para situações futuras?'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'adulto_circulo_controle',
          title: '🎯 Círculo de Controle',
          description: 'Listar os problemas estressores atuais e classificá-los entre "O que posso controlar" e "O que está fora do meu controle".',
          category: 'cognitiva',
          categoryLabel: 'Cognitiva (TCC)',
          ageGroup: 'adulto',
          ageGroupLabel: 'Adultos (18 a 59 anos)',
          protocol: 'Foco e Resolução de Problemas',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Quais fatores ou situações estão gerando ansiedade no momento?', tipo: 'texto_longo', placeholder: 'Liste os pontos de estresse...'),
            TaskFormFieldConfig(ordem: 2, label: '🟢 O que está DENTRO do seu controle direto em relação a isso?', tipo: 'texto_longo', placeholder: 'Minha reação, meu esforço, meus limites, minha comunicação...'),
            TaskFormFieldConfig(ordem: 3, label: '🔴 O que está TOTALMENTE FORA do seu controle?', tipo: 'texto_longo', placeholder: 'A reação dos outros, o trânsito, a economia, decisões de terceiros...'),
            TaskFormFieldConfig(ordem: 4, label: 'Qual ação concreta você escolhe focar hoje no que está ao seu alcance?', tipo: 'texto_longo', placeholder: 'Seu plano de ação direto...'),
          ],
        ),

        // --- IDOSOS (60+ anos) ---
        CatalogTaskTemplate(
          id: 'idoso_linha_tempo_gratidao',
          title: '📖 Linha do Tempo da Gratidão & Memória',
          description: 'Compartilhar um relato detalhado sobre uma memória feliz, conquista antiga ou história marcante da juventude.',
          category: 'autonomia',
          categoryLabel: 'Autonomia & Gratidão',
          ageGroup: 'idoso',
          ageGroupLabel: 'Idosos (60+ anos)',
          protocol: 'Terapia de Reminiscência',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual lembrança especial ou momento de orgulho veio à sua mente hoje?', tipo: 'texto_longo', placeholder: 'Conte a história desse dia, onde foi e quem estava lá...'),
            TaskFormFieldConfig(ordem: 2, label: 'Que ensinamento ou sentimento bom essa memória traz para a sua vida hoje?', tipo: 'texto_longo', placeholder: 'O que essa história diz sobre a sua força e trajetória?'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'idoso_ativacao_social',
          title: '📞 Ativação Social & Conexão',
          description: 'Realizar uma ligação telefônica ou enviar uma mensagem para um amigo, vizinho ou familiar querido.',
          category: 'comportamental',
          categoryLabel: 'Comportamental',
          ageGroup: 'idoso',
          ageGroupLabel: 'Idosos (60+ anos)',
          protocol: 'Ativação Social Geriátrica',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Com quem você conversou hoje?', tipo: 'texto_curto', placeholder: 'Nome da pessoa ou grau de parentesco / amizade'),
            TaskFormFieldConfig(ordem: 2, label: 'Sobre o que vocês conversaram e como foi a conversa?', tipo: 'texto_longo', placeholder: 'Compartilhe um pouco de como foi esse contato...'),
            TaskFormFieldConfig(ordem: 3, label: 'Como você se sentiu após a conversa?', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Ainda solitário)', labelMax: '10 (Acolhido e alegre)'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'idoso_caminhada_atenta',
          title: '🌳 Caminhada Atenta (Mindful)',
          description: 'Fazer um percurso curto ao ar livre focando na observação detalhada da natureza, sons e arquitetura do caminho.',
          category: 'mindfulness',
          categoryLabel: 'Mindfulness & Regulação',
          ageGroup: 'idoso',
          ageGroupLabel: 'Idosos (60+ anos)',
          protocol: 'Atenção Plena na Terceira Idade',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Por onde foi a sua caminhada e qual a duração aproximada?', tipo: 'texto_curto', placeholder: 'Ex: No jardim do prédio por 15 minutos / Na praça'),
            TaskFormFieldConfig(ordem: 2, label: 'Quais detalhes bonitos ou diferentes você notou pelo caminho?', tipo: 'texto_longo', placeholder: 'Flores, passarinhos, árvores, pessoas sorrindo...'),
            TaskFormFieldConfig(ordem: 3, label: 'Como seu corpo e sua respiração responderam ao passeio?', tipo: 'texto_longo', placeholder: 'Descreva a sensação física de vitalidade...'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'idoso_estimulacao_cognitiva',
          title: '🧩 Estimulação Cognitiva & Desafios',
          description: 'Completar um desafio de lógica, jogo de palavras cruzadas, caça-palavras ou leitura ativa no dia.',
          category: 'cognitiva',
          categoryLabel: 'Cognitiva (TCC)',
          ageGroup: 'idoso',
          ageGroupLabel: 'Idosos (60+ anos)',
          protocol: 'Treino Cognitivo',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual atividade de estímulo mental você realizou hoje?', tipo: 'selecao_unica', options: ['Palavras cruzadas / Caça-palavras', 'Sudoku / Jogo de números', 'Leitura de livro ou jornal', 'Jogo de tabuleiro / cartas com amigos', 'Outra atividade de memória']),
            TaskFormFieldConfig(ordem: 2, label: 'Quanto tempo você dedicou à atividade?', tipo: 'texto_curto', placeholder: 'Ex: 30 minutos'),
            TaskFormFieldConfig(ordem: 3, label: 'Como você avalia a sua concentração durante a atividade?', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Muita distração)', labelMax: '10 (Excelente foco)'),
          ],
        ),

        CatalogTaskTemplate(
          id: 'idoso_diario_autonomia',
          title: '🏆 Diário de Autonomia & Conquistas',
          description: 'Listar uma tarefa ou atividade diária realizada de forma 100% independente e comemorar o resultado.',
          category: 'autonomia',
          categoryLabel: 'Autonomia & Gratidão',
          ageGroup: 'idoso',
          ageGroupLabel: 'Idosos (60+ anos)',
          protocol: 'Fortalecimento da Autoeficácia',
          difficultyLevel: 1,
          tipoInput: 'formulario_multiplo',
          campos: [
            TaskFormFieldConfig(ordem: 1, label: 'Qual atividade você realizou hoje por conta própria?', tipo: 'texto_longo', placeholder: 'Ex: Arrumei minhas plantas, fiz compras no mercado, preparei meu café...'),
            TaskFormFieldConfig(ordem: 2, label: 'Qual a sensação de satisfação com essa conquista pessoal?', tipo: 'escala_linear', min: 1, max: 10, labelMin: '1 (Pouco)', labelMax: '10 (Muita satisfação)'),
          ],
        ),
      ];

  static List<CatalogTaskTemplate> getByAgeGroup(String ageGroup) {
    if (ageGroup == 'todas') return allTemplates;
    return allTemplates.where((t) => t.ageGroup == ageGroup || t.ageGroup == 'todas').toList();
  }

  static List<CatalogTaskTemplate> getByCategory(String category) {
    if (category == 'todas') return allTemplates;
    return allTemplates.where((t) => t.category == category).toList();
  }

  static List<CatalogTaskTemplate> filter({String? ageGroup, String? category}) {
    return allTemplates.where((t) {
      final matchAge = ageGroup == null || ageGroup == 'todas' || t.ageGroup == ageGroup || t.ageGroup == 'todas';
      final matchCat = category == null || category == 'todas' || t.category == category;
      return matchAge && matchCat;
    }).toList();
  }
}
