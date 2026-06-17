import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/appointment_model.dart';

class AppointmentService {
  final supabase = Supabase.instance.client;

  // ── PSICÓLOGO: gerenciar disponibilidade ─────────────

  Future<void> addAvailabilitySlot({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await supabase.from('availability_slots').insert({
        'psychologist_id': user.id,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar horário: $e');
    }
  }

  Future<List<AvailabilitySlot>> getMySlots() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('availability_slots')
          .select()
          .eq('psychologist_id', user.id)
          .gte('start_time', DateTime.now().toIso8601String())
          .order('start_time', ascending: true);

      return (data as List)
          .map((item) => AvailabilitySlot.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar horários: $e');
    }
  }

  Future<void> deleteSlot(String slotId) async {
    try {
      await supabase.from('availability_slots').delete().eq('id', slotId);
    } catch (e) {
      throw Exception('Erro ao remover horário: $e');
    }
  }

  // ── PACIENTE: escolher psicólogo e agendar ───────────

  /// Lista psicólogos disponíveis (perfil completo)
  Future<List<Map<String, dynamic>>> listAvailablePsychologists() async {
    try {
      final data = await supabase.rpc('list_available_psychologists');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Erro ao buscar psicólogos: $e');
    }
  }

  /// Lista horários livres de um psicólogo específico
  Future<List<AvailabilitySlot>> getAvailableSlotsForPsychologist(String psychologistId) async {
    try {
      final data = await supabase
          .from('availability_slots')
          .select()
          .eq('psychologist_id', psychologistId)
          .eq('is_booked', false)
          .gte('start_time', DateTime.now().toIso8601String())
          .order('start_time', ascending: true);

      return (data as List)
          .map((item) => AvailabilitySlot.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar horários disponíveis: $e');
    }
  }

  /// Paciente agenda uma consulta em um horário disponível
  Future<void> bookAppointment({
    required String psychologistId,
    required AvailabilitySlot slot,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await supabase.from('appointments').insert({
        'psychologist_id': psychologistId,
        'patient_id': user.id,
        'slot_id': slot.id,
        'start_time': slot.startTime.toIso8601String(),
        'end_time': slot.endTime.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao agendar consulta: $e');
    }
  }

  /// Paciente vê seus agendamentos
  Future<List<AppointmentItem>> getMyAppointmentsAsPatient() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('appointments')
          .select('*, psychologist:psychologist_id(full_name)')
          .eq('patient_id', user.id)
          .order('start_time', ascending: true);

      return (data as List)
          .map((item) => AppointmentItem.fromMap(item as Map<String, dynamic>, isPsychologistView: false))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }

  /// Psicólogo vê seus agendamentos
  Future<List<AppointmentItem>> getMyAppointmentsAsPsychologist() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('appointments')
          .select('*, patient:patient_id(full_name)')
          .eq('psychologist_id', user.id)
          .order('start_time', ascending: true);

      return (data as List)
          .map((item) => AppointmentItem.fromMap(item as Map<String, dynamic>, isPsychologistView: true))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }

  /// Cancela um agendamento (libera o horário automaticamente via trigger)
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId);
    } catch (e) {
      throw Exception('Erro ao cancelar consulta: $e');
    }
  }
}
