import 'package:depenses_app/core/l10n/gen/s.dart';
// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:depenses_app/models/expense.dart';
import 'package:depenses_app/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String currentUserEmail;
  const HistoryScreen({super.key, required this.currentUserEmail});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _api = ApiService();

  ExpenseStatus? _statusFilter; // null = Tous
  int? _yearFilter;             // null = Toutes
  late Future<List<Expense>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Expense>> _tryLoadFromApi() async {
    // Invocation DYNAMIQUE pour ne pas casser la compilation si la m?thode nÃ¢â‚¬â„¢existe pas
    final dynamic api = _api;

    // 1) fetchExpensesForUser(email)
    try {
      final r = await api.fetchExpensesForUser(widget.currentUserEmail);
      if (r is List<Expense>) return r;
    } catch (_) {}

    // 2) listExpenses()
    try {
      final r = await api.listExpenses();
      if (r is List<Expense>) return r;
    } catch (_) {}

    // 3) getExpenses()
    try {
      final r = await api.getExpenses();
      if (r is List<Expense>) return r;
    } catch (_) {}

    throw StateError('Aucune m?thode API disponible.');
  }

  Future<List<Expense>> _load() async {
    try {
      final items = await _tryLoadFromApi();
      return items;
    } catch (_) {
      // MODE D?MO - liste locale pour voir lÃ¢â‚¬â„¢apparence imm?diatement
      final now = DateTime.now();
      return <Expense>[
        Expense(
          id: '1001',
          category: '77100 | Frais de d?placement',
          amount: 45.50,
          date: now.subtract(const Duration(days: 5)),
          merchant: 'Taxi Qu?bec',
          description: 'D?placement Qu?bec',
          attachments: const [],
          attachmentUris: const [],
          createdAt: now.subtract(const Duration(days: 5)),
          createdBy: widget.currentUserEmail,
          status: ExpenseStatus.pending,
          journal: const [],
        ),
        Expense(
          id: '1002',
          category: '77105 | H?bergement',
          amount: 120.00,
          date: DateTime(now.year - 1, 11, 3),
          merchant: 'H?tel Laurier',
          description: 'H?bergement',
          attachments: const [],
          attachmentUris: const [],
          createdAt: DateTime(now.year - 1, 11, 3),
          createdBy: widget.currentUserEmail,
          status: ExpenseStatus.approvedLvl1,
          journal: const [],
        ),
        Expense(
          id: '1003',
          category: '77102 | Repas',
          amount: 19.75,
          date: now.subtract(const Duration(days: 40)),
          merchant: 'Bistro 2000',
          description: 'Repas',
          attachments: const [],
          attachmentUris: const [],
          createdAt: now.subtract(const Duration(days: 40)),
          createdBy: widget.currentUserEmail,
          status: ExpenseStatus.rejected,
          journal: const [],
        ),
        Expense(
          id: '1004',
          category: '83100 | Uniformes',
          amount: 80.00,
          date: DateTime(now.year, 2, 12),
          merchant: 'Uniformes ABC',
          description: 'Uniforme',
          attachments: const [],
          attachmentUris: const [],
          createdAt: DateTime(now.year, 2, 12),
          createdBy: widget.currentUserEmail,
          status: ExpenseStatus.approvedFinal,
          journal: const [],
        ),
      ];
    }
  }

  String _statusLabel(BuildContext context, ExpenseStatus s) {
    final l = S.of(context);
    switch (s) {
      case ExpenseStatus.pending:
        return l.statusPending;                // "En attente dÃ¢â‚¬â„¢approbation"
      case ExpenseStatus.rejected:
        return l.statusRejected;               // "Refus?"
      case ExpenseStatus.approvedLvl1:
        return '${l.statusApproved} (Niv. 1)'; // "Approuv? (Niv. 1)"
      case ExpenseStatus.approvedFinal:
        return '${l.statusApproved} (Final)';  // "Approuv? (Final)"
    }
  }

  List<Expense> _applyFilters(List<Expense> items) {
    var data = items;
    if (_statusFilter != null) {
      data = data.where((e) => e.status == _statusFilter).toList();
    }
    if (_yearFilter != null) {
      data = data.where((e) => (e.createdAt).year == _yearFilter).toList();
    }
    data.sort((a, b) => (b.createdAt.compareTo(a.createdAt)));
    return data;
  }

  String _titleFor(Expense e) {
    // D?rive un titre lisible pour la tuile
    if (e.description.trim().isNotEmpty) return e.description;
    if (e.merchant.trim().isNotEmpty) return e.merchant;
    return e.category;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final years = <int>{
      DateTime.now().year,
      DateTime.now().year - 1,
      DateTime.now().year - 2,
    }.toList()
      ..sort((a, b) => b.compareTo(a));

    return FutureBuilder<List<Expense>>(
      future: _future,
      builder: (context, snap) {
        final all = snap.data ?? const <Expense>[];
        final filtered = _applyFilters(all);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtres
              Row(
                children: [
                  // Statut
                  Expanded(
                    child: DropdownButtonFormField<ExpenseStatus?>(
                      value: _statusFilter,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.filter_list),
                        labelText: s.filterStatus, // "Statut"
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(s.filterAll), // "Tous"
                        ),
                        DropdownMenuItem(
                          value: ExpenseStatus.pending,
                          child: Text(_statusLabel(context, ExpenseStatus.pending)),
                        ),
                        DropdownMenuItem(
                          value: ExpenseStatus.approvedLvl1,
                          child: Text(_statusLabel(context, ExpenseStatus.approvedLvl1)),
                        ),
                        DropdownMenuItem(
                          value: ExpenseStatus.approvedFinal,
                          child: Text(_statusLabel(context, ExpenseStatus.approvedFinal)),
                        ),
                        DropdownMenuItem(
                          value: ExpenseStatus.rejected,
                          child: Text(_statusLabel(context, ExpenseStatus.rejected)),
                        ),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Ann?e
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _yearFilter,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today),
                        labelText: s.filterYear, // "Ann?e"
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(s.filterAllYears), // "Toutes"
                        ),
                        for (final y in years)
                          DropdownMenuItem(
                            value: y,
                            child: Text(y.toString()),
                          ),
                      ],
                      onChanged: (v) => setState(() => _yearFilter = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      s.historyEmpty, // "Aucune rÃ¯Â¿Â½clamation pour ces filtres."
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = filtered[i];
                      final date = e.createdAt;
                      return ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: Text(_titleFor(e)),
                        subtitle: Text(
                          '${e.category} . '
                              '${date.day.toString().padLeft(2, '0')}-'
                              '${date.month.toString().padLeft(2, '0')}-'
                              '${date.year}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${e.amount.toStringAsFixed(2)} \$',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              _statusLabel(context, e.status),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        onTap: () {
                          // Quand votre ?cran de d?tail sera pr?t :
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (_) => ApprovalDetailScreen(expense: e),
                          // ));
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}



