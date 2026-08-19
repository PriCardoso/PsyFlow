import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:psyflow_app/core/errors/app_exception.dart';
import 'package:psyflow_app/core/errors/error_handler.dart';
import 'package:psyflow_app/core/di/service_locator.dart';
import 'package:psyflow_app/core/services/user_service.dart';
import 'package:psyflow_app/core/services/task_service.dart';
import 'package:psyflow_app/core/services/mood_service.dart';
import 'package:psyflow_app/core/services/invite_service.dart';
import 'package:psyflow_app/core/services/appointment_service.dart';
import 'package:psyflow_app/repositories/user_repository.dart';
import 'package:psyflow_app/repositories/task_repository.dart';
import 'package:psyflow_app/models/task_item.dart';
import 'package:psyflow_app/models/mood_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockDocumentReference());
    registerFallbackValue(MockCollectionReference());
    registerFallbackValue(MockQuery());
    registerFallbackValue(MockQuerySnapshot());
    registerFallbackValue(MockDocumentSnapshot());
    registerFallbackValue(MockWriteBatch());
  });

  group('AppException', () {
    test('NetworkException has correct code', () {
      const exception = NetworkException('Network error');
      expect(exception.code, 'NETWORK_ERROR');
    });

    test('PermissionException has correct code', () {
      const exception = PermissionException('Permission denied');
      expect(exception.code, 'PERMISSION_DENIED');
    });

    test('NotFoundException has correct code', () {
      const exception = NotFoundException('Not found');
      expect(exception.code, 'NOT_FOUND');
    });

    test('ValidationException has correct code', () {
      const exception = ValidationException('Validation error');
      expect(exception.code, 'VALIDATION_ERROR');
    });

    test('AuthException has correct code', () {
      const exception = AuthException('Auth error');
      expect(exception.code, 'AUTH_ERROR');
    });

    test('CacheException has correct code', () {
      const exception = CacheException('Cache error');
      expect(exception.code, 'CACHE_ERROR');
    });

    test('UnknownException has correct code', () {
      const exception = UnknownException('Unknown error');
      expect(exception.code, 'UNKNOWN_ERROR');
    });

    test('mapToAppException maps FirebaseAuthException', () {
      final authException = FirebaseAuthException(
        code: 'wrong-password',
        message: 'Wrong password',
      );
      final appException = mapToAppException(authException);
      expect(appException, isA<AuthException>());
      expect(appException.message, 'E-mail ou senha inválidos');
    });

    test('mapToAppException maps FirebaseException permission-denied', () {
      final firebaseException = FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
        message: 'Permission denied',
      );
      final appException = mapToAppException(firebaseException);
      expect(appException, isA<PermissionException>());
    });
  });

  group('ErrorHandler', () {
    test('mapToAppException handles FormatException', () {
      final exception = mapToAppException(FormatException('Invalid format'));
      expect(exception, isA<ValidationException>());
    });

    test('mapToAppException handles ArgumentError', () {
      final exception = mapToAppException(ArgumentError('Invalid argument'));
      expect(exception, isA<ValidationException>());
    });

    test('mapToAppException passes through AppException', () {
      const original = NetworkException('Test');
      final exception = mapToAppException(original);
      expect(exception, same(original));
    });
  });

  group('UserService', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late UserService userService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      userService = UserService(firestore: mockFirestore, auth: mockAuth);
    });

    test('getProfile returns null when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      final result = await userService.getProfile();
      expect(result, isNull);
    });

    test('saveProfile throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => userService.saveProfile(role: 'patient', fullName: 'Test'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('TaskService', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockTaskRepository mockTaskRepository;
    late TaskService taskService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockTaskRepository = MockTaskRepository();
      taskService = TaskService(
        firestore: mockFirestore,
        auth: mockAuth,
        taskRepository: mockTaskRepository,
      );
    });

    test('getMyTasks throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => taskService.getMyTasks(),
        throwsA(isA<AppException>()),
      );
    });

    test('createTask throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => taskService.createTask(patientId: 'patient1', title: 'Test task'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('MoodService', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MoodService moodService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      moodService = MoodService(firestore: mockFirestore, auth: mockAuth);
    });

    test('addEntry throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => moodService.addEntry(mood: 5, anxiety: 3, energy: 4),
        throwsA(isA<AppException>()),
      );
    });

    test('getMyEntries throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => moodService.getMyEntries(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('InviteService', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late InviteService inviteService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      inviteService = InviteService(firestore: mockFirestore, auth: mockAuth);
    });

    test('generateInvite throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => inviteService.generateInvite(),
        throwsA(isA<AppException>()),
      );
    });

    test('useInvite throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => inviteService.useInvite('ABC123'),
        throwsA(isA<AppException>()),
      );
    });

    test('getMyPatients throws when user not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      
      expect(
        () => inviteService.getMyPatients(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('AppointmentService', () {
    late MockFirebaseFirestore mockFirestore;
    late AppointmentService appointmentService;
    late MockCollectionReference mockCollection;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      appointmentService = AppointmentService(mockFirestore);
    });

    test('addAvailabilitySlot calls firestore', () async {
      when(() => mockFirestore.collection('availability_slots')).thenReturn(mockCollection);
      when(() => mockCollection.add(any())).thenAnswer((_) async => MockDocumentReference());
      
      await appointmentService.addAvailabilitySlot(
        psychologistId: 'psych1',
        date: DateTime.now(),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        modality: 'online',
      );
      
      verify(() => mockFirestore.collection('availability_slots')).called(1);
    });

    test('deleteSlot calls firestore', () async {
      final mockDocRef = MockDocumentReference();
      when(() => mockFirestore.collection('availability_slots')).thenReturn(mockCollection);
      when(() => mockCollection.doc('slot1')).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenAnswer((_) async {});
      
      await appointmentService.deleteSlot('slot1');
      
      verify(() => mockCollection.doc('slot1').delete()).called(1);
    });
  });

  group('UserRepository', () {
    late MockFirebaseFirestore mockFirestore;
    late FirestoreUserRepository userRepository;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocRef;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocRef = MockDocumentReference();
      userRepository = FirestoreUserRepository(firestore: mockFirestore);
    });

    test('getUserById returns null when document does not exist', () async {
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc('user1')).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async {
        final snapshot = MockDocumentSnapshot();
        when(() => snapshot.exists).thenReturn(false);
        when(() => snapshot.data()).thenReturn(null);
        return snapshot;
      });
      
      final result = await userRepository.getUserById('user1');
      expect(result, isNull);
    });
  });

  group('TaskRepository', () {
    late MockFirebaseFirestore mockFirestore;
    late FirestoreTaskRepository taskRepository;
    late MockCollectionReference mockCollection;
    late MockQuery mockQuery;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockQuery = MockQuery();
      taskRepository = FirestoreTaskRepository(firestore: mockFirestore);
    });

    test('getTasksForPatient returns empty list when no tasks', () async {
      when(() => mockFirestore.collection('tasks')).thenReturn(mockCollection);
      when(() => mockCollection.where('patient_id', isEqualTo: 'patient1')).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('created_at', descending: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async {
        final snapshot = MockQuerySnapshot();
        when(() => snapshot.docs).thenReturn([]);
        return snapshot;
      });
      
      final result = await taskRepository.getTasksForPatient('patient1');
      expect(result, isEmpty);
    });
  });
}

class MockTaskRepository extends Mock implements TaskRepository {}