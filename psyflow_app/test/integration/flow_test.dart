import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psyflow_app/core/services/invite_service.dart';
import 'package:psyflow_app/core/services/task_service.dart';
import 'package:psyflow_app/core/services/mood_service.dart';
import 'package:psyflow_app/repositories/task_repository.dart';
import 'package:psyflow_app/repositories/patient_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('Integration Flow: Convite -> Paciente -> Tarefa -> Humor', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late InviteService inviteService;
    late TaskService taskService;
    late MoodService moodService;
    late PatientRepository patientRepository;

    const psychUid = 'psychologist-uid-100';
    const patientUid = 'patient-uid-200';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn(psychUid);
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      inviteService = InviteService(firestore: fakeFirestore, auth: mockAuth);
      final taskRepo = FirestoreTaskRepository(firestore: fakeFirestore);
      taskService = TaskService(
        firestore: fakeFirestore,
        auth: mockAuth,
        taskRepository: taskRepo,
      );
      moodService = MoodService(firestore: fakeFirestore, auth: mockAuth);
      patientRepository = FirestorePatientRepository(firestore: fakeFirestore);
    });

    test('Complete clinical lifecycle flow executes seamlessly', () async {
      // 1. Setup user records in Firestore
      await fakeFirestore.collection('users').doc(psychUid).set({
        'full_name': 'Dr. Marcos Paulo',
        'role': 'psychologist',
        'email': 'dr.marcos@psyflow.com',
      });

      await fakeFirestore.collection('users').doc(patientUid).set({
        'full_name': 'Ana Beatriz',
        'role': 'patient',
        'email': 'ana.beatriz@email.com',
      });

      // 2. Psychologist creates invitation
      when(() => mockUser.uid).thenReturn(psychUid);
      final inviteCode = await inviteService.generateInvite();
      expect(inviteCode, isNotEmpty);

      // 3. Patient uses invitation code to link with psychologist
      when(() => mockUser.uid).thenReturn(patientUid);
      await inviteService.useInvite(inviteCode);

      // Verify link in PatientRepository
      final patientLink = await patientRepository.getProfessionalForPatient(patientUid);
      expect(patientLink, isNotNull);
      expect(patientLink?['psychologist_id'], psychUid);

      // 4. Psychologist assigns a task for the patient
      when(() => mockUser.uid).thenReturn(psychUid);
      await taskService.createTask(
        patientId: patientUid,
        title: 'Registro de Pensamentos Automáticos',
        description: 'Identificar distorções cognitivas após situações de estresse.',
        category: 'cbt',
        protocol: 'TCC Ansiedade',
        difficultyLevel: 2,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );

      // 5. Patient logs current mood
      when(() => mockUser.uid).thenReturn(patientUid);
      await moodService.addEntry(
        mood: 3,
        anxiety: 8,
        energy: 4,
        stress: 7,
        notes: 'Preocupado com apresentação no trabalho.',
      );

      final myMoods = await moodService.getMyEntries();
      expect(myMoods.length, 1);
      expect(myMoods.first.mood, 3);
      expect(myMoods.first.anxiety, 8);
      expect(myMoods.first.notes, 'Preocupado com apresentação no trabalho.');

      // 6. Patient retrieves and completes assigned task
      final myTasks = await taskService.getMyTasks();
      expect(myTasks.length, 1);
      final assignedTask = myTasks.first;
      expect(assignedTask.title, 'Registro de Pensamentos Automáticos');
      expect(assignedTask.status, 'pending');

      await taskService.completeTask(
        taskId: assignedTask.id,
        response: 'Consegui reestruturar o pensamento catastrófico e me acalmar.',
        moodBefore: 2,
        moodAfter: 4,
      );

      // 7. Psychologist reviews task response and adds clinical notes
      when(() => mockUser.uid).thenReturn(psychUid);
      final psychTasks = await taskService.getTasksCreatedByMe();
      expect(psychTasks.length, 1);
      final completedTask = psychTasks.first;
      expect(completedTask.status, 'completed');
      expect(completedTask.patientResponse, contains('reestruturar o pensamento'));
      expect(completedTask.moodAfter, 4);

      await taskService.saveTherapistNotes(
        taskId: completedTask.id,
        notes: 'Paciente demonstrou excelente flexibilidade cognitiva na reestruturação.',
      );

      final updatedTaskSnapshot = await fakeFirestore.collection('tasks').doc(completedTask.id).get();
      expect(
        updatedTaskSnapshot.data()?['therapist_notes'],
        'Paciente demonstrou excelente flexibilidade cognitiva na reestruturação.',
      );
    });
  });
}
