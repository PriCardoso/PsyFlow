import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendationService {
  final supabase = Supabase.instance.client;

  Future<void> saveRecommendation({
    required String patientId,
    required String recommendation,
    required String type,
    required String severity,
  }) async {
    await supabase.from('ai_recommendations').insert({
      'patient_id': patientId,
      'recommendation': recommendation,
      'recommendation_type': type,
      'severity': severity,
    });
  }

  Future<List<Map<String, dynamic>>> getRecommendations(
    String patientId,
  ) async {
    final data = await supabase
        .from('ai_recommendations')
        .select()
        .eq('patient_id', patientId)
        .order(
          'created_at',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(data);
  }
}