import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/task_catalog.dart';

class TaskItem {
  final String id;
  final String taskId;
  final String patientId;
  final String psychologistId;
  final String title;
  final String? description;
  final String category;
  final String protocol;
  final int difficultyLevel;
  final String status;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final String? patientResponse;
  final String? therapistNotes;
  final int? moodBefore;
  final int? moodAfter;
  final String? patientName;
  final int order;

  // Novos campos estruturados conforme tarefas.md
  final String faixaEtaria; // 'Criança', 'Adolescente', 'Adulto', 'Idoso', 'Todas'
  final Map<String, dynamic>? configuracoes; // permite_notificacao, frequencia_lembrete, horario_lembrete, compartilhamento
  final Map<String, dynamic>? estruturaResposta; // tipo_input, campos: [{ordem, label, tipo, ...}]
  final Map<String, dynamic>? respostaPaciente; // enviada_em, valores: {...}, is_draft: bool

  TaskItem({
    required this.id,
    required this.taskId,
    required this.patientId,
    required this.psychologistId,
    required this.title,
    this.description,
    required this.category,
    required this.protocol,
    required this.difficultyLevel,
    required this.status,
    this.dueDate,
    this.createdAt,
    this.completedAt,
    this.patientResponse,
    this.therapistNotes,
    this.moodBefore,
    this.moodAfter,
    this.patientName,
    this.order = 0,
    this.faixaEtaria = 'Adulto',
    this.configuracoes,
    this.estruturaResposta,
    this.respostaPaciente,
  });

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return TaskItem(
      id: (map['id'] ?? '') as String,
      taskId: (map['task_id'] ?? map['id_tarefa'] ?? '') as String,
      patientId: (map['patient_id'] ?? map['id_paciente'] ?? '') as String,
      psychologistId: (map['psychologist_id'] ?? map['id_psicologo'] ?? '') as String,
      title: (map['title'] ?? map['titulo'] ?? '') as String,
      description: map['description'] as String? ?? map['descricao'] as String?,
      category: map['category'] as String? ?? map['categoria'] as String? ?? 'geral',
      protocol: map['protocol'] as String? ?? '',
      difficultyLevel: (map['difficulty_level'] as num?)?.toInt() ?? 1,
      status: map['status'] as String? ?? 'pending',
      dueDate: parseNullableDate(map['due_date'] ?? map['prazo_entrega']),
      createdAt: parseNullableDate(map['created_at'] ?? map['data_criacao']),
      completedAt: parseNullableDate(map['completed_at']),
      patientResponse: map['patient_response'] as String?,
      therapistNotes: map['therapist_notes'] as String?,
      moodBefore: (map['mood_before'] as num?)?.toInt(),
      moodAfter: (map['mood_after'] as num?)?.toInt(),
      patientName: map['patient_name'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
      faixaEtaria: (map['faixa_etaria'] ?? map['faixaEtaria'] ?? 'Adulto') as String,
      configuracoes: map['configuracoes'] as Map<String, dynamic>?,
      estruturaResposta: map['estrutura_resposta'] as Map<String, dynamic>?,
      respostaPaciente: map['resposta_paciente'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'patient_id': patientId,
      'psychologist_id': psychologistId,
      'title': title,
      'description': description,
      'category': category,
      'protocol': protocol,
      'difficulty_level': difficultyLevel,
      'status': status,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'patient_response': patientResponse,
      'therapist_notes': therapistNotes,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'order': order,
      'faixa_etaria': faixaEtaria,
      'configuracoes': configuracoes,
      'estrutura_resposta': estruturaResposta,
      'resposta_paciente': respostaPaciente,
    };
  }

  TaskItem copyWith({
    String? id,
    String? taskId,
    String? patientId,
    String? psychologistId,
    String? title,
    String? description,
    String? category,
    String? protocol,
    int? difficultyLevel,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    String? patientResponse,
    String? therapistNotes,
    int? moodBefore,
    int? moodAfter,
    String? patientName,
    int? order,
    String? faixaEtaria,
    Map<String, dynamic>? configuracoes,
    Map<String, dynamic>? estruturaResposta,
    Map<String, dynamic>? respostaPaciente,
  }) {
    return TaskItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      patientId: patientId ?? this.patientId,
      psychologistId: psychologistId ?? this.psychologistId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      protocol: protocol ?? this.protocol,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      patientResponse: patientResponse ?? this.patientResponse,
      therapistNotes: therapistNotes ?? this.therapistNotes,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      patientName: patientName ?? this.patientName,
      order: order ?? this.order,
      faixaEtaria: faixaEtaria ?? this.faixaEtaria,
      configuracoes: configuracoes ?? this.configuracoes,
      estruturaResposta: estruturaResposta ?? this.estruturaResposta,
      respostaPaciente: respostaPaciente ?? this.respostaPaciente,
    );
  }

  bool get isCompleted => status == 'completed';

  bool get isDraft => (respostaPaciente?['is_draft'] as bool?) == true;

  bool get isOverdue {
    if (dueDate == null) return false;
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Lista de campos do formulário dinâmico
  List<TaskFormFieldConfig> get formFields {
    if (estruturaResposta == null) return [];
    final rawFields = estruturaResposta!['campos'] as List<dynamic>?;
    if (rawFields == null) return [];
    return rawFields.map((f) => TaskFormFieldConfig.fromMap(f as Map<String, dynamic>)).toList();
  }

  /// Tipo de formulário
  String get tipoInput => (estruturaResposta?['tipo_input'] ?? 'formulario_multiplo') as String;

  /// Modo de compartilhamento
  String get sharingMode => (configuracoes?['compartilhamento'] ?? 'automatico') as String;

  bool get isSessionRestricted => sharingMode == 'sessao_presencial';

  /// Valores salvos pelo paciente
  Map<String, dynamic> get patientValues {
    if (respostaPaciente == null) return {};
    final val = respostaPaciente!['valores'];
    if (val is Map<String, dynamic>) return val;
    if (val is Map) return Map<String, dynamic>.from(val);
    return {};
  }
}