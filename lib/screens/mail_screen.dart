import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:flutter/material.dart';
import '../l10n/s.dart';

class MailScreen extends StatelessWidget {
  static const route = '/mail';

  final String currentUserEmail;
  const MailScreen({super.key, required this.currentUserEmail});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.mail)),
      body: Center(
        child: Text('Commentaire / feedback Ã¢â‚¬â€ utilisateur : $currentUserEmail'),
      ),
    );
  }
}

