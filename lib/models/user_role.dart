// lib/models/user_role.dart
enum UserRole {
  volunteer,   // B?n?vole SAC
  finance,     // Responsable finance
  admin,       // Administrateur
  operations,  // Op?rations
  expenses,    // D?penses
}

extension UserRoleLabel on UserRole {
  String get fr {
    switch (this) {
      case UserRole.volunteer:
        return 'B?n?vole SAC';
      case UserRole.finance:
        return 'Responsable finance';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.operations:
        return 'Op?rations';
      case UserRole.expenses:
        return 'D?penses';
    }
  }

  String get code {
    switch (this) {
      case UserRole.volunteer:
        return 'VOLUNTEER';
      case UserRole.finance:
        return 'FINANCE';
      case UserRole.admin:
        return 'ADMINISTRATEUR';
      case UserRole.operations:
        return 'OPERATIONS';
      case UserRole.expenses:
        return 'EXPENSES';
    }
  }
}

// ? extension utilis?e par AuthService.register / registerWithRoles
extension UserRoleApproval on UserRole {
  bool get requiresApproval {
    switch (this) {
      case UserRole.admin:
      case UserRole.finance:
        return true;  // approbation requise
      case UserRole.volunteer:
      case UserRole.operations:
      case UserRole.expenses:
        return false;
    }
  }
}


