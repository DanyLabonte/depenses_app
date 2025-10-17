import 'package:flutter/material.dart';
import 'package:depenses_app/core/l10n/gen/s.dart';

import 'package:depenses_app/screens/home_screen.dart';
import 'package:depenses_app/screens/history_screen.dart';
import 'package:depenses_app/screens/feedback_screen.dart';
import 'package:depenses_app/screens/profile_screen.dart';
import 'package:depenses_app/services/auth_service.dart';

import '../widgets/role_dropdown.dart';
import '../services/role_store.dart';
import '../models/user_roles.dart';
import 'package:depenses_app/screens/sign_in_screen.dart';

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

    final pages = <Widget>[
      HomeScreen(currentUserEmail: widget.currentUserEmail),
      HistoryScreen(currentUserEmail: widget.currentUserEmail),
      FeedbackScreen(currentUserEmail: widget.currentUserEmail),
      ProfileScreen(currentUserEmail: widget.currentUserEmail),
    ];

    return Scaffold(
      appBar: AppBar( 
        title: Text(title),
        
      ),

      // Affiche la page sélectionnée
      body: pages[_index],

      // Barre de navigation du bas
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: s.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: s.historyTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.lightbulb_outline),
            selectedIcon: const Icon(Icons.lightbulb),
            label: s.suggestionTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: s.profileTitle,
          ),
        ],
      ),
    );
  }
}


