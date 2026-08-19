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
        .where('status', isEqualTo: 'scheduled')
        .get();

    final appointments = <AppointmentItem>[];
    final Set<String> psychIds = {};

    for (final doc in snap.docs) {
      final item = AppointmentItem.fromMap({'id': doc.id, ...doc.data()});
      appointments.add(item);
      if (item.psychologistName == null || item.psychologistName!.trim().isEmpty) {
        psychIds.add(item.psychologistId);
      }
    }

    if (psychIds.isNotEmpty) {
      final userDocs = await Future.wait(
        psychIds.map((id) => _db.collection('users').doc(id).get()),
      );
      final namesMap = <String, String>{};
      final crpMap = <String, String>{};
      for (final doc in userDocs) {
        if (doc.exists) {
          final d = doc.data()!;
          namesMap[doc.id] = d['full_name'] ?? d['fullName'] ?? 'Dr(a). Psicólogo(a)';
          if (d['crp'] != null) crpMap[doc.id] = d['crp'];
        }
      }

      return appointments.map((a) {
        if (a.psychologistName == null || a.psychologistName!.trim().isEmpty) {
          return a.copyWith(
            psychologistName: namesMap[a.psychologistId] ?? 'Dr(a). Psicólogo(a)',
            psychologistCrp: crpMap[a.psychologistId],
          );
        }
        return a;
      }).toList();
    }

    return appointments;
  }

  Future<List<AppointmentItem>> getMyAppointmentsAsPsychologist(
      String userId) async {
    final snap = await _db
        .collection('appointments')
        .where('psychologist_id', isEqualTo: userId)
        .where('status', isEqualTo: 'scheduled')
        .get();

    final appointments = <AppointmentItem>[];
    final Set<String> patientIds = {};

    for (final doc in snap.docs) {
      final item = AppointmentItem.fromMap({'id': doc.id, ...doc.data()});
      appointments.add(item);
      if (item.patientName == null || item.patientName!.trim().isEmpty) {
        patientIds.add(item.patientId);
      }
    }

    if (patientIds.isNotEmpty) {
      final userDocs = await Future.wait(
        patientIds.map((id) => _db.collection('users').doc(id).get()),
      );
      final namesMap = <String, String>{};
      for (final doc in userDocs) {
        if (doc.exists) {
          final d = doc.data()!;
          namesMap[doc.id] = d['full_name'] ?? d['fullName'] ?? 'Paciente';
        }
      }

      return appointments.map((a) {
        if (a.patientName == null || a.patientName!.trim().isEmpty) {
          return a.copyWith(
            patientName: namesMap[a.patientId] ?? 'Paciente',
          );
        }
        return a;
      }).toList();
    }

    return appointments;
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

  /// Adiciona múltiplos horários na agenda em lote (batch)
  Future<int> addBatchAvailabilitySlots({
    required String psychologistId,
    required List<DateTime> dates,
    required List<int> selectedHours,
    required String modality,
    int durationMinutes = 50,
  }) async {
    try {
      final batch = _db.batch();
      int count = 0;

      for (final date in dates) {
        final dateStr = date.toIso8601String().split('T')[0];
        for (final hour in selectedHours) {
          final start = DateTime(date.year, date.month, date.day, hour, 0);
          final end = start.add(Duration(minutes: durationMinutes));
          final startStr = '${hour.toString().padLeft(2, '0')}:00';
          final endHour = end.hour.toString().padLeft(2, '0');
          final endMin = end.minute.toString().padLeft(2, '0');
          final endStr = '$endHour:$endMin';

          final docRef = _db.collection('availability_slots').doc();
          batch.set(docRef, {
            'psychologist_id': psychologistId,
            'date': dateStr,
            'start_time': startStr,
            'end_time': endStr,
            'modality': modality,
            'is_active': true,
            'is_booked': false,
            'created_at': FieldValue.serverTimestamp(),
          });
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
      return count;
    } catch (e) {
      throw AppException('Erro ao gerar horários na agenda: $e', originalError: e);
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
    String? psychologistName,
    String? psychologistCrp,
    required String patientId,
    String? patientName,
    required AvailabilitySlot slot,
    required String modality,
  }) async {
    try {
      await _db.runTransaction((tx) async {
        final slotRef = _db.collection('availability_slots').doc(slot.id);
        tx.update(slotRef, {'is_booked': true, 'is_active': false});

        tx.set(_db.collection('appointments').doc(), {
          'psychologist_id': psychologistId,
          'psychologist_name': psychologistName,
          'psychologist_crp': psychologistCrp,
          'patient_id': patientId,
          'patient_name': patientName,
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
