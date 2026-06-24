import '../models/task_template_model.dart';

/// Catálogo estático de modelos de tarefa pronta para o psicólogo enviar
/// ao paciente. O conteúdo foi escrito originalmente para o PsyFlow,
/// inspirado em temas e técnicas amplamente usados em TCC e no manejo de
/// TDAH/foco (reestruturação cognitiva, ativação comportamental,
/// aterramento sensorial, exposição gradual) — sem reproduzir texto de
/// nenhum material de terceiros.
///
/// Para adicionar um novo modelo, basta incluir uma nova entrada na lista
/// abaixo. A tela de criação de tarefa lê esta lista automaticamente.
class TaskTemplates {
  TaskTemplates._();

  static const String catFoco = 'foco_concentracao';
  static const String catTcc = 'tcc';
  static const String catAnsiedade = 'ansiedade';
  static const String catDepressao = 'depressao';

  static const Map<String, String> categoryLabels = {
    catFoco: 'Foco e Concentração',
    catTcc: 'TCC',
    catAnsiedade: 'Ansiedade',
    catDepressao: 'Depressão',
  };

  static List<TaskTemplate> get all => [
        ..._focoConcentracao,
        ..._tcc,
        ..._ansiedade,
        ..._depressao,
      ];

  // ---------------------------------------------------------------------
  // FOCO E CONCENTRAÇÃO (TDAH adulto)
  // 16 situações comuns de dificuldade de foco, cada uma com uma
  // estratégia prática e uma pergunta de reflexão para o paciente
  // registrar o que funcionou.
  // ---------------------------------------------------------------------
  static final List<TaskTemplate> _focoConcentracao = [
    TaskTemplate(
      id: 'foco_redes_sociais',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Reduzir a distração das redes sociais',
      description:
          'Instale um bloqueador de aplicativos ou de sites e defina horários '
          'fixos do dia para checar suas redes sociais, em vez de checá-las a '
          'qualquer momento. Experimente isso por alguns dias antes de avaliar.',
      reflectionQuestion:
          'Essa estratégia ajudou a manter o foco? O que você notou de '
          'diferente? Existe alguma variação dela que funcionaria ainda melhor '
          'para você?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_televisao',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Eliminar a TV como distração',
      description:
          'Durante o tempo que você reservar para estudar ou trabalhar, '
          'desligue a televisão ou, se possível, retire-a do ambiente. O '
          'objetivo é remover a tentação antes que ela apareça.',
      reflectionQuestion:
          'Você notou diferença na sua capacidade de manter o foco sem a TV '
          'ligada? Alguma outra mudança no ambiente ajudaria ainda mais?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_celular',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Diminuir as interrupções do celular',
      description:
          'Coloque o celular em modo silencioso ou deixe-o em outro cômodo '
          'enquanto realiza uma tarefa que exige concentração. Desative '
          'notificações que não sejam essenciais.',
      reflectionQuestion:
          'Como foi trabalhar sem as notificações por perto? Você sentiu '
          'vontade de checar o celular mesmo assim? Em que momentos?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_jogos_online',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Definir horários para jogos online',
      description:
          'Escolha horários específicos do dia para jogar e evite acessar '
          'jogos durante o período reservado para trabalho ou estudo. Tente '
          'manter esse limite por uma semana.',
      reflectionQuestion:
          'Foi fácil ou difícil respeitar o horário definido? O que ajudou (ou '
          'dificultou) cumprir esse limite?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_conversas_prolongadas',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Evitar conversas longas em momentos de tarefa',
      description:
          'Quando tiver tarefas pendentes, evite iniciar conversas que possam '
          'se prolongar. Se possível, combine com a outra pessoa um horário '
          'melhor para conversar com calma.',
      reflectionQuestion:
          'Você conseguiu adiar a conversa sem se sentir mal por isso? Como foi '
          'essa experiência?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_tarefas_excessivas',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Organizar tarefas em excesso',
      description:
          'Escolha apenas uma tarefa por vez. Liste suas prioridades do dia e '
          'trabalhe em uma delas até concluir, depois divida as próximas em '
          'etapas menores e mais fáceis de gerenciar.',
      reflectionQuestion:
          'Concentrar-se em uma tarefa por vez mudou sua sensação de '
          'sobrecarga? O que mais ajudaria a organizar o seu dia?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_estimulos_externos',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Reduzir estímulos externos no ambiente',
      description:
          'Organize um espaço de trabalho ou estudo calmo, com o mínimo de '
          'distrações visuais possível. Se sons externos forem um problema, '
          'experimente usar fones com cancelamento de ruído ou ruído branco.',
      reflectionQuestion:
          'O ambiente mais silencioso/organizado fez diferença na sua '
          'concentração? O que mais você poderia ajustar no espaço?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_esquecimento',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Criar lembretes para evitar esquecimentos',
      description:
          'Use post-its, alarmes ou aplicativos de lembrete para tarefas '
          'importantes do dia. Tente também criar uma pequena rotina diária '
          'fixa para reduzir a chance de esquecer compromissos.',
      reflectionQuestion:
          'Os lembretes ajudaram a diminuir os esquecimentos? Qual tipo de '
          'lembrete funcionou melhor para você?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_hiperfoco',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Lidar com episódios de hiperfoco',
      description:
          'Programe um alarme para lembrar de fazer pausas regulares mesmo '
          'quando estiver absorvido em uma atividade. Use a pausa para se '
          'alongar, beber água ou simplesmente desviar o olhar da tela.',
      reflectionQuestion:
          'Foi difícil parar quando o alarme tocou? Como você se sentiu depois '
          'da pausa?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_impulsividade',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Pausar antes de agir por impulso',
      description:
          'Antes de tomar uma decisão rápida, pare por alguns segundos e '
          'reflita sobre as possíveis consequências. Praticar mindfulness '
          'no dia a dia pode ajudar a aumentar essa pausa entre impulso e ação.',
      reflectionQuestion:
          'Você conseguiu notar o momento antes de agir por impulso? O que '
          'ajudou você a fazer essa pausa?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 3,
    ),
    TaskTemplate(
      id: 'foco_desorganizacao',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Reduzir a desorganização do dia a dia',
      description:
          'Use listas de tarefas, agenda ou um aplicativo de organização '
          'para acompanhar seus compromissos. Reserve um tempo fixo na semana '
          'só para organizar seu espaço.',
      reflectionQuestion:
          'A lista/agenda ajudou a se sentir mais no controle? O que ainda '
          'precisa de ajuste no seu sistema de organização?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_leitura',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Manter o foco durante a leitura',
      description:
          'Use marcadores ou grife trechos enquanto lê para se manter '
          'engajado com o texto. Defina uma meta pequena e alcançável, como '
          'ler algumas páginas por dia, em vez de um objetivo muito amplo.',
      reflectionQuestion:
          'Marcar o texto ajudou a manter a atenção na leitura? Como foi '
          'cumprir a meta de páginas que você definiu?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_inquietacao_fisica',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Acolher a inquietação física',
      description:
          'Inclua na sua rotina técnicas de relaxamento, como respiração '
          'diafragmática ou meditação breve, e procure manter alguma '
          'atividade física regular ao longo da semana.',
      reflectionQuestion:
          'Você notou alguma mudança na sensação de inquietação após praticar '
          'a respiração ou se exercitar? O que funcionou melhor?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_interromper',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Praticar a escuta sem interromper',
      description:
          'Na próxima conversa importante, experimente dar atenção total à '
          'outra pessoa, manter contato visual, evitar interromper e fazer '
          'perguntas que ajudem a entender melhor o que ela está dizendo.',
      reflectionQuestion:
          'Como foi tentar não interromper? Em que momento foi mais difícil se '
          'conter, e o que ajudaria nessa hora?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 3,
    ),
    TaskTemplate(
      id: 'foco_tarefas_domesticas',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Organizar as tarefas domésticas',
      description:
          'Crie um cronograma simples distribuindo as tarefas de casa pelos '
          'dias da semana, em vez de tentar fazer tudo de uma vez. Comece com '
          'poucas tarefas por dia e ajuste conforme a necessidade.',
      reflectionQuestion:
          'Distribuir as tarefas ao longo da semana tornou tudo mais leve? O '
          'que você ajustaria no cronograma?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_compras_online',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Evitar compras por impulso',
      description:
          'Defina um limite de gastos para compras online e, antes de '
          'finalizar uma compra não planejada, espere pelo menos dois dias '
          'após ver o anúncio ou pesquisar o produto.',
      reflectionQuestion:
          'A pausa de dois dias mudou sua decisão em alguma compra? Como foi '
          'esperar antes de comprar?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_procrastinacao',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Reduzir a procrastinação com o método pomodoro',
      description:
          'Divida uma tarefa que você vem evitando em blocos curtos de tempo '
          '(por exemplo, 25 minutos de foco seguidos de uma pausa de 5 '
          'minutos). Use um lembrete e planeje uma pequena recompensa ao final.',
      reflectionQuestion:
          'Dividir a tarefa em blocos curtos ajudou a começar? Quanto tempo '
          'você conseguiu manter o foco em cada bloco?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_comer_em_excesso',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Praticar a alimentação com atenção plena',
      description:
          'Estabeleça horários regulares para as refeições e, ao comer, '
          'evite distrações como celular ou TV. Coma devagar, preste atenção '
          'ao sabor da comida e pare quando perceber que já está satisfeito.',
      reflectionQuestion:
          'Comer sem distrações mudou a forma como você percebeu a fome e a '
          'saciedade? O que foi mais difícil de manter?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'foco_assistir_filme',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Manter o foco ao assistir a um filme',
      description:
          'Experimente ativar as legendas ao assistir a um filme ou série: '
          'ler o texto ajuda a manter a atenção presa à narrativa e reduz a '
          'dispersão.',
      reflectionQuestion:
          'As legendas ajudaram a acompanhar melhor a história? Você se '
          'distraiu menos do que de costume?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'foco_cafe_em_excesso',
      category: catFoco,
      categoryLabel: categoryLabels[catFoco]!,
      title: 'Reduzir o consumo excessivo de café',
      description:
          'Tente diminuir gradualmente a quantidade de cafeína consumida ao '
          'longo do dia e evite tomar café após as 15h, observando se isso '
          'melhora a qualidade do seu sono e da sua concentração.',
      reflectionQuestion:
          'Você percebeu alguma diferença no sono ou na disposição depois de '
          'reduzir a cafeína no fim do dia?',
      protocol: 'TCC - TDAH',
      difficultyLevel: 1,
    ),
  ];

  // ---------------------------------------------------------------------
  // TCC GERAL
  // ---------------------------------------------------------------------
  static final List<TaskTemplate> _tcc = [
    TaskTemplate(
      id: 'tcc_custo_beneficio',
      category: catTcc,
      categoryLabel: categoryLabels[catTcc]!,
      title: 'Análise de custo-benefício de um pensamento',
      description:
          'Escolha um pensamento ou crença negativa recorrente. Liste as '
          'vantagens e desvantagens de manter essa crença, depois liste os '
          'custos e os benefícios dela na sua vida. Avalie qual lado pesa '
          'mais e pense em uma crença alternativa que seja mais equilibrada.',
      reflectionQuestion:
          'Olhando para os custos e benefícios lado a lado, o que mais chamou '
          'sua atenção? Qual seria uma crença alternativa mais realista?',
      protocol: 'TCC',
      difficultyLevel: 2,
    ),
  ];

  // ---------------------------------------------------------------------
  // ANSIEDADE
  // ---------------------------------------------------------------------
  static final List<TaskTemplate> _ansiedade = [
    TaskTemplate(
      id: 'ansiedade_grounding_54321',
      category: catAnsiedade,
      categoryLabel: categoryLabels[catAnsiedade]!,
      title: 'Técnica de aterramento 5-4-3-2-1',
      description:
          'Em um momento de ansiedade, observe ao seu redor e identifique: 5 '
          'coisas que você consegue ver, 4 coisas que você consegue tocar, 3 '
          'coisas que você consegue ouvir, 2 coisas que você consegue cheirar '
          'e 1 coisa que você consegue saborear. Faça isso com calma, sem '
          'pressa.',
      reflectionQuestion:
          'Em que situação você usou essa técnica? Seu nível de ansiedade '
          'mudou depois do exercício?',
      protocol: 'TCC - Ansiedade',
      difficultyLevel: 1,
    ),
    TaskTemplate(
      id: 'ansiedade_plano_enfrentamento_medos',
      category: catAnsiedade,
      categoryLabel: categoryLabels[catAnsiedade]!,
      title: 'Construir um plano de enfrentamento de medos',
      description:
          'Pense em situações que você evita por medo ou ansiedade e liste-as. '
          'Avalie o nível de ansiedade de cada uma, de 0 a 10. Escolha a '
          'situação com o nível mais baixo e transforme-a em uma meta clara, '
          'realista e mensurável. Depois, organize um passo a passo, do mais '
          'fácil ao mais difícil, para enfrentá-la gradualmente.',
      reflectionQuestion:
          'Qual situação você escolheu para começar? Que primeiro passo, '
          'pequeno e concreto, você consegue dar esta semana?',
      protocol: 'TCC - Exposição Gradual',
      difficultyLevel: 3,
    ),
  ];

  // ---------------------------------------------------------------------
  // DEPRESSÃO
  // ---------------------------------------------------------------------
  static final List<TaskTemplate> _depressao = [
    TaskTemplate(
      id: 'depressao_ativacao_comportamental',
      category: catDepressao,
      categoryLabel: categoryLabels[catDepressao]!,
      title: 'Diário de ativação comportamental',
      description:
          'Durante uma semana, registre suas atividades diárias, incluindo as '
          'mais simples. Para cada período do dia, anote uma nota de humor de '
          '0 (muito ruim) a 10 (muito bom). Ao final da semana, observe quais '
          'atividades melhoraram seu humor, quais pioraram, e quais te '
          'fizeram sentir mais conectado com outras pessoas.',
      reflectionQuestion:
          'Que atividades mais melhoraram seu humor durante a semana? O que '
          'você notou sobre a relação entre o que faz e como se sente?',
      protocol: 'Ativação Comportamental',
      difficultyLevel: 2,
    ),
    TaskTemplate(
      id: 'depressao_atividades_perdidas',
      category: catDepressao,
      categoryLabel: categoryLabels[catDepressao]!,
      title: 'Recuperando atividades que traziam prazer',
      description:
          'Liste atividades que te traziam alegria há 1 ano, há 3 anos e há 5 '
          'anos, mas que você deixou de fazer. Avalie cada uma quanto ao nível '
          'de prazer que ela trazia, de 0 a 10. Pense nos motivos reais que '
          'fizeram você parar e em formas possíveis de retomar ou adaptar '
          'alguma dessas atividades hoje.',
      reflectionQuestion:
          'Qual dessas atividades você sentiria mais vontade de retomar? O '
          'que poderia te ajudar a dar o primeiro passo nessa direção?',
      protocol: 'Ativação Comportamental',
      difficultyLevel: 2,
    ),
  ];
}