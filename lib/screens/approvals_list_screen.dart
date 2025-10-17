// lib/screens/approvals_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import '../models/user_roles.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import '../services/auth_service.dart';

import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
import '../models/user_roles.dart';
import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../widgets/role_dropdown.dart';
/// ?cran pour la liste des demandes de r?le ? Chef divisionnaire ?
/// Affich? uniquement pour les administrateurs.
class ApprovalsListScreen extends StatelessWidget {
  static const route = '/approvals';
  const ApprovalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService(); // Service unique en m?moire
    final reqs = auth.pendingRoleRequests;

    return Scaffold(
      appBar: AppBar(actions: const [RoleDropdown()], title: const Text('Demandes de r?le')),
      body: reqs.isEmpty
          ? const Center(
        child: Text(
          'Aucune demande en attente',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final r = reqs[index];
          final name = r['name'] ?? ''; // si pr?sent
          final email = r['email'] ?? '';
          final role = r['requestedRole'] ?? 'Chef divisionnaire';

          return Card(
            child: ListTile(
              title: Text(name.isEmpty ? email : name),
              subtitle: Text('$email - $role'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      auth.rejectChef(email);
                      (context as Element).markNeedsBuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demande refus?e'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Refuser'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      auth.approveChef(email);
                      (context as Element).markNeedsBuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demande approuv?e'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approuver'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


