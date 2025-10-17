// lib/services/mock_store.dart

/// Stockage en m?moire (d?mo)
class MockStore {
  // Requ?tes d'?l?vation de r?le (si tu veux les exploiter c?t? AuthService)
  final List<Map<String, dynamic>> pendingRoleRequests = [];
  final List<Map<String, dynamic>> users = [];

  // Simule une base de donn?es en m?moire
  final List<Map<String, dynamic>> _expenses = [];
  int _nextId = 1;

  int nextId() => _nextId++;

  // ??????????????????????????????????????????????????????????????????????????
  // Helpers internes
  // ??????????????????????????????????????????????????????????????????????????

  List<Map<String, dynamic>> _journalOf(Map<String, dynamic> exp) {
    final j = exp['journal'];
    if (j is List) return j.cast<Map<String, dynamic>>();
    exp['journal'] = <Map<String, dynamic>>[];
    return exp['journal'];
  }

  void _appendAudit(
      Map<String, dynamic> exp, {
        required String type, // created | approved_lvl1 | approved_final | rejected
        required String actor,
        String? note,
        DateTime? at,
      }) {
    final journal = _journalOf(exp);
    journal.add({
      'type': type,
      'actor': actor,
      'at': (at ?? DateTime.now()).toIso8601String(),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
  }

  Map<String, dynamic> _normalizedExpense(Map<String, dynamic> expense) {
    // Copie d?fensive
    final e = Map<String, dynamic>.from(expense);

    // ID
    e['id'] = e['id'] ?? nextId();

    // Cr?ation & statut par d?faut
    e['createdAt'] = e['createdAt'] ?? e['created_at'] ?? DateTime.now().toIso8601String();
    e['createdBy'] = e['createdBy'] ?? e['created_by'] ?? (e['owner'] ?? '');
    e['status'] = e['status'] ?? 'pending_lvl1';

    // Champs facultatifs normalis?s
    if (e['amount'] is int) e['amount'] = (e['amount'] as int).toDouble();
    e['attachmentsCount'] = e['attachmentsCount'] ?? e['attachments_count'] ?? 0;

    // Journal initial : si absent, on ajoute l'?v?nement "created"
    final journal = _journalOf(e);
    final hasCreated = journal.any((it) => (it['type'] ?? '') == 'created');
    if (!hasCreated) {
      _appendAudit(
        e,
        type: 'created',
        actor: (e['createdBy'] ?? 'user').toString(),
        at: DateTime.tryParse(e['createdAt'] as String? ?? ''),
      );
    }
    return e;
  }

  // ??????????????????????????????????????????????????????????????????????????
  // API
  // ??????????????????????????????????????????????????????????????????????????

  void addExpense(Map<String, dynamic> expense) {
    final e = _normalizedExpense(expense);
    _expenses.add(e);
  }

  List<Map<String, dynamic>> byCreator(String email) =>
      _expenses.where((e) => (e['createdBy'] ?? '') == email).toList();

  List<Map<String, dynamic>> pendingForLvl1() =>
      _expenses.where((e) => e['status'] == 'pending_lvl1').toList();

  List<Map<String, dynamic>> pendingForLvl2() =>
      _expenses.where((e) => e['status'] == 'approved_lvl1').toList();

  Map<String, dynamic>? findById(int id) {
    try {
      return _expenses.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  void approveLvl1(int id, String approver) {
    final exp = findById(id);
    if (exp != null) {
      exp['status'] = 'approved_lvl1';
      exp['approvedByLvl1'] = approver;
      exp['approvedAtLvl1'] = DateTime.now().toIso8601String();
      _appendAudit(exp, type: 'approved_lvl1', actor: approver);
    }
  }

  void approveFinal(int id, String approver, String dispatch) {
    final exp = findById(id);
    if (exp != null) {
      exp['status'] = 'approved_final';
      exp['approvedByFinal'] = approver;
      exp['approvedAtFinal'] = DateTime.now().toIso8601String();
      exp['dispatch'] = dispatch; // simple tra?age
      _appendAudit(exp, type: 'approved_final', actor: approver, note: dispatch.isNotEmpty ? 'Dispatch: $dispatch' : null);
    }
  }

  void reject(int id, String reason, String approver) {
    final exp = findById(id);
    if (exp != null) {
      exp['status'] = 'rejected';
      exp['rejectedBy'] = approver;
      exp['reason'] = reason;
      exp['rejectedAt'] = DateTime.now().toIso8601String();
      _appendAudit(exp, type: 'rejected', actor: approver, note: reason);
    }
  }
}


