import 'package:flutter/material.dart';
import 'package:depenses_app/l10n/s.dart';
import 'package:depenses_app/screens/new_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  final String currentUserEmail;
  const HomeScreen({super.key, required this.currentUserEmail});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Dépenses', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Bienvenue dans votre application de gestion des dépenses.\n'
                  'Vous pouvez créer une nouvelle réclamation ou consulter l’historique via la barre ci-dessous.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewExpenseScreen(
                    currentUserEmail: currentUserEmail,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(s.newClaim),
          ),
        ],
      ),
    );
  }
}
