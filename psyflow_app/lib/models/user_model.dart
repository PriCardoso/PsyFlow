import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  psychologist,
  professional,
  patient,
  admin,
}

enum ProfessionalSpecialty {
  psychology,
  occupationalTherapy,
  psychopedagogy,
  speechTherapy,
  neuropsychology,
  psychiatry,
  multidisciplinary;

  String get label {
    switch (this) {
      case ProfessionalSpecialty.psychology:
        return 'Psicologia';
      case ProfessionalSpecialty.occupationalTherapy:
        return 'Terapia Ocupacional';
      case ProfessionalSpecialty.psychopedagogy:
        return 'Psicopedagogia';
      case ProfessionalSpecialty.speechTherapy:
        return 'Fonoaudiologia';
      case ProfessionalSpecialty.neuropsychology:
        return 'Neuropsicologia';
      case ProfessionalSpecialty.psychiatry:
        return 'Psiquiatria';
      case ProfessionalSpecialty.multidisciplinary:
        return 'Equipe Multidisciplinar';
    }
  }

  String get councilLabel {
    switch (this) {
      case ProfessionalSpecialty.psychology:
      case ProfessionalSpecialty.neuropsychology:
        return 'CRP';
      case ProfessionalSpecialty.occupationalTherapy:
        return 'CREFITO';
      case ProfessionalSpecialty.psychopedagogy:
        return 'CBO / ABPp';
      case ProfessionalSpecialty.speechTherapy:
        return 'CRFa';
      case ProfessionalSpecialty.psychiatry:
        return 'CRM';
      default:
        return 'Registro Profissional';
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final ProfessionalSpecialty? specialty;
  final String? photoUrl;
  final String? phone;
  final String? crp; // Retained for backward compatibility
  final String? professionalRegistration; // Universal council registration
  final String? bio;
  final DateTime createdAt;
  final bool active;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.specialty,
    this.photoUrl,
    this.phone,
    this.crp,
    this.professionalRegistration,
    this.bio,
    this.active = true,
  });

  bool get isProfessional => role == UserRole.professional || role == UserRole.psychologist;
  bool get isPatient => role == UserRole.patient;

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    DateTime parsedDate;
    final createdVal = map["createdAt"] ?? map["created_at"];
    if (createdVal is Timestamp) {
      parsedDate = createdVal.toDate();
    } else if (createdVal is String) {
      parsedDate = DateTime.tryParse(createdVal) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    // Role parsing
    final roleStr = map["role"] as String?;
    UserRole parsedRole = UserRole.patient;
    if (roleStr != null) {
      parsedRole = UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == roleStr.toLowerCase(),
        orElse: () => UserRole.patient,
      );
    }

    // Specialty parsing (handles snake_case and camelCase)
    final specStr = map["specialty"] as String?;
    ProfessionalSpecialty? parsedSpec;
    if (specStr != null) {
      final cleanSpec = specStr.replaceAll('_', '').toLowerCase();
      parsedSpec = ProfessionalSpecialty.values.firstWhere(
        (e) => e.name.replaceAll('_', '').toLowerCase() == cleanSpec,
        orElse: () => ProfessionalSpecialty.psychology,
      );
    }

    final reg = map["professional_registration"] ?? map["professionalRegistration"] ?? map["crp"];

    return UserModel(
      uid: id,
      email: map["email"] as String? ?? "",
      fullName: (map["full_name"] ?? map["fullName"]) as String? ?? "",
      role: parsedRole,
      specialty: parsedSpec,
      phone: map["phone"] as String?,
      photoUrl: (map["photo_url"] ?? map["photoUrl"]) as String?,
      crp: reg as String?,
      professionalRegistration: reg as String?,
      bio: map["bio"] as String?,
      active: map["active"] as bool? ?? true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "full_name": fullName,
      "fullName": fullName, // dual write for backward compatibility
      "role": role.name,
      "specialty": specialty?.name,
      "phone": phone,
      "photo_url": photoUrl,
      "photoUrl": photoUrl,
      "crp": professionalRegistration ?? crp,
      "professional_registration": professionalRegistration ?? crp,
      "bio": bio,
      "active": active,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}