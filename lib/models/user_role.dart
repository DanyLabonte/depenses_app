// lib/models/user_role.dart
enum UserRole {
  volunteer,   // Bénévole SAC
  finance,     // Responsable finance
  admin,       // Administrateur
  operations,  // Opérations
  expenses,    // Dépenses
}

extension UserRoleLabel on UserRole {
  String get fr {
    switch (this) {
      case UserRole.volunteer:
        return 'Bénévole SAC';
      case UserRole.finance:
        return 'Responsable finance';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.operations:
        return 'Opérations';
      case UserRole.expenses:
        return 'Dépenses';
    }
  }

  String get code {
    switch (this) {
      case UserRole.volunteer:
        return 'VOLUNTEER';
      case UserRole.finance:
        return 'FINANCE';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.operations:
        return 'OPERATIONS';
      case UserRole.expenses:
        return 'EXPENSES';
    }
  }
}

// ✅ extension utilisée par AuthService.register / registerWithRoles
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
