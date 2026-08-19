class AppUser {
  final String id;
  final String email;
  final String role;
  final String? workspaceId;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.workspaceId,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      workspaceId: map['workspace_id'] as String?,
    );
  }
}