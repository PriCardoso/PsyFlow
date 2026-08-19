import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_item.dart';
import '../../core/errors/app_exception.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasksForPatient(String patientId);
  Future<List<TaskItem>> getTasksCreatedByProfessional(String professionalId);
  Future<void> updateTaskStatus(String taskId, String status, {String? patientNotes, String? attachmentUrl});
  Future<void> deleteTask(String taskId);
  Stream<List<TaskItem>> streamTasksForPatient(String patientId);
  Stream<List<TaskItem>> streamTasksForProfessional(String professionalId);

  // Pagination support
  Future<List<TaskItem>> getTasksForPatientPaginated({
    required String patientId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
  Future<List<TaskItem>> getTasksCreatedByProfessionalPaginated({
    required String professionalId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
}

class FirestoreTaskRepository implements TaskRepository {
  final FirebaseFirestore _db;

  FirestoreTaskRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  @override
  Future<List<TaskItem>> getTasksForPatient(String patientId) async {
    try {
      final snap = await _db
          .collection('tasks')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs
          .map((d) => TaskItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  @override
  Future<List<TaskItem>> getTasksCreatedByProfessional(String professionalId) async {
    try {
      final snap = await _db
          .collection('tasks')
          .where('psychologist_id', isEqualTo: professionalId)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs
          .map((d) => TaskItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  @override
  Future<void> updateTaskStatus(
    String taskId,
    String status, {
    String? patientNotes,
    String? attachmentUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (status == 'completed') {
        updates['completed_at'] = FieldValue.serverTimestamp();
      }
      if (patientNotes != null) updates['patient_notes'] = patientNotes;
      if (attachmentUrl != null) updates['attachment_url'] = attachmentUrl;

      await _db.collection('tasks').doc(taskId).update(updates);
    } catch (e) {
      throw AppException('Erro ao atualizar tarefa: $e', originalError: e);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw AppException('Erro ao excluir tarefa: $e', originalError: e);
    }
  }

  @override
  Stream<List<TaskItem>> streamTasksForPatient(String patientId) {
    return _db
        .collection('tasks')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TaskItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
            .toList());
  }

  @override
  Stream<List<TaskItem>> streamTasksForProfessional(String professionalId) {
    return _db
        .collection('tasks')
        .where('psychologist_id', isEqualTo: professionalId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TaskItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
            .toList());
  }

  @override
  Future<List<TaskItem>> getTasksForPatientPaginated({
    required String patientId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection('tasks')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();
      return snap.docs
          .map((d) => TaskItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }

  @override
  Future<List<TaskItem>> getTasksCreatedByProfessionalPaginated({
    required String professionalId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection('tasks')
          .where('psychologist_id', isEqualTo: professionalId)
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();
      return snap.docs
          .map((d) => TaskItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar tarefas: $e', originalError: e);
    }
  }
}