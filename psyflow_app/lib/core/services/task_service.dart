import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../models/task_item.dart';
import '../../core/errors/app_exception.dart';
import '../../repositories/task_repository.dart';
import '../../core/utils/retry.dart';

class TaskService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final TaskRepository _taskRepository;

  TaskRepository get taskRepository => _taskRepository;

  TaskService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required TaskRepository taskRepository,
  })  : _db = firestore,
        _auth = auth,
        _taskRepository = taskRepository;

  /// Stream de tarefas para um paciente (tempo real)
  Stream<List<TaskItem>> tasksStreamForPatient(String patientId) {
    return _db
        .collection('tasks')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('due_date')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TaskItem.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  /// Stream de tarefas para um psicólogo (tempo real)
  Stream<List<TaskItem>> tasksStreamForPsychologist(String psychologistId) {
    return _db
        .collection('tasks')
        .where('psychologist_id', isEqualTo: psychologistId)
        .orderBy('due_date')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TaskItem.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  /// Psicólogo cria uma tarefa para um paciente com suporte a formulário dinâmico
  Future<void> createTask({
    required String patientId,
    required String title,
    String? description,
    String? category,
    String? protocol,
    int difficultyLevel = 1,
    DateTime? dueDate,
    String faixaEtaria = 'Adulto',
    Map<String, dynamic>? configuracoes,
    Map<String, dynamic>? estruturaResposta,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      await retry(() async {
        await _db.collection('tasks').add({
          'psychologist_id': user.uid,
          'patient_id': patientId,
          'title': title,
          'description': description,
          'category': category ?? 'geral',
          'protocol': protocol ?? '',
          'difficulty_level': difficultyLevel,
          'status': 'pending',
          'due_date': dueDate != null ? Timestamp.fromDate(dueDate) : null,
          'created_at': FieldValue.serverTimestamp(),
          'completed_at': null,
          'patient_response': null,
          'therapist_notes': null,
          'mood_before': null,
          'mood_after': null,
          'faixa_etaria': faixaEtaria,
          'configuracoes': configuracoes ?? {
            'permite_notificacao': true,
            'frequencia_lembrete': 'diario',
            'horario_lembrete': '20:00',
            'compartilhamento': 'automatico',
          },
          'estrutura_resposta': estruturaResposta,
          'resposta_paciente': null,
        });
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao criar tarefa: $e', originalError: e);
    }
  }

  /// Psicólogo vê todas as tarefas que criou
  Future<List<TaskItem>> getTasksCreatedByMe() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      return await retry(() async {
        final snap = await _db
            .collection('tasks')
            .where('psychologist_id', isEqualTo: user.uid)
            .orderBy('due_date')
            .get();

        final tasks = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        final patientIds = tasks.map((t) => t['patient_id'] as String).toSet();

        final patientNames = <String, String>{};
        for (final pid in patientIds) {
          final doc = await _db.collection('users').doc(pid).get();
          if (doc.exists) {
            final data = doc.data()!;
            patientNames[pid] = (data['full_name'] ?? data['fullName'] ?? data['name'] ?? '') as String;
          }
        }

        return tasks.map((t) {
          final pid = t['patient_id'] as String;
          return TaskItem.fromMap({...t, 'patient_name': patientNames[pid]});
        }).toList();
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  /// Psicólogo vê tarefas de um paciente específico
  Future<List<TaskItem>> getTasksForPatient(String patientId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      return await retry(() async {
        final snap = await _db
            .collection('tasks')
            .where('psychologist_id', isEqualTo: user.uid)
            .where('patient_id', isEqualTo: patientId)
            .orderBy('due_date')
            .get();

        return snap.docs
            .map((d) => TaskItem.fromMap({'id': d.id, ...d.data()}))
            .toList();
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  /// Paciente vê suas próprias tarefas
  Future<List<TaskItem>> getMyTasks() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      return await retry(() async {
        final snap = await _db
            .collection('tasks')
            .where('patient_id', isEqualTo: user.uid)
            .orderBy('due_date')
            .get();

        return snap.docs
            .map((d) => TaskItem.fromMap({'id': d.id, ...d.data()}))
            .toList();
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  /// Paciente salva rascunho de uma tarefa para retomar depois
  Future<void> saveDraftTask({
    required String taskId,
    required Map<String, dynamic> formValues,
    int? moodBefore,
  }) async {
    try {
      await retry(() async {
        await _db.collection('tasks').doc(taskId).update({
          'mood_before': moodBefore,
          'resposta_paciente': {
            'enviada_em': null,
            'valores': formValues,
            'is_draft': true,
          },
        });
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao salvar rascunho: $e', originalError: e);
    }
  }

  /// Paciente conclui tarefa enviando o formulário preenchido
  Future<void> completeTaskWithForm({
    required String taskId,
    required Map<String, dynamic> formValues,
    String? textSummary,
    int? moodBefore,
    int? moodAfter,
  }) async {
    try {
      await retry(() async {
        await _db.collection('tasks').doc(taskId).update({
          'status': 'completed',
          'completed_at': FieldValue.serverTimestamp(),
          'patient_response': textSummary,
          'mood_before': moodBefore,
          'mood_after': moodAfter,
          'resposta_paciente': {
            'enviada_em': FieldValue.serverTimestamp(),
            'valores': formValues,
            'is_draft': false,
          },
        });
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao concluir tarefa: $e', originalError: e);
    }
  }

  /// Paciente conclui uma tarefa clássica com resposta e humor
  Future<void> completeTask({
    required String taskId,
    required String response,
    required int moodBefore,
    required int moodAfter,
  }) async {
    try {
      await retry(() async {
        await _db.collection('tasks').doc(taskId).update({
          'status': 'completed',
          'completed_at': FieldValue.serverTimestamp(),
          'patient_response': response,
          'mood_before': moodBefore,
          'mood_after': moodAfter,
          'resposta_paciente': {
            'enviada_em': FieldValue.serverTimestamp(),
            'valores': {'resposta': response},
            'is_draft': false,
          },
        });
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao concluir tarefa: $e', originalError: e);
    }
  }

  /// Paciente marca tarefa como concluída/pendente
  Future<void> toggleTaskStatus(String taskId, bool completed) async {
    try {
      await retry(() async {
        await _db.collection('tasks').doc(taskId).update({
          'status': completed ? 'completed' : 'pending',
          'completed_at': completed ? FieldValue.serverTimestamp() : null,
        });
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao atualizar tarefa: $e', originalError: e);
    }
  }

  /// Psicólogo exclui uma tarefa
  Future<void> deleteTask(String taskId) async {
    try {
      await retry(() async {
        await _db.collection('tasks').doc(taskId).delete();
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao excluir tarefa: $e', originalError: e);
    }
  }

  /// Psicólogo salva anotação clínica sobre a resposta do paciente
  Future<void> saveTherapistNotes({
    required String taskId,
    required String notes,
  }) async {
    try {
      await retry(() async {
        await _db.collection('tasks').doc(taskId).update({
          'therapist_notes': notes,
        });
      }, retries: 3, initialDelay: const Duration(milliseconds: 300));
    } catch (e) {
      throw AppException('Erro ao salvar anotação: $e', originalError: e);
    }
  }
}