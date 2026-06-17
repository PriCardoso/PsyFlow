import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/intervention_template.dart';

class InterventionService {
  final supabase = Supabase.instance.client;

  Future<List<InterventionTemplate>>
      getTemplates() async {
    final response = await supabase
        .from('intervention_templates')
        .select()
        .eq('is_active', true)
        .order('category');

    return (response as List)
        .map(
          (e) => InterventionTemplate.fromMap(e),
        )
        .toList();
  }

  Future<List<InterventionTemplate>>
      getByCategory(
    String category,
  ) async {
    final response = await supabase
        .from('intervention_templates')
        .select()
        .eq('category', category)
        .eq('is_active', true);

    return (response as List)
        .map(
          (e) => InterventionTemplate.fromMap(e),
        )
        .toList();
  }
}