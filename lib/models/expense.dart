// lib/models/expense.dart
import 'dart:io';

/// Statut dÃ¢â‚¬â„¢une rÃ¯Â¿Â½clamation
enum ExpenseStatus { pending, approvedLvl1, approvedFinal, rejected }

extension ExpenseStatusLabel on ExpenseStatus {
  String get label {
    switch (this) {
      case ExpenseStatus.pending:
        return 'En attente';
      case ExpenseStatus.approvedLvl1:
        return 'Approuv?e N1';
      case ExpenseStatus.approvedFinal:
        return 'Approuv?e finale';
      case ExpenseStatus.rejected:
        return 'Refus?e';
    }
  }
}

/// Types d'?v?nements du journal
enum AuditType { created, approved_lvl1, approved_final, rejected }

/// ?v?nement dÃ¢â‚¬â„¢audit (historique)
class AuditEvent {
  final AuditType type;
  final DateTime at;
  final String actor;
  final String? note;

  const AuditEvent({
    required this.type,
    required this.at,
    required this.actor,
    this.note,
  });
}

/// Mod?le principal dÃ¢â‚¬â„¢une d?pense
class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String merchant;
  final String description;

  /// Pi?ces jointes en m?moire (facultatif)
  final List<File> attachments;

  /// Chemins/URI des pi?ces jointes (utilis? par lÃ¢â‚¬â„¢UI et lÃ¢â‚¬â„¢API mock)
  final List<String> attachmentUris;

  /// M?tadonn?es de cr?ation
  final DateTime createdAt;
  final String createdBy;

  /// Statut courant
  ExpenseStatus status;

  /// Journal complet (cr?ation, approbations, refus)
  List<AuditEvent> journal;

  // Champs dÃ¢â‚¬â„¢approbation (remplis quand approuv?)
  String? approvedByLvl1;
  DateTime? approvedAtLvl1;

  String? approvedByFinal;
  DateTime? approvedAtFinal;

  /// Raison en cas de refus
  String? rejectionReason;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.merchant,
    required this.description,
    this.attachments = const <File>[],
    this.attachmentUris = const <String>[],
    required this.createdAt,
    required this.createdBy,
    this.status = ExpenseStatus.pending,
    List<AuditEvent>? journal,
    this.approvedByLvl1,
    this.approvedAtLvl1,
    this.approvedByFinal,
    this.approvedAtFinal,
    this.rejectionReason,
  }) : journal = journal ?? <AuditEvent>[];

  /// Copie immuable et cibl?e
  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? merchant,
    String? description,
    List<File>? attachments,
    List<String>? attachmentUris,
    DateTime? createdAt,
    String? createdBy,
    ExpenseStatus? status,
    List<AuditEvent>? journal,
    String? approvedByLvl1,
    DateTime? approvedAtLvl1,
    String? approvedByFinal,
    DateTime? approvedAtFinal,
    String? rejectionReason,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      merchant: merchant ?? this.merchant,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      attachmentUris: attachmentUris ?? this.attachmentUris,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      journal: journal ?? List<AuditEvent>.from(this.journal),
      approvedByLvl1: approvedByLvl1 ?? this.approvedByLvl1,
      approvedAtLvl1: approvedAtLvl1 ?? this.approvedAtLvl1,
      approvedByFinal: approvedByFinal ?? this.approvedByFinal,
      approvedAtFinal: approvedAtFinal ?? this.approvedAtFinal,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}


