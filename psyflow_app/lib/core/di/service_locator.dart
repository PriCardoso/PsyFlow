import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../repositories/user_repository.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/patient_repository.dart';
import '../../repositories/chat_repository.dart';
import '../../repositories/appointment_repository.dart';
import '../../core/services/user_service.dart';
import '../../core/services/task_service.dart';
import '../../core/services/appointment_service.dart';
import '../../core/services/mood_service.dart';
import '../../core/services/invite_service.dart';
import '../../core/services/protocol_service.dart';
import '../../core/services/journey_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/clinical_scale_service.dart';
import '../../core/services/emotional_log_service.dart';
import '../../core/services/intervention_service.dart';
import '../../core/services/other_services.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  _registerFirebaseServices();
  _registerRepositories();
  _registerServices();
}

void _registerFirebaseServices() {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
}

void _registerRepositories() {
  sl.registerLazySingleton<UserRepository>(
    () => FirestoreUserRepository(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => FirestoreTaskRepository(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<PatientRepository>(
    () => FirestorePatientRepository(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => FirestoreChatRepository(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => FirestoreAppointmentRepository(firestore: sl<FirebaseFirestore>()),
  );
}

void _registerServices() {
  sl.registerLazySingleton<UserService>(
    () => UserService(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton<TaskService>(
    () => TaskService(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
      taskRepository: sl<TaskRepository>(),
    ),
  );
  sl.registerLazySingleton<AppointmentService>(
    () => AppointmentService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<MoodService>(
    () => MoodService(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton<InviteService>(
    () => InviteService(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton<ProtocolService>(
    () => ProtocolService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<JourneyService>(
    () => JourneyService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<StorageService>(
    () => StorageService(storage: sl<FirebaseStorage>()),
  );
  sl.registerLazySingleton<ClinicalScaleService>(
    () => ClinicalScaleService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<EmotionalLogService>(
    () => EmotionalLogService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<InterventionService>(
    () => InterventionService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<PasswordResetService>(
    () => PasswordResetService(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton<RecommendationService>(
    () => RecommendationService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ProgressService>(
    () => ProgressService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ReportService>(
    () => ReportService(firestore: sl<FirebaseFirestore>()),
  );
}