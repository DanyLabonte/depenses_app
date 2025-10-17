import 'package:flutter/material.dart';

class RoleOption {
  final String code;
  final String label;
  final bool selectable;
  final bool requiresApproval;
  const RoleOption({
    required this.code,
    required this.label,
    this.selectable = true,
    this.requiresApproval = false,
  });
}

const List<RoleOption> kAllRoles = [
  RoleOption(code: 'VOL_SAC', label: 'Réclamation Bénévole', selectable: true),
  RoleOption(code: 'OPS',     label: 'Opérations',          selectable: false),
  RoleOption(code: 'DEP',     label: 'Dépenses',            selectable: false),
  RoleOption(code: 'K9',      label: 'Patrouille canine',   selectable: false, requiresApproval: true),
  RoleOption(code: 'FIN',     label: 'Responsable finance', selectable: true,  requiresApproval: true),
  RoleOption(code: 'ADMIN',   label: 'Administrateur',      selectable: true,  requiresApproval: true),
];

class RolesSelector extends StatefulWidget {
  final Set<String> initial;
  final ValueChanged<Set<String>> onChanged;
  const RolesSelector({super.key, required this.initial, required this.onChanged});

  @override
  State<RolesSelector> createState() => _RolesSelectorState();
}

class _RolesSelectorState extends State<RolesSelector> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initial};
    if (_selected.isEmpty) _selected.add('VOL_SAC');
  }

  Widget _chip(RoleOption r) {
    final sel = _selected.contains(r.code);
    return FilterChip(
      label: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: Text(r.label, overflow: TextOverflow.ellipsis)),
        if (r.requiresApproval) ...[
          const SizedBox(width: 6),
          const Icon(Icons.verified_user_outlined, size: 16),
        ]
      ]),
      selected: sel,
      onSelected: r.selectable ? (v) {
        setState(() {
          if (v) {
            _selected.add(r.code);
          } else {
            _selected.remove(r.code);
            if (_selected.isEmpty) _selected.add('VOL_SAC');
          }
        });
        widget.onChanged(_selected);
      } : null,
      tooltip: r.selectable
          ? (r.requiresApproval ? "Soumis à approbation" : null)
          : "Bientôt disponible",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Rôles (plusieurs possibles)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kAllRoles.map(_chip).toList(),
        ),
        const SizedBox(height: 8),
        Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.info_outline, size: 16),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Les rôles “Responsable finance” et “Administrateur” nécessitent une approbation.',
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ],
    );
  }
}