import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_item.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasksForPatient(String patientId);
  Future<List<TaskItem>> getTasksCreatedByProfessional(String professionalId);
  Future<void> updateTaskStatus(String taskId, String status, {String? patientNotes, String? attachmentUrl});
  Future<void> deleteTask(String taskId);
  Stream<List<TaskItem>> streamTasksForPatient(String patientId);
}

class FirestoreTaskRepository implements TaskRepository {
  final FirebaseFirestore _db;

  FirestoreTaskRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<TaskItem>> getTasksForPatient(String patientId) async {
    final snap = await _db
        .collection('tasks')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => TaskItem.fromMap({'id': d.id, ...d.data()})).toList();
  }

  @override
  Future<List<TaskItem>> getTasksCreatedByProfessional(String professionalId) async {
    final snap = await _db
        .collection('tasks')
        .where('psychologist_id', isEqualTo: professionalId)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => TaskItem.fromMap({'id': d.id, ...d.data()})).toList();
  }

  @override
  Future<void> updateTaskStatus(
    String taskId,
    String status, {
    String? patientNotes,
    String? attachmentUrl,
  }) async {
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
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  @override
  Stream<List<TaskItem>> streamTasksForPatient(String patientId) {
    return _db
        .collection('tasks')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskItem.fromMap({'id': d.id, ...d.data()})).toList());
  }
}
