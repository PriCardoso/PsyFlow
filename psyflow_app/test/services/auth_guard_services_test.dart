import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyflow_app/repositories/task_repository.dart';

import 'package:psyflow_app/core/services/task_service.dart';
import 'package:psyflow_app/core/services/invite_service.dart';
import 'package:psyflow_app/core/services/mood_service.dart';
import 'package:psyflow_app/core/services/user_service.dart';
import 'package:psyflow_app/core/errors/app_exception.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('Auth guards for services', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
    });

    test('TaskService.getMyTasks throws when unauthenticated', () async {
      final service = TaskService(
        firestore: mockFirestore,
        auth: mockAuth,
        taskRepository: MockTaskRepository(),
      );

      when(() => mockAuth.currentUser).thenReturn(null);

      expect(() => service.getMyTasks(), throwsA(isA<AppException>()));
    });

    test('TaskService.createTask throws when unauthenticated', () async {
      final service = TaskService(
        firestore: mockFirestore,
        auth: mockAuth,
        taskRepository: MockTaskRepository(),
      );

      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => service.createTask(patientId: 'p1', title: 't'),
        throwsA(isA<AppException>()),
      );
    });

    test('InviteService methods throw when unauthenticated', () async {
      final service = InviteService(firestore: mockFirestore, auth: mockAuth);

      when(() => mockAuth.currentUser).thenReturn(null);

      expect(() => service.generateInvite(), throwsA(isA<AppException>()));
      expect(() => service.getMyInvites(), throwsA(isA<AppException>()));
      expect(() => service.useInvite('ABC123'), throwsA(isA<AppException>()));
      expect(() => service.getMyPatients(), throwsA(isA<AppException>()));
    });

    test('MoodService methods throw when unauthenticated', () async {
      final service = MoodService(firestore: mockFirestore, auth: mockAuth);

      when(() => mockAuth.currentUser).thenReturn(null);

      expect(() => service.addEntry(mood: 5, anxiety: 3, energy: 4), throwsA(isA<AppException>()));
      expect(() => service.getMyEntries(), throwsA(isA<AppException>()));
      final hasToday = await service.hasEntryToday();
      expect(hasToday, isFalse);
    });

    test('UserService returns null profile when unauthenticated and saveProfile throws', () async {
      final service = UserService(firestore: mockFirestore, auth: mockAuth);
      when(() => mockAuth.currentUser).thenReturn(null);

      final profile = await service.getProfile();
      expect(profile, isNull);

      expect(
        () => service.saveProfile(role: 'patient', fullName: 'Test'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
