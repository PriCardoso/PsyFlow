import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_item.dart';
import '../models/availability_slot.dart';
import '../../core/errors/app_exception.dart';

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

  // Pagination support
  Future<List<AppointmentItem>> getPatientAppointmentsPaginated({
    required String patientId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
  Future<List<AppointmentItem>> getProfessionalAppointmentsPaginated({
    required String professionalId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
  Future<List<AvailabilitySlot>> getSlotsPaginated({
    required String professionalId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
}

class FirestoreAppointmentRepository implements AppointmentRepository {
  final FirebaseFirestore _db;

  FirestoreAppointmentRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  @override
  Stream<List<AppointmentItem>> streamPatientAppointments(String patientId) {
    return _db
        .collection('appointments')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('scheduled_date', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
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
            .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
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
            .map((d) => AvailabilitySlot.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
            .toList());
  }

  @override
  Future<void> bookAppointment({
    required String professionalId,
    required String patientId,
    required AvailabilitySlot slot,
    required String modality,
  }) async {
    try {
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
    } catch (e) {
      throw AppException('Erro ao agendar consulta: $e', originalError: e);
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _db.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw AppException('Erro ao cancelar consulta: $e', originalError: e);
    }
  }

  @override
  Future<void> addSlot(AvailabilitySlot slot) async {
    try {
      await _db.collection('availability_slots').add(slot.toMap());
    } catch (e) {
      throw AppException('Erro ao adicionar horário: $e', originalError: e);
    }
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    try {
      await _db.collection('availability_slots').doc(slotId).delete();
    } catch (e) {
      throw AppException('Erro ao excluir horário: $e', originalError: e);
    }
  }

  @override
  Future<List<AppointmentItem>> getPatientAppointmentsPaginated({
    required String patientId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection('appointments')
          .where('patient_id', isEqualTo: patientId)
          .orderBy('scheduled_date', descending: false)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();
      return snap.docs
          .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar consultas: $e', originalError: e);
    }
  }

  @override
  Future<List<AppointmentItem>> getProfessionalAppointmentsPaginated({
    required String professionalId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection('appointments')
          .where('psychologist_id', isEqualTo: professionalId)
          .orderBy('scheduled_date', descending: false)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();
      return snap.docs
          .map((d) => AppointmentItem.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar consultas: $e', originalError: e);
    }
  }

  @override
  Future<List<AvailabilitySlot>> getSlotsPaginated({
    required String professionalId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection('availability_slots')
          .where('psychologist_id', isEqualTo: professionalId)
          .orderBy('date')
          .orderBy('start_time')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();
      return snap.docs
          .map((d) => AvailabilitySlot.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList();
    } catch (e) {
      throw AppException('Erro ao buscar horários: $e', originalError: e);
    }
  }
}