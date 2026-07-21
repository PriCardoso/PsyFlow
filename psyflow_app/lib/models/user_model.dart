import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  psychologist,
  patient,
  admin,
}

class UserModel {
  final String uid;

  final String email;

  final String fullName;

  final UserRole role;

  final String? photoUrl;

  final String? phone;

  final String? crp;

  final String? bio;

  final DateTime createdAt;

  final bool active;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.photoUrl,
    this.phone,
    this.crp,
    this.bio,
    this.active = true,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return UserModel(
      uid: id,
      email: map["email"] ?? "",
      fullName: map["full_name"] ?? map["fullName"] ?? "",
      role: UserRole.values.firstWhere(
        (e) => e.name == map["role"],
        orElse: () => UserRole.patient,
      ),
      phone: map["phone"],
      photoUrl: map["photoUrl"],
      crp: map["crp"],
      bio: map["bio"],
      active: map["active"] ?? true,
      createdAt:
          (map["createdAt"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "fullName": fullName,
      "role": role.name,
      "phone": phone,
      "photoUrl": photoUrl,
      "crp": crp,
      "bio": bio,
      "active": active,
      "createdAt": createdAt,
    };
  }
}