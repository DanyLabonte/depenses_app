// lib/screens/approvals_list_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Écran pour la liste des demandes de rôle « Chef divisionnaire »
/// Affiché uniquement pour les administrateurs.
class ApprovalsListScreen extends StatelessWidget {
  static const route = '/approvals';
  const ApprovalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService(); // Service unique en mémoire
    final reqs = auth.pendingRoleRequests;

    return Scaffold(
      appBar: AppBar(title: const Text('Demandes de rôle')),
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
          final name = r['name'] ?? ''; // si présent
          final email = r['email'] ?? '';
          final role = r['requestedRole'] ?? 'Chef divisionnaire';

          return Card(
            child: ListTile(
              title: Text(name.isEmpty ? email : name),
              subtitle: Text('$email — $role'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      auth.rejectChef(email);
                      (context as Element).markNeedsBuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demande refusée'),
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
                          content: Text('Demande approuvée'),
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
