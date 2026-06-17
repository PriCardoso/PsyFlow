import 'package:supabase_flutter/supabase_flutter.dart';

class JourneyService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getJourney(
    String patientId,
  ) async {
    final data = await supabase
        .from('therapy_journeys')
        .select()
        .eq('patient_id', patientId)
        .maybeSingle();

    return data;
  }

  Future<List<Map<String, dynamic>>> getSteps(
    String protocol,
  ) async {
    final data = await supabase
        .from('journey_steps')
        .select()
        .eq('protocol', protocol)
        .order('phase');

    return List<Map<String, dynamic>>.from(data);
  }
}