import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:flutter/material.dart';
import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:depenses_app/services/auth_service.dart';
import 'package:depenses_app/screens/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserEmail;
  const ProfileScreen({super.key, required this.currentUserEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _displayName;
  String? _division;
  DateTime? _joinDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = AuthService();
    final p = await a.profileForEmail(widget.currentUserEmail);
    final div = await a.getUserDivision(widget.currentUserEmail);
    final jd = await a.getUserJoinDate(widget.currentUserEmail);
    setState(() {
      _displayName = p?.displayName?.trim().isEmpty == true ? null : p?.displayName;
      _division = div;
      _joinDate = jd;
    });
  }

  Future<void> _confirmDelete() async {
    final s = S.of(context);
    final ok1 = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est permanente et supprimera vos donn?es locales (d?mo). Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.confirm)),
        ],
      ),
    );
    if (ok1 != true) return;

    final ok2 = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Tapez "SUPPRIMER" pour confirmer la suppression.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
    if (ok2 == true) {
      await AuthService().deleteAccount(widget.currentUserEmail);
      if (!mounted) return;
      Navigator.of(context).pop(); // retour
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-t?te / avatar + nom
          Material(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.5),
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                child: Text(
                  (_displayName ?? widget.currentUserEmail)
                      .trim()
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .map((e) => e.characters.first.toUpperCase())
                      .join(),
                ),
              ),
              title: Text(_displayName ?? widget.currentUserEmail.split('@').first),
              subtitle: Text(widget.currentUserEmail),
              trailing: IconButton(
                tooltip: s.signOut,
                icon: const Icon(Icons.logout_rounded),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(s.signOut),
                      content: Text(s.signOutConfirm),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
                        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.confirm)),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await AuthService().signOut();
if (!mounted) return;
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const SignInScreen()),
  (route) => false,
);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Division
          _RowInfo(
            icon: Icons.apartment_rounded,
            label: 'Division',
            value: _division ?? '-',
            locked: true,
          ),
          const SizedBox(height: 8),

          // Date dâ€™adhï¿½sion
          _RowInfo(
            icon: Icons.event_available_rounded,
            label: 'Date dâ€™adhï¿½sion',
            value: _joinDate == null
                ? '-'
                : '${_joinDate!.year}-${_joinDate!.month.toString().padLeft(2, '0')}-${_joinDate!.day.toString().padLeft(2, '0')}',
            locked: true,
          ),
          const SizedBox(height: 16),

          // Langue
          DropdownButtonFormField<String>(
            value: Localizations.localeOf(context).languageCode == 'fr' ? 'fr' : 'en',
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.language_rounded),
              labelText: 'Langue',
            ),
            items: const [
              DropdownMenuItem(value: 'fr', child: Text('Fran?ais')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (_) {
              // Ton m?canisme dâ€™internationalisation r?actif (si tu en as un)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Changement de langue simul? (d?mo).')),
              );
            },
          ),
          const SizedBox(height: 12),

          // Th?me
          DropdownButtonFormField<String>(
            value: 'system',
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.color_lens_outlined),
              labelText: 'Th?me',
            ),
            items: const [
              DropdownMenuItem(value: 'system', child: Text('Syst?me')),
              DropdownMenuItem(value: 'light', child: Text('Clair')),
              DropdownMenuItem(value: 'dark', child: Text('Sombre')),
            ],
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Changement de th?me simul? (d?mo).')),
              );
            },
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Astuce : sur le Web, les photos sont stock?es en local (navigateur).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),

          // Supprimer le compte
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('Supprimer le compte'),
          ),
        ],
      ),
    );
  }
}

class _RowInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool locked;
  const _RowInfo({
    required this.icon,
    required this.label,
    required this.value,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: locked ? const Icon(Icons.lock_rounded, size: 18) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
    );
  }
}




