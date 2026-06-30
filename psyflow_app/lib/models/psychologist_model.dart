import 'user_model.dart';

class PsychologistModel extends UserModel {
  final String crp;

  final String? specialty;

  final String? bio;

  final String? clinic;

  const PsychologistModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.createdAt,
    required super.role,
    required this.crp,
    super.phone,
    super.photoUrl,
    super.active,
    this.specialty,
    this.bio,
    this.clinic,
  });
}