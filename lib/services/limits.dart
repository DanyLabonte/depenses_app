// lib/utils/limits.dart

/// Définition centralisée des plafonds de dépenses par catégorie.
/// Permet de gérer les exceptions selon le rôle, les plafonds globaux,
/// et les textes à afficher en cas de dépassement.
class Limits {
  /// Plafond standard par catégorie (en dollars)
  static const Map<String, double> categoryMax = {
    'Repas': 75.0,
    'Transport': 200.0,
    'Hébergement': 300.0,
    'Fournitures': 150.0,
    'Autre': 100.0,
  };

  /// Plafonds mensuels globaux (optionnel)
  static const Map<String, double> monthlyGlobalMax = {
    'Employé': 1500.0,
    'Bénévole SAC': 1000.0,
    'Chef divisionnaire': 2500.0,
    'Administrateur': 5000.0,
  };

  /// Majoration par rôle (en pourcentage)
  static const Map<String, double> roleBonus = {
    'Chef divisionnaire': 1.2, // +20 %
    'Administrateur': 2.0,     // double
  };

  /// Retourne le plafond applicable pour une catégorie donnée.
  static double getLimitForCategory(String category, {String? role}) {
    final base = categoryMax[category] ?? 100.0;
    if (role == null) return base;
    final multiplier = roleBonus[role] ?? 1.0;
    return base * multiplier;
  }

  /// Vérifie si le montant respecte le plafond.
  static bool isWithinLimit(double amount, String category, {String? role}) {
    return amount <= getLimitForCategory(category, role: role);
  }

  /// Message convivial à afficher en cas de dépassement.
  static String limitExceededMessage(String category, {String? role}) {
    final limit = getLimitForCategory(category, role: role);
    return 'Le montant dépasse la limite autorisée pour "$category" '
        '(${limit.toStringAsFixed(2)} \$${role != null ? ' pour le rôle $role' : ''}).';
  }

  /// Vérifie le plafond global mensuel d’un utilisateur.
  /// Retourne `true` si en dessous, `false` sinon.
  static bool isUnderMonthlyTotal(double totalSpent, {String? role}) {
    if (role == null) return true;
    final max = monthlyGlobalMax[role];
    if (max == null) return true;
    return totalSpent <= max;
  }

  /// Texte explicatif des plafonds, pour affichage dans l’app.
  static String getLimitsDescription({String? role}) {
    final buffer = StringBuffer();
    buffer.writeln('📋 *Plafonds par catégorie*${role != null ? ' pour $role' : ''}:');
    categoryMax.forEach((cat, value) {
      buffer.writeln('• $cat : ${getLimitForCategory(cat, role: role).toStringAsFixed(2)} \$');
    });
    if (role != null && monthlyGlobalMax.containsKey(role)) {
      buffer.writeln('\n💰 Limite mensuelle globale : '
          '${monthlyGlobalMax[role]!.toStringAsFixed(2)} \$');
    }
    return buffer.toString();
  }
}
