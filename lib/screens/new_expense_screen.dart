import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:flutter/material.dart';
import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:depenses_app/screens/expense_form_screen.dart';

class NewExpenseScreen extends StatelessWidget {
  final String currentUserEmail;
  const NewExpenseScreen({super.key, required this.currentUserEmail});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.newClaim)),
      body: ExpenseFormScreen(currentUserEmail: currentUserEmail),
    );
  }
}


