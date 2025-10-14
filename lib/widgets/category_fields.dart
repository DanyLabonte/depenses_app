import 'package:flutter/material.dart';
import '../l10n/s.dart';

/// Bloc "QC99 - Service à la collectivité" + Catégorie + Sous-catégorie.
/// - `initialCategory` / `initialSubCategory` pour pré-remplir
/// - `onChanged(cat, sub)` renvoyé à chaque sélection
class CategoryFields extends StatefulWidget {
  final String? initialCategory;
  final String? initialSubCategory;
  final void Function(String category, String? subCategory) onChanged;

  const CategoryFields({
    super.key,
    this.initialCategory,
    this.initialSubCategory,
    required this.onChanged,
  });

  @override
  State<CategoryFields> createState() => _CategoryFieldsState();
}

class _CategoryFieldsState extends State<CategoryFields> {
  String? _cat;
  String? _sub;

  static const _categories = [
    'D11_PREMIER_SECOURS',
    'D12_SÉCURITÉ_CIVILE',
    'D13_PATROUILLE_CANINE',
    'D14_CLINIQUE',
    'D15_SAC_GÉNÉRAL',
  ];

  static const _subs = {
    'D11_PREMIER_SECOURS': [
      'PS0000 - PREMIER SECOURS GÉNÉRAL',
      'PS0062 - 0062 QUÉBEC',
      'PS0094 - 0094 SHERBROOKE',
      'PS0158 - 0158 DRUMMONDVILLE',
      'PS0233 - 0233 TROIS-RIVIÈRES',
      'PS0280 - 0280 SAINTE-HYACINTHE',
      'PS0300 - 0300 SAGUENAY',
      'PS0309 - 0309 BOIS FRANC ÉRABLE',
      'PS0335 - 0335 SAINT-GEORGES',
      'PS0452 - 0452 MONTRÉAL',
      'PS0549 - 0549 BAIE-COMEAU',
      'PS0789 - 0789 LAURENTIDES',
      'PS0843 - 0843 HAUT-RICHELIEU',
      'PS0883 - 0883 LANAUDIÈRES',
      'PS0907 - 0907 GATINEAU',
      'PS0971 - 0971 LAVAL',
      'PS1002 - 1002 LONGUEUIL',
    ],
    'D12_SÉCURITÉ_CIVILE': [
      'SC0000 - SÉCURITÉ CIVILE GÉNÉRAL',
      'SC0001 - ERU 1',
      'SC0002 - ERU 2',
      'SC0003 - ERU 3',
    ],
    'D13_PATROUILLE_CANINE': [
      'PC0000 - PATROUILLE CANINE GÉNÉRAL',
      'PC0001 - SECTEUR NORD',
      'PC0002 - SECTEUR SUD',
      'PC0003 - SECTEUR EST',
      'PC0004 - SECTEUR OUEST',
    ],
    'D14_CLINIQUE': ['CL0001 - CLINIQUE'],
    'D15_SAC_GÉNÉRAL': [
      'EP0001 - ÉQUIPE PROVINCIAL',
      'SAC000 - SERVICE À LA COLLECTIVITÉ GÉNÉRAL',
    ],
  };

  @override
  void initState() {
    super.initState();
    _cat = widget.initialCategory;
    _sub = widget.initialSubCategory;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête fixe
        Text(
          s.qc99Title, // "QC99 - Service à la collectivité"
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Catégorie
        DropdownButtonFormField<String>(
          value: _cat,
          decoration: InputDecoration(labelText: s.category),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (c) {
            setState(() {
              _cat = c;
              _sub = null;
            });
            widget.onChanged(_cat ?? '', _sub);
          },
        ),
        const SizedBox(height: 8),

        // Sous-catégorie (affichée seulement si catégorie choisie)
        if (_cat != null && _subs[_cat] != null)
          DropdownButtonFormField<String>(
            value: _sub,
            decoration: InputDecoration(labelText: s.subCategory),
            items: _subs[_cat]!
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) {
              setState(() => _sub = v);
              widget.onChanged(_cat ?? '', _sub);
            },
          ),
      ],
    );
  }
}
