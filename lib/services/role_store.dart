import "package:flutter/foundation.dart";
import "../models/user_roles.dart";

/// Stockage ultra-simple du rÃƒÂ´le et de l'identitÃƒÂ© courants cÃƒÂ´tÃƒÂ© client.
/// Ãƒâ‚¬ raccorder plus tard ÃƒÂ  votre auth rÃƒÂ©elle (Firebase, API, etc.).
class RoleStore {
  // RÃƒÂ´le actuellement utilisÃƒÂ© par l'UI.
  static final ValueNotifier<UserRole> notifier =
      ValueNotifier<UserRole>(UserRole.benevoleSac);

  // Email de l'utilisateur courant (si connu).
  static String? currentEmail;

  // Ensemble des rÃƒÂ´les attribuÃƒÂ©s ÃƒÂ  l'utilisateur (si connu).
  // Si null, on considÃƒÂ¨re au minimum le rÃƒÂ´le courant.
  static Set<UserRole>? _currentRoles;
  static Set<UserRole>? get currentRoles =>
      _currentRoles ?? <UserRole>{ notifier.value };

  static UserRole get role => notifier.value;

  static void setRole(UserRole r) {
    if (notifier.value != r) notifier.value = r;
  }

  /// Renseigner l'identitÃƒÂ© une fois l'utilisateur authentifiÃƒÂ©.
  static void setIdentity({
    required String email,
    required Set<UserRole> roles,
  }) {
    currentEmail = email;
    _currentRoles = roles.isEmpty ? <UserRole>{notifier.value} : roles;
  }

  /// Utilitaires simples si vous gÃƒÂ©rez les rÃƒÂ´les localement.
  static void grant(UserRole r) {
    final roles = currentRoles ?? <UserRole>{};
    roles.add(r);
    _currentRoles = roles;
  }

  static void revoke(UserRole r) {
    final roles = currentRoles ?? <UserRole>{};
    roles.remove(r);
    _currentRoles = roles;
    if (!roles.contains(notifier.value) && roles.isNotEmpty) {
      notifier.value = roles.first;
    }
  }
}