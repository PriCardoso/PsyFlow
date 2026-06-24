import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/appointment_item.dart';
import '../../models/psychologist_summary.dart';
import '../../models/availability_slot.dart';

class AppointmentService {
  final SupabaseClient client;

  AppointmentService(this.client);

  Future<List<AppointmentItem>> getMyAppointmentsAsPatient(String userId) async {
    final data = await client
        .from('appointments')
        .select()
        .eq('patient_id', userId);

    return (data as List).map((m) => AppointmentItem.fromMap(m)).toList();
  }

  Future<List<AppointmentItem>> getMyAppointmentsAsPsychologist(String userId) async {
    final data = await client
        .from('appointments')
        .select()
        .eq('psychologist_id', userId);

    return (data as List).map((m) => AppointmentItem.fromMap(m)).toList();
  }

  Future<List<PsychologistSummary>> listAvailablePsychologists() async {
    final data = await client
        .from('users')
        .select('id, full_name, modality')
        .eq('role', 'psychologist');

    return (data as List).map((m) => PsychologistSummary.fromMap(m)).toList();
  }

  Future<List<AvailabilitySlot>> getAvailableSlotsForPsychologist(String psychologistId) async {
    final data = await client
        .from('availability_slots')
        .select()
        .eq('psychologist_id', psychologistId)
        .eq('is_active', true);

    return (data as List).map((m) => AvailabilitySlot.fromMap(m)).toList();
  }

  Future<void> addAvailabilitySlot({
    required String psychologistId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required String modality,
  }) async {
    await client.from('availability_slots').insert({
      'psychologist_id': psychologistId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime.toIso8601String().split('T')[1],
      'end_time': endTime.toIso8601String().split('T')[1],
      'modality': modality,
    });
  }

  Future<void> deleteSlot(String slotId) async {
    await client.from('availability_slots').delete().eq('id', slotId);
  }

  /// Mantenha apenas esta versão do bookAppointment
  Future<void> bookAppointment({
    required String psychologistId,
    required String patientId,
    required AvailabilitySlot slot,
    required String modality,
  }) async {
    await client.from('appointments').insert({
      'psychologist_id': psychologistId,
      'patient_id': patientId,
      'slot_id': slot.id,
      'scheduled_date':
          slot.date?.toIso8601String().split('T')[0],
      'start_time': slot.startTime,
      'end_time': slot.endTime,
      'modality': modality,
      'status': 'scheduled',
    });
  }
}
