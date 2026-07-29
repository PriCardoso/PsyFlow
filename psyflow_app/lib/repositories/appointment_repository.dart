import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_item.dart';
import '../models/availability_slot.dart';

abstract class AppointmentRepository {
  Stream<List<AppointmentItem>> streamPatientAppointments(String patientId);
  Stream<List<AppointmentItem>> streamProfessionalAppointments(String professionalId);
  Stream<List<AvailabilitySlot>> streamSlotsForProfessional(String professionalId);
  Future<void> bookAppointment({
    required String professionalId,
    required String patientId,
    required AvailabilitySlot slot,
    required String modality,
  });
  Future<void> cancelAppointment(String appointmentId);
  Future<void> addSlot(AvailabilitySlot slot);
  Future<void> deleteSlot(String slotId);
}

class FirestoreAppointmentRepository implements AppointmentRepository {
  final FirebaseFirestore _db;

  FirestoreAppointmentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<AppointmentItem>> streamPatientAppointments(String patientId) {
    return _db
        .collection('appointments')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('scheduled_date', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  @override
  Stream<List<AppointmentItem>> streamProfessionalAppointments(String professionalId) {
    return _db
        .collection('appointments')
        .where('psychologist_id', isEqualTo: professionalId)
        .orderBy('scheduled_date', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  @override
  Stream<List<AvailabilitySlot>> streamSlotsForProfessional(String professionalId) {
    return _db
        .collection('availability_slots')
        .where('psychologist_id', isEqualTo: professionalId)
        .orderBy('date')
        .orderBy('start_time')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AvailabilitySlot.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  @override
  Future<void> bookAppointment({
    required String professionalId,
    required String patientId,
    required AvailabilitySlot slot,
    required String modality,
  }) async {
    await _db.runTransaction((tx) async {
      final slotRef = _db.collection('availability_slots').doc(slot.id);
      tx.update(slotRef, {'is_booked': true, 'is_active': false});

      tx.set(_db.collection('appointments').doc(), {
        'psychologist_id': professionalId,
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
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': 'cancelled',
    });
  }

  @override
  Future<void> addSlot(AvailabilitySlot slot) async {
    await _db.collection('availability_slots').add(slot.toMap());
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    await _db.collection('availability_slots').doc(slotId).delete();
  }
}
