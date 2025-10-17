import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:flutter/material.dart';
import '../l10n/s.dart';

/// Bloc "QC99 - Service ? la collectivit?" + Cat?gorie + Sous-cat?gorie.
/// - `initialCategory` / `initialSubCategory` pour pr?-remplir
/// - `onChanged(cat, sub)` renvoy? ? chaque s?lection
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
    'D12_S?CURIT?_CIVILE',
    'D13_PATROUILLE_CANINE',
    'D14_CLINIQUE',
    'D15_SAC_G?N?RAL',
  ];

  static const _subs = {
    'D11_PREMIER_SECOURS': [
      'PS0000 - PREMIER SECOURS G?N?RAL',
      'PS0062 - 0062 QU?BEC',
      'PS0094 - 0094 SHERBROOKE',
      'PS0158 - 0158 DRUMMONDVILLE',
      'PS0233 - 0233 TROIS-RIVI?RES',
      'PS0280 - 0280 SAINTE-HYACINTHE',
      'PS0300 - 0300 SAGUENAY',
      'PS0309 - 0309 BOIS FRANC ?RABLE',
      'PS0335 - 0335 SAINT-GEORGES',
      'PS0452 - 0452 MONTR?AL',
      'PS0549 - 0549 BAIE-COMEAU',
      'PS0789 - 0789 LAURENTIDES',
      'PS0843 - 0843 HAUT-RICHELIEU',
      'PS0883 - 0883 LANAUDI?RES',
      'PS0907 - 0907 GATINEAU',
      'PS0971 - 0971 LAVAL',
      'PS1002 - 1002 LONGUEUIL',
    ],
    'D12_S?CURIT?_CIVILE': [
      'SC0000 - S?CURIT? CIVILE G?N?RAL',
      'SC0001 - ERU 1',
      'SC0002 - ERU 2',
      'SC0003 - ERU 3',
    ],
    'D13_PATROUILLE_CANINE': [
      'PC0000 - PATROUILLE CANINE G?N?RAL',
      'PC0001 - SECTEUR NORD',
      'PC0002 - SECTEUR SUD',
      'PC0003 - SECTEUR EST',
      'PC0004 - SECTEUR OUEST',
    ],
    'D14_CLINIQUE': ['CL0001 - CLINIQUE'],
    'D15_SAC_G?N?RAL': [
      'EP0001 - ?QUIPE PROVINCIAL',
      'SAC000 - SERVICE ? LA COLLECTIVIT? G?N?RAL',
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
        // En-t?te fixe
        Text(
          s.qc99Title, // "QC99 - Service ? la collectivit?"
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Cat?gorie
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

        // Sous-cat?gorie (affich?e seulement si cat?gorie choisie)
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


