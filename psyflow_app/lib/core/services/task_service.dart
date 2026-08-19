import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../models/task_item.dart';
import '../../core/errors/app_exception.dart';
import '../../repositories/task_repository.dart';

class TaskService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final TaskRepository _taskRepository;

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

  /// Psicólogo cria uma tarefa para um paciente
  Future<void> createTask({
    required String patientId,
    required String title,
    String? description,
    String? category,
    String? protocol,
    int difficultyLevel = 1,
    DateTime? dueDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
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
      });
    } catch (e) {
      throw AppException('Erro ao criar tarefa: $e', originalError: e);
    }
  }

  /// Psicólogo vê todas as tarefas que criou
  Future<List<TaskItem>> getTasksCreatedByMe() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
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
          patientNames[pid] = doc.data()?['full_name'] ?? doc.data()?['fullName'] ?? '';
        }
      }

      return tasks.map((t) {
        final pid = t['patient_id'] as String;
        return TaskItem.fromMap({...t, 'patient_name': patientNames[pid]});
      }).toList();
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  /// Psicólogo vê tarefas de um paciente específico
  Future<List<TaskItem>> getTasksForPatient(String patientId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('tasks')
          .where('psychologist_id', isEqualTo: user.uid)
          .where('patient_id', isEqualTo: patientId)
          .orderBy('due_date')
          .get();

      return snap.docs
          .map((d) => TaskItem.fromMap({'id': d.id, ...d.data()}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  /// Paciente vê suas próprias tarefas
  Future<List<TaskItem>> getMyTasks() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('tasks')
          .where('patient_id', isEqualTo: user.uid)
          .orderBy('due_date')
          .get();

      return snap.docs
          .map((d) => TaskItem.fromMap({'id': d.id, ...d.data()}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  /// Paciente conclui uma tarefa com resposta e humor
  Future<void> completeTask({
    required String taskId,
    required String response,
    required int moodBefore,
    required int moodAfter,
  }) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        'status': 'completed',
        'completed_at': FieldValue.serverTimestamp(),
        'patient_response': response,
        'mood_before': moodBefore,
        'mood_after': moodAfter,
      });
    } catch (e) {
      throw AppException('Erro ao concluir tarefa: $e', originalError: e);
    }
  }

  /// Paciente marca tarefa como concluída/pendente
  Future<void> toggleTaskStatus(String taskId, bool completed) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        'status': completed ? 'completed' : 'pending',
        'completed_at': completed ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      throw AppException('Erro ao atualizar tarefa: $e', originalError: e);
    }
  }

  /// Psicólogo exclui uma tarefa
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).delete();
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
      await _db.collection('tasks').doc(taskId).update({
        'therapist_notes': notes,
      });
    } catch (e) {
      throw AppException('Erro ao salvar anotação: $e', originalError: e);
    }
  }
}