// lib/screens/timeline_screen.dart
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';

class TimelineScreen extends StatelessWidget {
  final Expense expense;
  const TimelineScreen({super.key, required this.expense});

  bool _isUrl(String p) => p.startsWith('http://') || p.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final dateLong = DateFormat.yMMMMd('fr_CA').add_Hm();
    final dateShort = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal de la réclamation'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _StatusChip(status: expense.status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Récapitulatif réclamation
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('${expense.category} • ${expense.amount.toStringAsFixed(2)} \$'),
              subtitle: Text(
                [
                  if (expense.merchant.toString().isNotEmpty) 'Marchand : ${expense.merchant}',
                  'Date : ${dateLong.format(expense.date)}',
                  'Statut : ${expense.status.label}',
                ].join('\n'),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pièces jointes (si présentes)
          if (expense.attachmentUris.isNotEmpty) ...[
            const Text('Pièces jointes', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: expense.attachmentUris.map((p) {
                final Widget thumb;
                if (_isUrl(p)) {
                  thumb = Image.network(
                    p,
                    width: 92, height: 92, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _brokenThumb(),
                  );
                } else if (!kIsWeb) {
                  thumb = Image.file(
                    File(p),
                    width: 92, height: 92, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _brokenThumb(),
                  );
                } else {
                  thumb = _brokenThumb();
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: thumb,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Journal / Timeline
          const Text('Historique', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (expense.journal.isEmpty)
            _EmptyState(dateShort: dateShort)
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expense.journal.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final a = expense.journal[i];
                  final meta = _auditMeta(a.type);
                  final when = dateShort.format(a.at);
                  final note = (a.note ?? '').trim();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: meta.color.withOpacity(.15),
                      child: Icon(meta.icon, color: meta.color),
                    ),
                    title: Text(meta.label),
                    subtitle: Text([
                      '$when — par ${a.actor}',
                      if (note.isNotEmpty) 'Note : $note',
                    ].join('\n')),
                    isThreeLine: note.isNotEmpty,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _brokenThumb() => Container(
    width: 92, height: 92,
    color: Colors.black12,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image),
  );

  _AuditMeta _auditMeta(AuditType t) {
    switch (t) {
      case AuditType.created:
        return const _AuditMeta('Créée', Icons.fiber_new, Colors.blueGrey);
      case AuditType.approved_lvl1:
        return const _AuditMeta('Approuvée N1', Icons.verified_outlined, Colors.indigo);
      case AuditType.approved_final:
        return const _AuditMeta('Approuvée finale', Icons.verified, Colors.green);
      case AuditType.rejected:
        return const _AuditMeta('Refusée', Icons.block, Colors.red);
    }
  }
}

/// Petit chip de statut, couleurs cohérentes avec l’historique
class _StatusChip extends StatelessWidget {
  final ExpenseStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    switch (status) {
      case ExpenseStatus.pending:
        color = Colors.amber; break;
      case ExpenseStatus.approvedLvl1:
        color = Colors.indigo; break;
      case ExpenseStatus.approvedFinal:
        color = Colors.green; break;
      case ExpenseStatus.rejected:
        color = Colors.red; break;
    }
    return Chip(
      label: Text(status.label),
      avatar: Icon(
        switch (status) {
          ExpenseStatus.pending => Icons.hourglass_top,
          ExpenseStatus.approvedLvl1 => Icons.verified_outlined,
          ExpenseStatus.approvedFinal => Icons.verified,
          ExpenseStatus.rejected => Icons.block,
        },
        size: 16, color: color,
      ),
      side: BorderSide(color: color.withOpacity(.5)),
    );
  }
}

class _AuditMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _AuditMeta(this.label, this.icon, this.color);
}

class _EmptyState extends StatelessWidget {
  final DateFormat dateShort;
  const _EmptyState({required this.dateShort});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: Colors.black45),
          const SizedBox(height: 8),
          const Text('Aucun événement pour le moment', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'La réclamation a été créée le ${dateShort.format(DateTime.now())}. Les validations apparaîtront ici.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
