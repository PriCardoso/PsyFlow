import 'user_model.dart';

class PatientModel extends UserModel {
  final String? psychologistId;

  final DateTime? birthDate;

  final String? gender;

  final String? diagnosis;

  final String? observations;

  const PatientModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.createdAt,
    required super.role,
    super.phone,
    super.photoUrl,
    super.active,
    this.psychologistId,
    this.birthDate,
    this.gender,
    this.diagnosis,
    this.observations,
  });
}