import "package:flutter/material.dart";
import "../models/user_roles.dart";

const Set<String> kAdminApprovers = {
  "dany.labonte@sja.ca",
  "joanie.cote@sja.ca",
  "jeff.mok@sja.ca",
};

class CurrentUser {
  final String email;
  final Set<UserRole> roles;
  final bool mustChangePassword;
  const CurrentUser({required this.email, required this.roles, this.mustChangePassword=false});
  bool has(UserRole r) => roles.contains(r);
}

class RolePolicy {
  static bool canApproveRole({required UserRole targetRole, required CurrentUser approver}){
    switch (targetRole) {
      case UserRole.responsableFinance:
        return approver.has(UserRole.administrateur);
      case UserRole.administrateur:
        return kAdminApprovers.contains(approver.email.toLowerCase());
      case UserRole.benevoleSac:
        return approver.has(UserRole.administrateur) || approver.has(UserRole.responsableFinance);
    }
  }
  static bool canSwitchTo({required UserRole targetRole, required CurrentUser me}){
    if (me.has(targetRole)) return true; // jamais s'auto-promouvoir
    return false;
  }
  static String reasonForDeny(UserRole targetRole){
    switch (targetRole) {
      case UserRole.responsableFinance: return "Ce rÃƒÂ´le ne peut ÃƒÂªtre accordÃƒÂ© que par un Administrateur.";
      case UserRole.administrateur:     return "Ce rÃƒÂ´le ne peut ÃƒÂªtre accordÃƒÂ© que par Dany, Joanie ou Jeff.";
      case UserRole.benevoleSac:        return "OpÃƒÂ©ration non autorisÃƒÂ©e.";
    }
  }
}