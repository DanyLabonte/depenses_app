import 'package:flutter/material.dart';

/// ==========================
/// Réglages / Politiques SAC
/// ==========================
/// — Montant remboursé par KM (ajuste si besoin)
const double kKmRate = 0.58; // $/km
/// — Règles repas (exemples — ajuste si besoin)
const int kMinHoursForLunch = 4;
const int kMinHoursForDinner = 10;
const int kBreakfastThresholdHour = 7; // départ avant 07:00 => déjeuner éligible

/// — Barèmes forfaitaires repas (par repas)
const double kBreakfastPerDiem = 10.0;
const double kLunchPerDiem = 15.0;
const double kDinnerPerDiem = 25.0;

/// ==========================
/// Modèles retournés
/// ==========================
class KmDetail {
  final double distanceEnteredKm;
  final double eligibleKm;
  final bool excludedHomeCommute;
  final bool coveredByOrg;
  final double kmRate;
  final double kmAmount;

  KmDetail({
    required this.distanceEnteredKm,
    required this.eligibleKm,
    required this.excludedHomeCommute,
    required this.coveredByOrg,
    required this.kmRate,
    required this.kmAmount,
  });
}

class MealDetail {
  final bool breakfastEligible;
  final bool lunchEligible;
  final bool dinnerEligible;
  final bool provided; // repas fournis => exclusion
  final int breakfastQty;
  final int lunchQty;
  final int dinnerQty;
  final double breakfastRate;
  final double lunchRate;
  final double dinnerRate;

  double get breakfastAmount =>
      provided || !breakfastEligible ? 0 : breakfastQty * breakfastRate;
  double get lunchAmount =>
      provided || !lunchEligible ? 0 : lunchQty * lunchRate;
  double get dinnerAmount =>
      provided || !dinnerEligible ? 0 : dinnerQty * dinnerRate;

  double get totalMeals => breakfastAmount + lunchAmount + dinnerAmount;

  MealDetail({
    required this.breakfastEligible,
    required this.lunchEligible,
    required this.dinnerEligible,
    required this.provided,
    required this.breakfastQty,
    required this.lunchQty,
    required this.dinnerQty,
    required this.breakfastRate,
    required this.lunchRate,
    required this.dinnerRate,
  });
}

class KmMealResult {
  final KmDetail km;
  final MealDetail meals;
  final double grandTotal;
  final String? suggestedAccount; // '77100' (KM) ou '77102' (Repas)

  const KmMealResult({
    required this.km,
    required this.meals,
    required this.grandTotal,
    this.suggestedAccount,
  });
}

/// ==========================
/// Écran KM & Repas
/// ==========================
class KmMealAccountScreen extends StatefulWidget {
  /// 0 = KM, 1 = Repas
  final int initialTab;
  const KmMealAccountScreen({super.key, this.initialTab = 0});

  @override
  State<KmMealAccountScreen> createState() => _KmMealAccountScreenState();
}

class _KmMealAccountScreenState extends State<KmMealAccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // KM
  final _distanceCtrl = TextEditingController();
  bool _isHomeCommute = false; // Trajet domicile-travail (exclu)
  bool _isCoveredByOrg = false; // KM couverts par l’organisation (exclu)

  // Repas
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  bool _mealsProvided = false;
  int _bQty = 0;
  int _lQty = 0;
  int _dQty = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this, initialIndex: widget.initialTab)
      ..addListener(() => setState(() {})); // refresh pour la barre du bas
  }

  @override
  void dispose() {
    _tab.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Calculs
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _pickTime({required bool start}) async {
    final initial = start ? _start : _end;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (start) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Duration get _duration {
    final startMins = _start.hour * 60 + _start.minute;
    final endMins = _end.hour * 60 + _end.minute;
    final diff = endMins - startMins;
    return Duration(minutes: diff < 0 ? 0 : diff);
  }

  bool get _breakfastEligible => _start.hour < kBreakfastThresholdHour;
  bool get _lunchEligible => _duration.inHours >= kMinHoursForLunch;
  bool get _dinnerEligible => _duration.inHours >= kMinHoursForDinner;

  KmDetail _computeKm() {
    final raw = double.tryParse(_distanceCtrl.text.replaceAll(',', '.')) ?? 0;
    double eligible = raw;
    if (_isHomeCommute) eligible = 0;
    if (_isCoveredByOrg) eligible = 0;
    if (eligible < 0) eligible = 0;
    final amount = eligible * kKmRate;

    return KmDetail(
      distanceEnteredKm: raw,
      eligibleKm: eligible,
      excludedHomeCommute: _isHomeCommute,
      coveredByOrg: _isCoveredByOrg,
      kmRate: kKmRate,
      kmAmount: amount,
    );
  }

  MealDetail _computeMeals() {
    return MealDetail(
      breakfastEligible: _breakfastEligible,
      lunchEligible: _lunchEligible,
      dinnerEligible: _dinnerEligible,
      provided: _mealsProvided,
      breakfastQty: _bQty,
      lunchQty: _lQty,
      dinnerQty: _dQty,
      breakfastRate: kBreakfastPerDiem,
      lunchRate: kLunchPerDiem,
      dinnerRate: kDinnerPerDiem,
    );
  }

  void _confirm() {
    final km = _computeKm();
    final meals = _computeMeals();
    final bool isKmTab = _tab.index == 0;

    // total et compte suggéré basés UNIQUEMENT sur l’onglet actif
    final double total = isKmTab ? km.kmAmount : meals.totalMeals;
    final String? account =
    isKmTab ? (km.kmAmount > 0 ? '77100' : null) : (meals.totalMeals > 0 ? '77102' : null);

    // On remet à zéro la partie non utilisée pour éviter toute confusion
    final KmDetail kmForReturn = isKmTab
        ? km
        : KmDetail(
      distanceEnteredKm: 0,
      eligibleKm: 0,
      excludedHomeCommute: false,
      coveredByOrg: false,
      kmRate: kKmRate,
      kmAmount: 0,
    );

    final MealDetail mealsForReturn = isKmTab
        ? MealDetail(
      breakfastEligible: false,
      lunchEligible: false,
      dinnerEligible: false,
      provided: false,
      breakfastQty: 0,
      lunchQty: 0,
      dinnerQty: 0,
      breakfastRate: kBreakfastPerDiem,
      lunchRate: kLunchPerDiem,
      dinnerRate: kDinnerPerDiem,
    )
        : meals;

    Navigator.of(context).pop<KmMealResult>(
      KmMealResult(
        km: kmForReturn,
        meals: mealsForReturn,
        grandTotal: total,
        suggestedAccount: account,
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('KM & Repas'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.route), text: 'KM'),
            Tab(icon: Icon(Icons.restaurant), text: 'Repas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildKmTab(theme),
          _buildMealsTab(theme),
        ],
      ),
      bottomNavigationBar: _buildBottom(theme),
    );
  }

  /// Barre du bas — n’affiche QUE les infos de l’onglet actif
  Widget _buildBottom(ThemeData theme) {
    final isKmTab = _tab.index == 0;
    final km = _computeKm();
    final meals = _computeMeals();

    final chips = <Widget>[];
    if (isKmTab) {
      chips.addAll([
        _chip(
          label:
          'KM: ${km.eligibleKm.toStringAsFixed(2)} × ${km.kmRate.toStringAsFixed(2)} = ${km.kmAmount.toStringAsFixed(2)}',
          icon: Icons.directions_car_filled_rounded,
        ),
        if (km.excludedHomeCommute)
          _chip(label: 'Domicile-travail exclu', icon: Icons.block, color: Colors.orange),
        if (km.coveredByOrg)
          _chip(label: 'KM couverts (exclu)', icon: Icons.block, color: Colors.orange),
      ]);
    } else {
      chips.addAll([
        _chip(label: 'Repas: ${meals.totalMeals.toStringAsFixed(2)}', icon: Icons.restaurant_rounded),
        if (meals.provided)
          _chip(label: 'Repas fournis (exclus)', icon: Icons.block, color: Colors.orange),
      ]);
    }

    final primaryLabel =
    isKmTab ? 'Total KM: ${km.kmAmount.toStringAsFixed(2)}' : 'Total repas: ${meals.totalMeals.toStringAsFixed(2)}';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chips.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: chips),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.check_circle),
                    label: Text(primaryLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    Color? color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: color?.withOpacity(0.12),
      side: color != null ? BorderSide(color: color) : null,
    );
  }

  Widget _buildKmTab(ThemeData theme) {
    final km = _computeKm();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Kilométrage', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(
          controller: _distanceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Distance (km)',
            prefixIcon: Icon(Icons.route),
            helperText: 'Saisir la distance parcourue en kilomètres',
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _isHomeCommute,
          onChanged: (v) => setState(() => _isHomeCommute = v),
          title: const Text('Trajet domicile ↔ lieu habituel (exclu)'),
          subtitle: const Text('Non remboursable selon la politique'),
        ),
        SwitchListTile(
          value: _isCoveredByOrg,
          onChanged: (v) => setState(() => _isCoveredByOrg = v),
          title: const Text('KM couverts par l’organisation (exclu)'),
          subtitle: const Text('Ex.: véhicule fourni, réclamé par ailleurs'),
        ),
        const SizedBox(height: 12),
        _summaryTile(
          title: 'Éligible: ${km.eligibleKm.toStringAsFixed(2)} km × ${km.kmRate.toStringAsFixed(2)}',
          value: '${km.kmAmount.toStringAsFixed(2)} \$',
          icon: Icons.directions_car_filled_rounded,
        ),
      ],
    );
  }

  Widget _buildMealsTab(ThemeData theme) {
    final durationHours = _duration.inHours;
    final eligibleB = _breakfastEligible;
    final eligibleL = _lunchEligible;
    final eligibleD = _dinnerEligible;
    final meals = _computeMeals();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Repas', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_circle_outline),
                title: Text('Départ: ${_start.format(context)}'),
                onTap: () => _pickTime(start: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.stop_circle_outlined),
                title: Text('Retour: ${_end.format(context)}'),
                onTap: () => _pickTime(start: false),
              ),
            ),
          ],
        ),
        Text('Durée: $durationHours h'),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _mealsProvided,
          onChanged: (v) => setState(() => _mealsProvided = v),
          title: const Text('Repas fournis (exclusion)'),
          subtitle: const Text('Si fourni, le repas correspondant est exclu'),
        ),
        const Divider(height: 24),

        _mealRow(
          title: 'Déjeuner',
          eligible: eligibleB,
          qty: _bQty,
          onChanged: (v) => setState(() => _bQty = v),
          rate: kBreakfastPerDiem,
        ),
        const SizedBox(height: 8),

        _mealRow(
          title: 'Dîner',
          eligible: eligibleL,
          qty: _lQty,
          onChanged: (v) => setState(() => _lQty = v),
          rate: kLunchPerDiem,
        ),
        const SizedBox(height: 8),

        _mealRow(
          title: 'Souper',
          eligible: eligibleD,
          qty: _dQty,
          onChanged: (v) => setState(() => _dQty = v),
          rate: kDinnerPerDiem,
        ),
        const SizedBox(height: 16),

        _summaryTile(
          title: 'Total repas éligible',
          value: '${meals.totalMeals.toStringAsFixed(2)} \$.',
          icon: Icons.restaurant_rounded,
        ),
      ],
    );
  }

  Widget _mealRow({
    required String title,
    required bool eligible,
    required int qty,
    required void Function(int) onChanged,
    required double rate,
  }) {
    final disabled = _mealsProvided || !eligible;
    final color = disabled ? Colors.orange : Colors.green;
    final label = _mealsProvided ? 'fourni (exclu)' : (eligible ? 'éligible' : 'non éligible');

    return Row(
      children: [
        Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(title),
            subtitle: Text('$label • ${rate.toStringAsFixed(2)} \$'),
            leading: Icon(eligible ? Icons.check_circle : Icons.block, color: color),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: disabled || qty == 0 ? null : () => onChanged(qty - 1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$qty', style: const TextStyle(fontSize: 16)),
            IconButton(
              onPressed: disabled ? null : () => onChanged(qty + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
