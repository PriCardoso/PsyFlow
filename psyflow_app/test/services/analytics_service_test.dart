import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:psyflow_app/core/services/analytics_service.dart';
import 'package:psyflow_app/models/mood_model.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('AnalyticsService', () {
    late MockFirebaseAnalytics mockAnalytics;
    late AnalyticsService analyticsService;

    setUp(() {
      mockAnalytics = MockFirebaseAnalytics();
      analyticsService = AnalyticsService(analytics: mockAnalytics);
    });

    test('logLogin calls analytics.logLogin with email method', () async {
      when(() => mockAnalytics.logLogin(loginMethod: any(named: 'loginMethod')))
          .thenAnswer((_) async {});

      await analyticsService.logLogin(method: 'email');

      verify(
        () => mockAnalytics.logLogin(loginMethod: 'email'),
      ).called(1);
    });

    test('logSignUp calls analytics.logSignUp', () async {
      when(
        () => mockAnalytics.logSignUp(signUpMethod: any(named: 'signUpMethod')),
      ).thenAnswer((_) async {});

      await analyticsService.logSignUp(method: 'email');

      verify(
        () => mockAnalytics.logSignUp(signUpMethod: 'email'),
      ).called(1);
    });

    test('logLogout calls analytics.logEvent with logout', () async {
      when(() => mockAnalytics.logEvent(name: any(named: 'name')))
          .thenAnswer((_) async {});

      await analyticsService.logLogout();

      verify(
        () => mockAnalytics.logEvent(name: 'logout'),
      ).called(1);
    });

    test('logMoodLogged calls analytics.logEvent with mood_logged', () async {
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      await analyticsService.logMoodLogged(moodScore: 8);

      verify(
        () => mockAnalytics.logEvent(
          name: 'mood_logged',
          parameters: {'mood_score': 8},
        ),
      ).called(1);
    });

    test('logTaskCreated calls analytics.logEvent with task_created', () async {
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      await analyticsService.logTaskCreated(patientId: 'p123');

      verify(
        () => mockAnalytics.logEvent(
          name: 'task_created',
          parameters: {'patient_id': 'p123'},
        ),
      ).called(1);
    });

    test('logTaskCompleted calls analytics.logEvent with task_completed',
        () async {
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      await analyticsService.logTaskCompleted(taskId: 't456');

      verify(
        () => mockAnalytics.logEvent(
          name: 'task_completed',
          parameters: {'task_id': 't456'},
        ),
      ).called(1);
    });

    test('analytics errors are silently caught without rethrowing', () async {
      when(() => mockAnalytics.logLogin(loginMethod: any(named: 'loginMethod')))
          .thenThrow(Exception('Firebase unavailable'));

      // Should not throw
      await expectLater(
        analyticsService.logLogin(),
        completes,
      );
    });
  });

  group('MoodEntry model', () {
    test('fromMap parses all fields correctly', () {
      final map = {
        'id': 'mood1',
        'patient_id': 'p1',
        'mood': 8,
        'anxiety': 3,
        'energy': 7,
        'sleep_quality': 6,
        'stress': 4,
        'notes': 'Feeling good',
        'factors': ['work', 'exercise'],
        'created_at': DateTime(2024, 6, 15),
      };

      final entry = MoodEntry.fromMap(map);

      expect(entry.id, 'mood1');
      expect(entry.patientId, 'p1');
      expect(entry.mood, 8);
      expect(entry.anxiety, 3);
      expect(entry.energy, 7);
      expect(entry.sleepQuality, 6);
      expect(entry.stress, 4);
      expect(entry.notes, 'Feeling good');
      expect(entry.factors, ['work', 'exercise']);
    });

    test('fromMap uses default values for missing optional fields', () {
      final map = {
        'id': 'mood2',
        'patient_id': 'p2',
        'mood': 6,
        'anxiety': 5,
        'energy': 6,
        'created_at': DateTime(2024, 1, 1),
      };

      final entry = MoodEntry.fromMap(map);

      expect(entry.sleepQuality, 6); // defaultValue
      expect(entry.stress, 5); // defaultValue
      expect(entry.notes, isNull);
      expect(entry.factors, isEmpty);
    });

    test('getScoreColor returns green for high scores', () {
      final color = MoodEntry.getScoreColor(9);
      expect(color.value, 0xFF10B981); // green
    });

    test('getScoreColor returns red for low scores', () {
      final color = MoodEntry.getScoreColor(2);
      expect(color.value, 0xFFEF4444); // red
    });

    test('getScoreColor inverse works for anxiety/stress', () {
      // Anxiety 1 (very calm) should be green when inverse=true
      final calmColor = MoodEntry.getScoreColor(1, inverse: true);
      expect(calmColor.value, 0xFF10B981);

      // Anxiety 10 (very high) should be red when inverse=true
      final highColor = MoodEntry.getScoreColor(10, inverse: true);
      expect(highColor.value, 0xFFEF4444);
    });

    test('moodEmoji returns correct emoji for score', () {
      final entry = MoodEntry(
        id: '1',
        patientId: 'p1',
        mood: 10,
        anxiety: 1,
        energy: 8,
        createdAt: DateTime.now(),
      );
      expect(entry.moodEmoji, '🌟');
    });

    test('toMap serializes correctly', () {
      final now = DateTime(2024, 3, 20);
      final entry = MoodEntry(
        id: 'e1',
        patientId: 'p1',
        mood: 7,
        anxiety: 4,
        energy: 6,
        sleepQuality: 8,
        stress: 3,
        notes: 'Test note',
        factors: const ['sleep', 'diet'],
        createdAt: now,
      );

      final map = entry.toMap();

      expect(map['patient_id'], 'p1');
      expect(map['mood'], 7);
      expect(map['anxiety'], 4);
      expect(map['energy'], 6);
      expect(map['sleep_quality'], 8);
      expect(map['stress'], 3);
      expect(map['notes'], 'Test note');
      expect(map['factors'], ['sleep', 'diet']);
    });
  });
}
