import 'package:depenses_app/core/l10n/gen/s.dart';
// lib/screens/expense_form_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:depenses_app/models/expense.dart';
import 'package:depenses_app/services/api_service.dart';
import 'package:depenses_app/services/auth_service.dart';

/// ====== R?f?rentiels D?partement / Programme ======
enum DepartmentRef {
  d11('D11 - Premiers Secours'),
  d12('D12 - S?curit? Civile'),
  d13('D13 - Patrouille Canine'),
  d14('D14 - Clinique'),
  d15('D15 - SAC G?n?rale'),
  d16('D16 - SAC Direction');

  const DepartmentRef(this.label);
  final String label;
}

class ProgramRef {
  final String code;
  final String label;
  const ProgramRef(this.code, this.label);
}

const Map<DepartmentRef, List<ProgramRef>> _kProgramsByDept = {
  DepartmentRef.d11: [
    ProgramRef('PS0000', 'PREMIER SECOURS G?N?RAL'),
    ProgramRef('PS0062', 'DIVISION 0062 QU?BEC'),
    ProgramRef('PS0094', 'DIVISION 0094 SHERBROOKE'),
    ProgramRef('PS0158', 'DIVISION 0158 DRUMMONDVILLE'),
    ProgramRef('PS0233', 'DIVISION 0233 TROIS-RIVI?RES'),
    ProgramRef('PS0280', 'DIVISION 0280 SAINTE-HYACINTHE'),
    ProgramRef('PS0300', 'DIVISION 0300 SAGUENAY'),
    ProgramRef('PS0309', 'DIVISION 0309 BOIS FRANC ?RABLE'),
    ProgramRef('PS0335', 'DIVISION 0335 SAINT-GEORGES'),
    ProgramRef('PS0452', 'DIVISION 0452 MONTR?AL'),
    ProgramRef('PS0549', 'DIVISION 0549 BAIE-COMEAU'),
    ProgramRef('PS0789', 'DIVISION 0789 LAURENTIDES'),
    ProgramRef('PS0843', 'DIVISION 0843 HAUT-RICHELIEU'),
    ProgramRef('PS0883', 'DIVISION 0883 LANAUDI?RES'),
    ProgramRef('PS0907', 'DIVISION 0907 GATINEAU'),
    ProgramRef('PS0971', 'DIVISION 0971 LAVAL'),
    ProgramRef('PS1002', 'DIVISION 1002 LONGUEUIL'),
  ],
  DepartmentRef.d12: [
    ProgramRef('SC0000', 'S?CURIT? CIVILE G?N?RAL'),
    ProgramRef('SC0001', 'ERU 1'),
    ProgramRef('SC0002', 'ERU 2'),
    ProgramRef('SC0003', 'ERU 3'),
  ],
  DepartmentRef.d13: [
    ProgramRef('PC0000', 'PATROUILLE CANINE G?N?RAL'),
    ProgramRef('PC0001', 'SECTEUR NORD'),
    ProgramRef('PC0002', 'SECTEUR SUD'),
    ProgramRef('PC0003', 'SECTEUR EST'),
    ProgramRef('PC0004', 'SECTEUR OUEST'),
  ],
  DepartmentRef.d14: [
    ProgramRef('CL0001', 'CLINIQUE'),
  ],
  DepartmentRef.d15: [
    ProgramRef('EP0001', '?QUIPE PROVINCIAL'),
    ProgramRef('SAC000', 'SERVICE ? LA COLLECTIVIT? G?N?RAL'),
  ],
  DepartmentRef.d16: [
    ProgramRef('DIRSAC', 'DIRECTION DES SAC'),
  ],
};

class ExpenseFormScreen extends StatefulWidget {
  final String currentUserEmail;
  const ExpenseFormScreen({super.key, required this.currentUserEmail});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Champs communs
  final _amountCtrl = TextEditingController(); // g?n?rique OU repas/km
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _accountCode;

  // Photo obligatoire
  PlatformFile? _photo;

  // ----- Repas -----
  static const double _breakfastCap = 10.0;
  static const double _lunchCap = 15.0;
  static const double _dinnerCap = 25.0;

  MealType _mealType = MealType.breakfast;
  double _mealCovered = 0.0;
  double _mealNotCovered = 0.0;

  // ----- KM -----
  final _kmCtrl = TextEditingController();
  TravelType _travelType = TravelType.voiture;
  double get _kmRateCurrent => _travelType.rate;

  double _kmCoveredAmount = 0.0;
  double _kmNotCoveredAmount = 0.0;

  // D?partement / Programme
  DepartmentRef? _dept;
  ProgramRef? _program;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }

  Map<String, String> _accounts(BuildContext context) {
    final s = S.of(context);
    return <String, String>{
      '66100': s.acc66100,
      '66102': s.acc66102,
      '66104': s.acc66104,
      '77100': s.acc77100, // KM
      '77102': s.acc77102, // Repas
      '77105': s.acc77105,
      '81100': s.acc81100,
      '81101': s.acc81101,
      '81102': s.acc81102,
      '83100': s.acc83100,
      '84101': s.acc84101,
      '84102': s.acc84102,
      '84104': s.acc84104,
      '99999': s.acc99999,
    };
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0;

  String _money(num v) => v.toStringAsFixed(2);

  // Repas
  double _capFor(MealType t) {
    switch (t) {
      case MealType.breakfast:
        return _breakfastCap;
      case MealType.lunch:
        return _lunchCap;
      case MealType.dinner:
        return _dinnerCap;
    }
  }

  void _recomputeMeal() {
    final spent = _parse(_amountCtrl);
    final cap = _capFor(_mealType);
    final covered = spent.clamp(0, cap);
    final notCovered = (spent - covered).clamp(0, double.infinity);
    setState(() {
      _mealCovered = covered.toDouble();
      _mealNotCovered = notCovered.toDouble();
    });
  }

  // KM (50 premiers km couverts selon type)
  void _recomputeKm() {
    final km = _parse(_kmCtrl);
    final rate = _kmRateCurrent;
    final first50Covered = _travelType.first50Covered;
    final double eligibleKm =
    first50Covered ? km : (km - 50).clamp(0, double.infinity);

    final spent = km * rate;
    final covered = (eligibleKm * rate).clamp(0, spent);
    final notCovered = (spent - covered).clamp(0, double.infinity);

    setState(() {
      _kmCoveredAmount = covered.toDouble();
      _kmNotCoveredAmount = notCovered.toDouble();
      _amountCtrl.text = _money(_kmCoveredAmount);
    });
  }

  Future<void> _pickPhoto() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _photo = res.files.first);
    }
  }

  // Convertit lÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢image en data:URI pour attachmentUris (web friendly)
  String? _photoAsDataUri() {
    if (_photo?.bytes == null) return null;
    final ext = (_photo!.extension ?? '').toLowerCase();
    final mime = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
        ? 'image/webp'
        : 'image/jpeg';
    return Uri.dataFromBytes(_photo!.bytes!, mimeType: mime).toString();
  }

  Future<void> _onSubmit() async {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Veuillez joindre ou prendre une photo (obligatoire).'),
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final s = S.of(context);
    final api = ApiService();
    final accounts = _accounts(context);

    final bool isMeal = _accountCode == '77102';
    final bool isKm = _accountCode == '77100';

    double amountToSubmit;
    if (isMeal) {
      amountToSubmit = _mealCovered;
    } else if (isKm) {
      amountToSubmit = _kmCoveredAmount;
    } else {
      amountToSubmit = _parse(_amountCtrl);
    }

    const costCenter = 'QC99 - Service ? la collectivit?';
    final deptLbl = _dept?.label ?? '';
    final progLbl =
    _program == null ? '' : '${_program!.code} - ${_program!.label}';

    final enrichedDescription = [
      'Centre de co?t: $costCenter',
      if (deptLbl.isNotEmpty) 'D?partement: $deptLbl',
      if (progLbl.isNotEmpty) 'Programme: $progLbl',
      if (_notesCtrl.text.trim().isNotEmpty) 'Notes: ${_notesCtrl.text.trim()}',
    ].join(' | ');

    final dataUri = _photoAsDataUri();

    final exp = Expense(
      id: '',
      category: '${_accountCode ?? ''} | ${accounts[_accountCode] ?? ''}',
      amount: amountToSubmit,
      date: _date,
      merchant: '-',
      description: enrichedDescription,
      attachments: const [], // important pour le Web
      attachmentUris: dataUri != null ? [dataUri] : const <String>[],
      createdBy: widget.currentUserEmail,
      createdAt: DateTime.now(),
      status: ExpenseStatus.pending,
    );

    await api.addExpense(exp);

    // Notifier finance (mock)
    try {
      await AuthService().notifyFinanceNewExpense(
        createdBy: widget.currentUserEmail,
        amount: amountToSubmit,
        category: accounts[_accountCode] ?? '',
      );
    } catch (_) {}

    if (!mounted) return;

    final again = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Soumettre une autre rÃƒÂ©clamation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    ) ??
        false;

    if (!mounted) return;

    if (again) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ExpenseFormScreen(currentUserEmail: widget.currentUserEmail),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final accounts = _accounts(context);
    final bool isMeal = _accountCode == '77102';
    final bool isKm = _accountCode == '77100';

    if (isMeal) _recomputeMeal();
    if (isKm) _recomputeKm();

    return Scaffold(
      appBar: AppBar(title: Text(s.newClaim)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Centre de co?t (lecture seule)
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: const ListTile(
                      leading: Icon(Icons.account_tree_rounded),
                      title: Text('Centre de co?t'),
                      subtitle: Text('QC99 - Service ? la collectivit?'),
                      trailing: Icon(Icons.lock_rounded, size: 18),
                    ),
                  ),

                  // D?partement
                  DropdownButtonFormField<DepartmentRef>(
                    value: _dept,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'D?partement',
                      prefixIcon: Icon(Icons.business_center_rounded),
                    ),
                    items: DepartmentRef.values
                        .map((d) =>
                        DropdownMenuItem(value: d, child: Text(d.label)))
                        .toList(),
                    onChanged: (d) {
                      setState(() {
                        _dept = d;
                        _program = null;
                      });
                    },
                    validator: (v) => v == null ? 'S?lection requise' : null,
                  ),
                  const SizedBox(height: 8),

                  // Programme
                  DropdownButtonFormField<ProgramRef>(
                    value: _program,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Programme',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: (_dept == null
                        ? const <ProgramRef>[]
                        : _kProgramsByDept[_dept!] ?? const <ProgramRef>[])
                        .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.code} - ${p.label}'),
                    ))
                        .toList(),
                    onChanged: (p) => setState(() => _program = p),
                    validator: (v) => v == null ? 'S?lection requise' : null,
                  ),
                  const SizedBox(height: 8),

                  // Cat?gorie
                  DropdownButtonFormField<String>(
                    value: _accountCode,
                    decoration: InputDecoration(
                      labelText: s.category,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    isExpanded: true,
                    items: accounts.entries
                        .map((e) => DropdownMenuItem<String>(
                      value: e.key,
                      child: Text(e.value),
                    ))
                        .toList(),
                    validator: (v) =>
                    (v == null || v.isEmpty) ? s.requiredField : null,
                    onChanged: (v) {
                      setState(() => _accountCode = v);
                      if (v == '77102') _recomputeMeal();
                      if (v == '77100') _recomputeKm();
                    },
                  ),
                  const SizedBox(height: 8),

                  // Date + Montant
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de la d?pense',
                              prefixIcon: Icon(Icons.calendar_month_rounded),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: (isMeal || isKm)
                            ? InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Montant',
                            prefixIcon:
                            Icon(Icons.attach_money_rounded),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            isMeal
                                ? '${_money(_mealCovered)} \$'
                                : '${_money(_kmCoveredAmount)} \$',
                          ),
                        )
                            : TextFormField(
                          controller: _amountCtrl,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'))
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Montant',
                            prefixIcon:
                            Icon(Icons.attach_money_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return s.requiredField;
                            }
                            final parsed = double.tryParse(
                                v.replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0) {
                              return s.unknownError;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_accountCode == '77102')
                    _buildMealSection(context)
                  else if (_accountCode == '77100')
                    _buildKmSection(context),

                  // Notes
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // Photo obligatoire
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text(
                              'Joindre ou prendre une photo (obligatoire)'),
                        ),
                        if (_photo != null)
                          Chip(
                            avatar:
                            const Icon(Icons.image_rounded, size: 18),
                            label: Text(_photo!.name),
                            onDeleted: () =>
                                setState(() => _photo = null),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close_rounded),
                          label: Text(s.cancel),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save_rounded),
                          label: Text(s.confirm),
                          onPressed: _onSubmit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(BuildContext context) {
    final cap = _capFor(_mealType);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<MealType>(
                    value: _mealType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Repas',
                      prefixIcon: Icon(Icons.restaurant_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: MealType.breakfast, child: Text('D?jeuner')),
                      DropdownMenuItem(
                          value: MealType.lunch, child: Text('D?ner')),
                      DropdownMenuItem(
                          value: MealType.dinner, child: Text('Souper')),
                    ],
                    onChanged: (t) {
                      if (t == null) return;
                      setState(() => _mealType = t);
                      _recomputeMeal();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  avatar: const Icon(Icons.verified_rounded),
                  label: Text('Autoris? ${_money(cap)} \$'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              ],
              decoration: const InputDecoration(
                labelText: 'Montant d?pens?',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
              onChanged: (_) => _recomputeMeal(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return S.of(context).requiredField;
                }
                final parsed =
                double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return S.of(context).unknownError;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _readOnlyMoneyRow('Montant non couvert', _mealNotCovered,
                icon: Icons.block_rounded),
            const SizedBox(height: 8),
            _readOnlyMoneyRow('Total rembours?', _mealCovered,
                icon: Icons.receipt_long_rounded, strong: true),
          ],
        ),
      ),
    );
  }

  Widget _buildKmSection(BuildContext context) {
    final first50Covered = _travelType.first50Covered;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<TravelType>(
              value: _travelType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Type de d?placement',
                prefixIcon: Icon(Icons.directions_car_filled_rounded),
              ),
              items: TravelType.values
                  .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.label),
              ))
                  .toList(),
              onChanged: (t) {
                if (t == null) return;
                setState(() => _travelType = t);
                _recomputeKm();
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _kmCtrl,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
              ],
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                prefixIcon: Icon(Icons.alt_route_rounded),
              ),
              onChanged: (_) => _recomputeKm(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return S.of(context).requiredField;
                }
                final parsed =
                double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return S.of(context).unknownError;
                }
                return null;
              },
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    first50Covered
                        ? Icons.verified_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: first50Covered ? Colors.green : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      first50Covered
                          ? '50 premiers km COUVERTS pour ce type'
                          : '50 premiers km NON couverts pour ce type',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _readOnlyMoneyRow('Montant non couvert', _kmNotCoveredAmount,
                icon: Icons.block_rounded),
            const SizedBox(height: 8),
            _readOnlyMoneyRow('Total rembours?', _kmCoveredAmount,
                icon: Icons.local_atm_rounded, strong: true),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyMoneyRow(String label, double value,
      {bool strong = false, IconData? icon}) {
    final style =
    strong ? const TextStyle(fontWeight: FontWeight.w600) : const TextStyle();
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(label, style: style)),
        Text('${_money(value)} \$', style: style),
      ],
    );
  }
}

enum MealType { breakfast, lunch, dinner }

enum TravelType {
  moto,
  transportMaterielOuVisiteCanine,
  voiture,
  covoiturage3Plus,
  remorquage,
}

extension TravelTypeX on TravelType {
  String get label {
    switch (this) {
      case TravelType.moto:
        return 'Moto ou scooter';
      case TravelType.transportMaterielOuVisiteCanine:
        return 'Transport de mat?riel ou Visite Canine';
      case TravelType.voiture:
        return 'Voiture personnelle';
      case TravelType.covoiturage3Plus:
        return 'Covoiturage de 3 personnes et plus';
      case TravelType.remorquage:
        return 'Remorquage de mat?riel roulant';
    }
  }

  double get rate {
    switch (this) {
      case TravelType.moto:
        return 0.25;
      case TravelType.transportMaterielOuVisiteCanine:
        return 0.50;
      case TravelType.voiture:
        return 0.50;
      case TravelType.covoiturage3Plus:
        return 0.55;
      case TravelType.remorquage:
        return 0.60;
    }
  }

  /// Seuls "Transport de mat?riel ou Visite Canine" et "Remorquage."
  /// couvrent les 50 premiers km.
  bool get first50Covered {
    return this == TravelType.transportMaterielOuVisiteCanine ||
        this == TravelType.remorquage;
  }
}



