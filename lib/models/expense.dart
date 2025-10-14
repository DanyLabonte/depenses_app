// lib/models/expense.dart
import 'dart:io';

/// Statut d'une réclamation
enum ExpenseStatus { pending, approvedLvl1, approvedFinal, rejected }

extension ExpenseStatusLabel on ExpenseStatus {
  String get label {
    switch (this) {
      case ExpenseStatus.pending:
        return 'En attente';
      case ExpenseStatus.approvedLvl1:
        return 'Approuvée N1';
      case ExpenseStatus.approvedFinal:
        return 'Approuvée finale';
      case ExpenseStatus.rejected:
        return 'Refusée';
    }
  }
}

/// Types d'événements du journal
enum AuditType { created, approved_lvl1, approved_final, rejected }

/// Événement d'audit (historique)
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

/// Modèle principal d'une dépense
class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String merchant;
  final String description;

  /// Pièces jointes en mémoire (facultatif)
  final List<File> attachments;

  /// Chemins/URI des pièces jointes (utilisé par l'UI et l'API mock)
  final List<String> attachmentUris;

  /// Métadonnées de création
  final DateTime createdAt;
  final String createdBy;

  /// Statut courant
  ExpenseStatus status;

  /// Journal complet (création, approbations, refus)
  List<AuditEvent> journal;

  // Champs d’approbation (remplis quand approuvé)
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

  /// Copie immuable et ciblée
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
