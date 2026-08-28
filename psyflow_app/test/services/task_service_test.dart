import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psyflow_app/core/services/task_service.dart';
import 'package:psyflow_app/repositories/task_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('TaskService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late FirestoreTaskRepository taskRepository;
    late TaskService taskService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('psych-1');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      taskRepository = FirestoreTaskRepository(firestore: fakeFirestore);
      taskService = TaskService(
        firestore: fakeFirestore,
        auth: mockAuth,
        taskRepository: taskRepository,
      );
    });

    test('createTask creates a task document in firestore', () async {
      await taskService.createTask(
        patientId: 'patient-1',
        title: 'Respiração Guiada',
        description: 'Fazer 5 minutos pela manhã',
        category: 'mindfulness',
        protocol: 'TCC',
        difficultyLevel: 1,
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      final snapshot = await fakeFirestore.collection('tasks').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['title'], 'Respiração Guiada');
      expect(data['patient_id'], 'patient-1');
      expect(data['psychologist_id'], 'psych-1');
      expect(data['status'], 'pending');
    });

    test('completeTask updates task with response and mood', () async {
      final docRef = await fakeFirestore.collection('tasks').add({
        'title': 'Registro de Pensamentos',
        'patient_id': 'patient-1',
        'psychologist_id': 'psych-1',
        'status': 'pending',
      });

      await taskService.completeTask(
        taskId: docRef.id,
        response: 'Consegui reestruturar o pensamento catastrófico.',
        moodBefore: 2,
        moodAfter: 4,
      );

      final updatedDoc = await docRef.get();
      final data = updatedDoc.data()!;
      expect(data['status'], 'completed');
      expect(data['patient_response'], 'Consegui reestruturar o pensamento catastrófico.');
      expect(data['mood_before'], 2);
      expect(data['mood_after'], 4);
    });

    test('toggleTaskStatus updates status correctly', () async {
      final docRef = await fakeFirestore.collection('tasks').add({
        'title': 'Diário de Sono',
        'status': 'pending',
      });

      await taskService.toggleTaskStatus(docRef.id, true);
      var doc = await docRef.get();
      expect(doc.data()!['status'], 'completed');

      await taskService.toggleTaskStatus(docRef.id, false);
      doc = await docRef.get();
      expect(doc.data()!['status'], 'pending');
    });

    test('saveTherapistNotes adds notes to task', () async {
      final docRef = await fakeFirestore.collection('tasks').add({
        'title': 'Exposição Gradual',
        'status': 'completed',
      });

      await taskService.saveTherapistNotes(
        taskId: docRef.id,
        notes: 'Excelente enfrentamento demonstrado.',
      );

      final doc = await docRef.get();
      expect(doc.data()!['therapist_notes'], 'Excelente enfrentamento demonstrado.');
    });

    test('deleteTask removes task from firestore', () async {
      final docRef = await fakeFirestore.collection('tasks').add({
        'title': 'Tarefa Temporária',
      });

      await taskService.deleteTask(docRef.id);
      final doc = await docRef.get();
      expect(doc.exists, isFalse);
    });
  });
}