enum UserRole {
  admin,
  manager,
  supervisor,
  technician,
  unknown
}

class UserSession {
  final String username;
  final UserRole role;
  final String token;

  UserSession({
    required this.username,
    required this.role,
    required this.token,
  });

  // Helper method to convert the incoming raw backend string to an Enum
  static UserRole mapStringToRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'supervisor':
        return UserRole.supervisor;
      case 'technician':
        return UserRole.technician;
      default:
        return UserRole.unknown;
    }
  }

  // Quick RBAC access control parameters
  bool get canConfigureGoldenSample {
    return role == UserRole.admin || role == UserRole.manager;
  }

  bool get canTriggerInspection {
    return role != UserRole.unknown;
  }
}
