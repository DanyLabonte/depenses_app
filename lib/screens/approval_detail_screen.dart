// lib/screens/approval_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:depenses_app/models/expense.dart';

class ApprovalDetailScreen extends StatelessWidget {
  final Expense expense;
  const ApprovalDetailScreen({super.key, required this.expense});

  String _fmt(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Widget _approvalTile({
    required String title,
    String? by,
    DateTime? at,
  }) {
    final ok = by != null && by.trim().isNotEmpty && at != null;
    return ListTile(
      leading: Icon(ok ? Icons.verified_rounded : Icons.hourglass_empty_rounded),
      title: Text(title),
      subtitle: Text(
        ok ? 'Par: $by . Le: ${_fmt(at)}' : 'En attente',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      Chip(
        label: Text(expense.status.label),
        avatar: Icon(
          expense.status == ExpenseStatus.rejected
              ? Icons.block_rounded
              : expense.status == ExpenseStatus.pending
              ? Icons.hourglass_bottom_rounded
              : Icons.verified_rounded,
        ),
      ),
      Chip(
        label: Text('${expense.amount.toStringAsFixed(2)} \$'),
        avatar: const Icon(Icons.attach_money_rounded),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('D?tails dÃ¢â‚¬â„¢approbation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
          const SizedBox(height: 12),

          // Infos de base
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: Text(expense.category),
              subtitle: Text(expense.description.isEmpty
                  ? '-'
                  : expense.description),
            ),
          ),
          const SizedBox(height: 8),

          // Cr?ation
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_rounded),
              title: Text('Cr?? par: ${expense.createdBy}'),
              subtitle: Text('Le: ${_fmt(expense.createdAt)}'),
            ),
          ),
          const SizedBox(height: 8),

          // Niveaux dÃ¢â‚¬â„¢approbation
          Card(
            child: Column(
              children: [
                _approvalTile(
                  title: 'Approbation niveau 1',
                  by: expense.approvedByLvl1,
                  at: expense.approvedAtLvl1,
                ),
                const Divider(height: 0),
                _approvalTile(
                  title: 'Approbation finale',
                  by: expense.approvedByFinal,
                  at: expense.approvedAtFinal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (expense.status == ExpenseStatus.rejected &&
              (expense.rejectionReason ?? '').isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.report_rounded),
                title: const Text('Raison du refus'),
                subtitle: Text(expense.rejectionReason!),
              ),
            ),

          // Journal
          if (expense.journal.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.history_rounded),
                      title: Text('Journal'),
                      dense: true,
                    ),
                    const Divider(height: 0),
                    for (final ev in expense.journal)
                      ListTile(
                        leading: const Icon(Icons.fiber_manual_record, size: 16),
                        title: Text(_label(ev.type)),
                        subtitle: Text(
                          'Par: ${ev.actor} . Le: ${_fmt(ev.at)}'
                              '${(ev.note ?? '').isNotEmpty ? '\nNote: ${ev.note}' : ''}',
                        ),
                        dense: true,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _label(AuditType t) {
    switch (t) {
      case AuditType.created:
        return 'Cr?ation';
      case AuditType.approved_lvl1:
        return 'Approuv?e N1';
      case AuditType.approved_final:
        return 'Approuv?e finale';
      case AuditType.rejected:
        return 'Refus?e';
    }
  }
}


