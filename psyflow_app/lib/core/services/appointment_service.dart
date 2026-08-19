import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_item.dart';
import '../../models/psychologist_summary.dart';
import '../../models/availability_slot.dart';
import '../../core/errors/app_exception.dart';

class AppointmentService {
  final FirebaseFirestore _db;

  AppointmentService(this._db);

  // Stream methods for real-time updates
  Stream<List<AppointmentItem>> appointmentsStreamForPatient(String userId) {
    return _db
        .collection('appointments')
        .where('patient_id', isEqualTo: userId)
        .orderBy('scheduled_date', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Stream<List<AppointmentItem>> appointmentsStreamForPsychologist(String userId) {
    return _db
        .collection('appointments')
        .where('psychologist_id', isEqualTo: userId)
        .orderBy('scheduled_date', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Stream<List<AvailabilitySlot>> slotsStreamForPsychologist(String psychologistId) {
    return _db
        .collection('availability_slots')
        .where('psychologist_id', isEqualTo: psychologistId)
        .orderBy('date')
        .orderBy('start_time')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AvailabilitySlot.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<List<AppointmentItem>> getMyAppointmentsAsPatient(
      String userId) async {
    final snap = await _db
        .collection('appointments')
        .where('patient_id', isEqualTo: userId)
        .get();

    return snap.docs
        .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<AppointmentItem>> getMyAppointmentsAsPsychologist(
      String userId) async {
    final snap = await _db
        .collection('appointments')
        .where('psychologist_id', isEqualTo: userId)
        .get();

    return snap.docs
        .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<AvailabilitySlot>> getMySlots(String psychologistId) async {
    final snap = await _db
        .collection('availability_slots')
        .where('psychologist_id', isEqualTo: psychologistId)
        .get();

    return snap.docs
        .map((d) => AvailabilitySlot.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<PsychologistSummary>> listAvailablePsychologists() async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'psychologist')
        .get();

    return snap.docs
        .map((d) => PsychologistSummary.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<AvailabilitySlot>> getAvailableSlotsForPsychologist(
      String psychologistId) async {
    final snap = await _db
        .collection('availability_slots')
        .where('psychologist_id', isEqualTo: psychologistId)
        .where('is_active', isEqualTo: true)
        .get();

    return snap.docs
        .map((d) => AvailabilitySlot.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addAvailabilitySlot({
    required String psychologistId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required String modality,
  }) async {
    try {
      await _db.collection('availability_slots').add({
        'psychologist_id': psychologistId,
        'date': date.toIso8601String().split('T')[0],
        'start_time': startTime.toIso8601String().split('T')[1].substring(0, 5),
        'end_time': endTime.toIso8601String().split('T')[1].substring(0, 5),
        'modality': modality,
        'is_active': true,
        'is_booked': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException('Erro ao adicionar horário: $e', originalError: e);
    }
  }

  Future<void> deleteSlot(String slotId) async {
    try {
      await _db.collection('availability_slots').doc(slotId).delete();
    } catch (e) {
      throw AppException('Erro ao excluir horário: $e', originalError: e);
    }
  }

  Future<void> bookAppointment({
    required String psychologistId,
    required String patientId,
    required AvailabilitySlot slot,
    required String modality,
  }) async {
    try {
      await _db.runTransaction((tx) async {
        final slotRef = _db.collection('availability_slots').doc(slot.id);
        tx.update(slotRef, {'is_booked': true, 'is_active': false});

        tx.set(_db.collection('appointments').doc(), {
          'psychologist_id': psychologistId,
          'patient_id': patientId,
          'slot_id': slot.id,
          'scheduled_date': slot.date.toIso8601String().split('T')[0],
          'start_time': slot.startTime.toIso8601String().split('T')[1].substring(0, 5),
          'end_time': slot.endTime.toIso8601String().split('T')[1].substring(0, 5),
          'modality': modality,
          'status': 'scheduled',
          'created_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw AppException('Erro ao agendar consulta: $e', originalError: e);
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _db.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw AppException('Erro ao cancelar consulta: $e', originalError: e);
    }
  }
}
