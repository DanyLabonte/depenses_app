import 'package:flutter/material.dart';
import 'package:depenses_app/l10n/s.dart';
import 'package:depenses_app/screens/home_screen.dart';
import 'package:depenses_app/screens/history_screen.dart';
import 'package:depenses_app/screens/feedback_screen.dart';
import 'package:depenses_app/screens/profile_screen.dart';
import 'package:depenses_app/services/auth_service.dart';

class AppShell extends StatefulWidget {
  final String currentUserEmail;
  const AppShell({super.key, required this.currentUserEmail});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    String title;
    switch (_index) {
      case 0:
        title = s.homeTitle;
        break;
      case 1:
        title = s.historyTitle;
        break;
      case 2:
        title = s.suggestionTitle;
        break;
      case 3:
        title = s.profileTitle;
        break;
      default:
        title = s.appTitle;
    }

    final pages = [
      HomeScreen(currentUserEmail: widget.currentUserEmail),
      HistoryScreen(currentUserEmail: widget.currentUserEmail),
      FeedbackScreen(currentUserEmail: widget.currentUserEmail),
      ProfileScreen(currentUserEmail: widget.currentUserEmail),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: s.signOut,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(s.signOut),
                  content: Text(s.signOutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(s.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(s.confirm),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await AuthService().signOut();
                if (!mounted) return;
                Navigator.of(context).pop(); // retour à l’écran précédent (connexion)
              }
            },
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_rounded),
            selectedIcon: const Icon(Icons.home_filled),
            label: s.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_toggle_off_rounded),
            selectedIcon: const Icon(Icons.history_rounded),
            label: s.historyTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.mail_outline_rounded),
            selectedIcon: const Icon(Icons.mail_rounded),
            label: s.suggestionTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: s.profileTitle,
          ),
        ],
      ),
    );
  }
}
