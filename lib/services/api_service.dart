// lib/services/api_service.dart
import 'dart:io';
import '../models/expense.dart';
import 'mock_store.dart';

/// Adapter entre le modèle de l’app (camelCase + objets riches)
/// et le MockStore (snake_case + Map<String, dynamic>).
class ApiService {
  final MockStore _store = MockStore();

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers de conversion Map <-> Model
  // ────────────────────────────────────────────────────────────────────────────

  ExpenseStatus _statusFromAny(String raw) {
    final s = raw.trim();
    switch (s) {
      case 'approved_lvl1':
      case 'approvedLvl1':
        return ExpenseStatus.approvedLvl1;
      case 'approved_final':
      case 'approvedFinal':
        return ExpenseStatus.approvedFinal;
      case 'rejected':
        return ExpenseStatus.rejected;
      case 'pending_lvl1':
      case 'pending':
      default:
        return ExpenseStatus.pending;
    }
  }

  String _statusToSnake(ExpenseStatus st) {
    switch (st) {
      case ExpenseStatus.approvedLvl1:
        return 'approved_lvl1';
      case ExpenseStatus.approvedFinal:
        return 'approved_final';
      case ExpenseStatus.rejected:
        return 'rejected';
      case ExpenseStatus.pending:
      default:
        return 'pending_lvl1';
    }
  }

  DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  List<AuditEvent> _hydrateJournal(Map<String, dynamic> m) {
    final raw = m['journal'];
    if (raw is List) {
      return raw.map((e) {
        final mm = (e as Map).cast<String, dynamic>();
        final type = switch ((mm['type'] ?? '').toString()) {
          'created' => AuditType.created,
          'approved_lvl1' => AuditType.approved_lvl1,
          'approved_final' => AuditType.approved_final,
          'rejected' => AuditType.rejected,
          _ => AuditType.created,
        };
        return AuditEvent(
          type: type,
          at: _dt(mm['at']) ?? DateTime.now(),
          actor: (mm['actor'] ?? '').toString(),
          note: (mm['note'] as String?)?.trim(),
        );
      }).toList();
    }

    final createdAt = _dt(m['createdAt']) ?? _dt(m['created_at']) ?? DateTime.now();
    final createdBy = (m['createdBy'] ?? m['created_by'] ?? '').toString();
    final status = _statusFromAny((m['status'] ?? 'pending_lvl1').toString());

    final events = <AuditEvent>[
      AuditEvent(type: AuditType.created, at: createdAt, actor: createdBy),
    ];

    final approvedByLvl1 = (m['approvedByLvl1'] ?? m['approved_by_lvl1']) as String?;
    final approvedAtLvl1 = _dt(m['approvedAtLvl1'] ?? m['approved_at_lvl1']);

    final approvedByFinal = (m['approvedByFinal'] ?? m['approved_by_final']) as String?;
    final approvedAtFinal = _dt(m['approvedAtFinal'] ?? m['approved_at_final']);

    final rejectedBy = (m['rejectedBy'] ?? m['rejected_by']) as String?;
    final rejectedAt = _dt(m['rejectedAt'] ?? m['rejected_at']);
    final reason = (m['reason'] as String?)?.trim();

    if (approvedByLvl1 != null && approvedAtLvl1 != null) {
      events.add(AuditEvent(
        type: AuditType.approved_lvl1,
        at: approvedAtLvl1,
        actor: approvedByLvl1,
      ));
    }
    if (approvedByFinal != null && approvedAtFinal != null) {
      events.add(AuditEvent(
        type: AuditType.approved_final,
        at: approvedAtFinal,
        actor: approvedByFinal,
      ));
    }
    if (status == ExpenseStatus.rejected) {
      events.add(AuditEvent(
        type: AuditType.rejected,
        at: rejectedAt ?? DateTime.now(),
        actor: rejectedBy ?? 'Approver',
        note: reason,
      ));
    }

    events.sort((a, b) => a.at.compareTo(b.at));
    return events;
  }

  Expense _fromMap(Map<String, dynamic> m) {
    final attachmentsCount = (m['attachmentsCount'] ?? m['attachments_count'] ?? 0) as int;

    final uriList = <String>[];
    final rawUris = m['attachmentUris'] ?? m['attachment_uris'];
    if (rawUris is List) {
      for (final u in rawUris) {
        if (u != null && u.toString().isNotEmpty) uriList.add(u.toString());
      }
    }

    return Expense(
      id: (m['id'] ?? '').toString(),
      category: (m['category'] ?? '') as String,
      amount: (m['amount'] ?? 0).toDouble(),
      date: _dt(m['date']) ?? DateTime.now(),
      merchant: (m['merchant'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      attachments: <File>[],
      attachmentUris: uriList,
      createdBy: (m['createdBy'] ?? m['created_by'] ?? '') as String,
      createdAt: _dt(m['createdAt'] ?? m['created_at']) ?? DateTime.now(),
      status: _statusFromAny((m['status'] ?? 'pending_lvl1') as String),
      approvedByLvl1: m['approvedByLvl1'] as String? ?? m['approved_by_lvl1'] as String?,
      approvedAtLvl1: _dt(m['approvedAtLvl1'] ?? m['approved_at_lvl1']),
      approvedByFinal: m['approvedByFinal'] as String? ?? m['approved_by_final'] as String?,
      approvedAtFinal: _dt(m['approvedAtFinal'] ?? m['approved_at_final']),
      rejectionReason: m['reason'] as String?,
      journal: _hydrateJournal(m),
    );
  }

  Map<String, dynamic> _toMap(Expense e) {
    return {
      'id': int.tryParse(e.id) ?? _store.nextId(),
      'status': _statusToSnake(e.status),
      'createdBy': e.createdBy,
      'createdAt': e.createdAt.toIso8601String(),
      'amount': e.amount,
      'category': e.category,
      'merchant': e.merchant,
      'description': e.description,
      'date': e.date.toIso8601String(),
      'attachmentsCount': e.attachments.length,
      if (e.attachmentUris.isNotEmpty) 'attachmentUris': e.attachmentUris,
      if (e.approvedByLvl1 != null) 'approvedByLvl1': e.approvedByLvl1,
      if (e.approvedAtLvl1 != null) 'approvedAtLvl1': e.approvedAtLvl1!.toIso8601String(),
      if (e.approvedByFinal != null) 'approvedByFinal': e.approvedByFinal,
      if (e.approvedAtFinal != null) 'approvedAtFinal': e.approvedAtFinal!.toIso8601String(),
      if (e.rejectionReason != null) 'reason': e.rejectionReason,
      if (e.journal.isNotEmpty)
        'journal': e.journal
            .map((a) => {
          'type': switch (a.type) {
            AuditType.created => 'created',
            AuditType.approved_lvl1 => 'approved_lvl1',
            AuditType.approved_final => 'approved_final',
            AuditType.rejected => 'rejected',
          },
          'at': a.at.toIso8601String(),
          'actor': a.actor,
          if (a.note?.isNotEmpty == true) 'note': a.note,
        })
            .toList(),
    };
  }

  // ────────────────────────────────────────────────────────────────────────────
  // API publique
  // ────────────────────────────────────────────────────────────────────────────

  /// Ajoute une dépense (utilisé par ExpenseFormScreen).
  Future<void> addExpense(Expense exp) async {
    final map = _toMap(exp);
    _store.addExpense(map);
  }

  /// (Optionnel) Ajoute plusieurs dépenses en séquence.
  Future<void> addExpenses(List<Expense> list) async {
    for (final e in list) {
      await addExpense(e);
    }
  }

  /// Historique de l’utilisateur.
  Future<List<Expense>> fetchMyExpenses(String email) async {
    final list = _store.byCreator(email);
    return list.map(_fromMap).toList();
  }

  /// Liste approbations N1.
  Future<List<Expense>> fetchPendingLvl1() async {
    final list = _store.pendingForLvl1();
    return list.map(_fromMap).toList();
  }

  /// Liste approbations N2.
  Future<List<Expense>> fetchPendingLvl2() async {
    final list = _store.pendingForLvl2();
    return list.map(_fromMap).toList();
  }

  /// Récupération brute par ID (attendue par ApprovalDetailScreen).
  Future<Map<String, dynamic>?> findById(int id) async {
    return _store.findById(id);
  }

  /// Variante typée modèle.
  Future<Expense?> fetchExpense(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final m = _store.findById(intId);
    return m == null ? null : _fromMap(m);
  }

  Future<void> approveLvl1(int id, String approver) async {
    _store.approveLvl1(id, approver);
  }

  Future<void> approveFinal(int id, String coding, String approver) async {
    _store.approveFinal(id, approver, coding);
  }

  Future<void> reject(int id, String reason, String approver) async {
    _store.reject(id, reason, approver);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Compat pour anciens écrans (HistoryScreen)
  // ────────────────────────────────────────────────────────────────────────────

  /// Ancien nom utilisé dans certains écrans. Ici on retourne les enregistrements
  /// en attente (N1 + N2) pour éviter un crash si l’écran appelle encore ça.
  Future<List<Expense>> listExpenses() async {
    final data = <Map<String, dynamic>>[
      ..._store.pendingForLvl1(),
      ..._store.pendingForLvl2(),
    ];
    return data.map(_fromMap).toList();
  }

  /// Alias de compat.
  Future<List<Expense>> getExpenses() async {
    return await listExpenses();
  }
}
