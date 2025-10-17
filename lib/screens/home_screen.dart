import 'package:depenses_app/core/l10n/gen/s.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import '../models/user_roles.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import 'package:flutter/material.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import '../models/user_roles.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import 'package:depenses_app/core/l10n/gen/s.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import '../models/user_roles.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import 'package:depenses_app/screens/new_expense_screen.dart';

import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import '../models/user_roles.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
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
          Text('D?penses', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Bienvenue dans votre application de gestion des d?penses.\n'
                  "Vous pouvez créer une nouvelle réclamation ou consulter lâ€™historique via la barre ci-dessous.",
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




