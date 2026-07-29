import 'user_model.dart';

class PsychologistModel extends UserModel {
  final String? clinic;

  const PsychologistModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.createdAt,
    required super.role,
    super.crp,
    super.professionalRegistration,
    super.specialty,
    super.phone,
    super.photoUrl,
    super.active,
    super.bio,
    this.clinic,
  });
}