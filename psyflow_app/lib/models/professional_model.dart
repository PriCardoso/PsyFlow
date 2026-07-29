import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class ProfessionalModel extends UserModel {
  final String? professionalRegistration;
  final String? bio;
  final String? clinicAddress;
  final String? clinicPhone;
  final List<String>? specializations;
  final List<String>? approaches;
  final List<String>? languages;
  final Map<String, dynamic>? availability;
  final bool acceptsInsurance;
  final List<String>? acceptedInsurances;
  final double? sessionPrice;
  final String? currency;
  final int? yearsExperience;
  final String? education;
  final List<String>? certifications;
  final double averageRating;
  final int totalReviews;
  final bool isAvailableForNewPatients;
  final DateTime? lastActiveAt;

  const ProfessionalModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.role,
    required super.createdAt,
    super.specialty,
    super.photoUrl,
    super.phone,
    super.crp,
    this.professionalRegistration,
    this.bio,
    this.clinicAddress,
    this.clinicPhone,
    this.specializations,
    this.approaches,
    this.languages,
    this.availability,
    this.acceptsInsurance = false,
    this.acceptedInsurances,
    this.sessionPrice,
    this.currency = 'BRL',
    this.yearsExperience,
    this.education,
    this.certifications,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isAvailableForNewPatients = true,
    this.lastActiveAt,
    super.active = true,
  });

  @override
  bool get isProfessional => true;

  factory ProfessionalModel.fromMap(Map<String, dynamic> map, String id) {
    final user = UserModel.fromMap(map, id);

    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ProfessionalModel(
      uid: user.uid,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      specialty: user.specialty,
      photoUrl: user.photoUrl,
      phone: user.phone,
      crp: user.crp,
      createdAt: user.createdAt,
      active: user.active,
      professionalRegistration: map['professional_registration'] ?? map['professionalRegistration'] ?? map['crp'],
      bio: map['bio'],
      clinicAddress: map['clinic_address'] ?? map['clinicAddress'],
      clinicPhone: map['clinic_phone'] ?? map['clinicPhone'],
      specializations: List<String>.from(map['specializations'] ?? []),
      approaches: List<String>.from(map['approaches'] ?? []),
      languages: List<String>.from(map['languages'] ?? ['Português']),
      availability: map['availability'] as Map<String, dynamic>?,
      acceptsInsurance: map['accepts_insurance'] ?? map['acceptsInsurance'] ?? false,
      acceptedInsurances: List<String>.from(map['accepted_insurances'] ?? map['acceptedInsurances'] ?? []),
      sessionPrice: (map['session_price'] ?? map['sessionPrice'])?.toDouble(),
      currency: map['currency'] ?? 'BRL',
      yearsExperience: map['years_experience'] ?? map['yearsExperience'],
      education: map['education'],
      certifications: List<String>.from(map['certifications'] ?? []),
      averageRating: (map['average_rating'] ?? map['averageRating'] ?? 0).toDouble(),
      totalReviews: map['total_reviews'] ?? map['totalReviews'] ?? 0,
      isAvailableForNewPatients: map['is_available_for_new_patients'] ?? map['isAvailableForNewPatients'] ?? true,
      lastActiveAt: parseDate(map['last_active_at'] ?? map['lastActiveAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'professional_registration': professionalRegistration ?? crp,
      'bio': bio,
      'clinic_address': clinicAddress,
      'clinic_phone': clinicPhone,
      'specializations': specializations ?? [],
      'approaches': approaches ?? [],
      'languages': languages ?? ['Português'],
      'availability': availability,
      'accepts_insurance': acceptsInsurance,
      'accepted_insurances': acceptedInsurances ?? [],
      'session_price': sessionPrice,
      'currency': currency,
      'years_experience': yearsExperience,
      'education': education,
      'certifications': certifications ?? [],
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'is_available_for_new_patients': isAvailableForNewPatients,
      'last_active_at': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
    };
  }

  String get displaySpecialty => specialty?.label ?? 'Não informado';
  String get councilLabel => specialty?.councilLabel ?? 'Registro Profissional';
  String get councilNumber => professionalRegistration ?? crp ?? 'Não informado';

  List<String> get displaySpecializations => specializations?.where((s) => s.isNotEmpty).toList() ?? [];
  List<String> get displayApproaches => approaches?.where((a) => a.isNotEmpty).toList() ?? [];
  List<String> get displayLanguages => languages?.where((l) => l.isNotEmpty).toList() ?? ['Português'];

  String get formattedPrice {
    if (sessionPrice == null) return 'Consultar';
    return '${currency == 'BRL' ? 'R\$' : currency} ${sessionPrice!.toStringAsFixed(2)}';
  }

  String get experienceText {
    if (yearsExperience == null) return 'Experiência não informada';
    if (yearsExperience == 0) return 'Iniciante';
    if (yearsExperience == 1) return '1 ano de experiência';
    return '$yearsExperience anos de experiência';
  }

  String get ratingText {
    if (totalReviews == 0) return 'Sem avaliações';
    return '${averageRating.toStringAsFixed(1)} ($totalReviews avaliações)';
  }
}

class ProfessionalProfile {
  final String id;
  final String fullName;
  final String email;
  final ProfessionalSpecialty specialty;
  final String? professionalRegistration;
  final String? photoUrl;
  final String? bio;
  final String? clinicAddress;
  final List<String>? specializations;
  final List<String>? approaches;
  final double averageRating;
  final int totalReviews;
  final double? sessionPrice;
  final bool isAvailableForNewPatients;

  const ProfessionalProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.specialty,
    this.professionalRegistration,
    this.photoUrl,
    this.bio,
    this.clinicAddress,
    this.specializations,
    this.approaches,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.sessionPrice,
    this.isAvailableForNewPatients = true,
  });

  factory ProfessionalProfile.fromMap(Map<String, dynamic> map, String id) {
    ProfessionalSpecialty parsedSpec = ProfessionalSpecialty.psychology;
    final specStr = map['specialty'] as String?;
    if (specStr != null) {
      final cleanSpec = specStr.replaceAll('_', '').toLowerCase();
      parsedSpec = ProfessionalSpecialty.values.firstWhere(
        (e) => e.name.replaceAll('_', '').toLowerCase() == cleanSpec,
        orElse: () => ProfessionalSpecialty.psychology,
      );
    }

    return ProfessionalProfile(
      id: id,
      fullName: map['full_name'] ?? map['fullName'] ?? '',
      email: map['email'] ?? '',
      specialty: parsedSpec,
      professionalRegistration: map['professional_registration'] ?? map['professionalRegistration'] ?? map['crp'],
      photoUrl: map['photo_url'] ?? map['photoUrl'],
      bio: map['bio'],
      clinicAddress: map['clinic_address'] ?? map['clinicAddress'],
      specializations: List<String>.from(map['specializations'] ?? []),
      approaches: List<String>.from(map['approaches'] ?? []),
      averageRating: (map['average_rating'] ?? map['averageRating'] ?? 0).toDouble(),
      totalReviews: map['total_reviews'] ?? map['totalReviews'] ?? 0,
      sessionPrice: (map['session_price'] ?? map['sessionPrice'])?.toDouble(),
      isAvailableForNewPatients: map['is_available_for_new_patients'] ?? map['isAvailableForNewPatients'] ?? true,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String get displaySpecialty => specialty.label;
  String get councilLabel => specialty.councilLabel;
  String get councilNumber => professionalRegistration ?? 'Não informado';
}