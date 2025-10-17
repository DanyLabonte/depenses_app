import 'package:depenses_app/core/l10n/gen/s.dart';
// lib/screens/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:depenses_app/models/user_role.dart';
import 'package:depenses_app/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final List<UserRole> roles;
  final String? divisionCode; // AJOUT: division s?lectionn?e ? lÃ¢â‚¬â„¢inscription

  const VerifyEmailScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.roles,
    this.divisionCode,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  // Cooldown pour renvoi du code
  Timer? _timer;
  int _cooldown = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _startCooldown([int seconds = 30]) {
    setState(() => _cooldown = seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;
    try {
      await AuthService().sendVerificationCode(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code renvoy?.')),
      );
      _startCooldown(30);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _confirm() async {
    final s = S.of(context);
    if (_codeCtrl.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.codeInvalid)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // 1) V?rifier le code envoy? ? lÃ¢â‚¬â„¢email
      final ok = await AuthService().verifyEmailCode(
        widget.email,
        _codeCtrl.text.trim(),
      );
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.codeInvalid)),
        );
        return;
      }

      // 2) Enregistrer le compte avec MULTI R?LES + division
      final needsApproval = await AuthService().registerWithRoles(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        roles: widget.roles,
        divisionCode: widget.divisionCode, // passe la division si fournie
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            needsApproval
                ? 'Compte cr??. Approbation requise pour certains r?les.'
                : 'Compte cr?? et actif.',
          ),
        ),
      );

      // Retour ? l'?cran racine (ex: SignIn)
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.verificationTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.verificationSubtitle(widget.email)),
                const SizedBox(height: 12),

                TextField(
                  controller: _codeCtrl,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.codeLabel,
                    prefixIcon: const Icon(Icons.pin),
                  ),
                ),

                const SizedBox(height: 12),

                // R?les choisis (affichage)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.roles
                      .map(
                        (r) => const Chip(
                      label: Text('R?le s?lectionn?'),
                      avatar: Icon(Icons.verified_user, size: 18),
                    ),
                  )
                      .toList(),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _confirm,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(s.confirm),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _cooldown > 0 ? null : _resend,
                      child: Text(
                        _cooldown > 0
                            ? 'Renvoyer dans ${_cooldown}s'
                            : 'Renvoyer le code',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



