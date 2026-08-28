import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:psyflow_app/core/services/data_export_service.dart';

void main() {
  group('DataExportService LGPD', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DataExportService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = DataExportService(firestore: fakeFirestore);
    });

    test('collectUserData compiles profile, mood, tasks, appointments and scales', () async {
      const userId = 'user-test-123';

      // Seed data
      await fakeFirestore.collection('users').doc(userId).set({
        'email': 'user@example.com',
        'full_name': 'Paciente Teste',
        'role': 'patient',
      });

      await fakeFirestore.collection('mood_entries').add({
        'user_id': userId,
        'mood': 4,
        'primary_emotion': 'Calmo',
      });

      await fakeFirestore.collection('tasks').add({
        'patient_id': userId,
        'title': 'Exercício de Respiração',
        'status': 'completed',
      });

      await fakeFirestore.collection('appointments').add({
        'patient_id': userId,
        'date': '2026-09-01',
        'status': 'scheduled',
      });

      await fakeFirestore.collection('clinical_scale_responses').add({
        'user_id': userId,
        'scale_code': 'PHQ-9',
        'total_score': 3,
      });

      final result = await service.collectUserData(userId);

      expect(result['user_id'], userId);
      expect(result['platform'], 'PsyFlow');
      expect(result['compliance'], 'LGPD / GDPR Data Portability');
      expect(result['profile'], isNotNull);
      expect((result['profile'] as Map)['email'], 'user@example.com');
      expect((result['mood_entries'] as List).length, 1);
      expect((result['tasks'] as List).length, 1);
      expect((result['appointments'] as List).length, 1);
      expect((result['clinical_scale_responses'] as List).length, 1);
    });

    test('exportUserDataAsFormattedJson returns valid JSON string', () async {
      const userId = 'user-test-json';

      await fakeFirestore.collection('users').doc(userId).set({
        'email': 'json@test.com',
        'full_name': 'Export JSON Test',
      });

      final jsonStr = await service.exportUserDataAsFormattedJson(userId);

      expect(jsonStr, isNotEmpty);
      expect(jsonStr, contains('user-test-json'));
      expect(jsonStr, contains('LGPD / GDPR Data Portability'));
    });
  });
}
