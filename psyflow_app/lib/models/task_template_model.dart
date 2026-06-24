/// Modelo de um modelo (template) de tarefa pronta para uso.
///
/// Diferente do [InterventionTemplate] (que já existe e é carregado do
/// Supabase para alimentar a Biblioteca de Intervenções), este modelo é
/// pensado para ser leve, 100% local/estático, e usado apenas para
/// pré-popular o formulário de criação de tarefa do psicólogo
/// (`_CreateTaskSheet`). Ele não precisa de tabela própria no banco —
/// quando o psicólogo escolhe um modelo, os campos são copiados para os
/// campos normais de `tasks` (title, description, category, protocol,
/// difficulty_level) e a tarefa criada é uma `TaskItem` comum.
class TaskTemplate {
  /// Identificador estável do modelo (não é um id de banco).
  final String id;

  /// Categoria temática, usada para os chips de filtro
  /// (ex.: 'foco_concentracao', 'tcc', 'depressao', 'ansiedade').
  final String category;

  /// Rótulo legível da categoria, para exibição na UI.
  final String categoryLabel;

  /// Título curto da tarefa (vai para `tasks.title`).
  final String title;

  /// Texto de apoio/instruções para o paciente (vai para `tasks.description`).
  final String description;

  /// Pergunta de reflexão a ser respondida pelo paciente ao concluir a
  /// tarefa. É opcional, e quando presente é anexada ao final da descrição.
  final String? reflectionQuestion;

  /// Nome curto do protocolo/abordagem de referência
  /// (vai para `tasks.protocol`), ex.: 'TCC', 'Ativação Comportamental'.
  final String protocol;

  /// 1 = fácil, 2 = médio, 3 = avançado.
  final int difficultyLevel;

  const TaskTemplate({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.title,
    required this.description,
    this.reflectionQuestion,
    required this.protocol,
    required this.difficultyLevel,
  });

  /// Descrição final, já incluindo a pergunta de reflexão (se houver),
  /// pronta para ser usada como `description` da tarefa.
  String get fullDescription {
    if (reflectionQuestion == null || reflectionQuestion!.isEmpty) {
      return description;
    }
    return '$description\n\nPara refletir: $reflectionQuestion';
  }
}