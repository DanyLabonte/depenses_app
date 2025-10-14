import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:depenses_app/l10n/s.dart';
import 'package:depenses_app/models/user_role.dart';
import 'package:depenses_app/services/auth_service.dart';
import 'package:depenses_app/screens/verify_email_screen.dart';

class _DivisionRef {
  final String code;
  final String label;
  const _DivisionRef(this.code, this.label);
}

const _kDivisions = <_DivisionRef>[
  _DivisionRef('PS0062', 'DIVISION 0062 QUÉBEC'),
  _DivisionRef('PS0094', 'DIVISION 0094 SHERBROOKE'),
  _DivisionRef('PS0158', 'DIVISION 0158 DRUMMONDVILLE'),
  _DivisionRef('PS0233', 'DIVISION 0233 TROIS-RIVIÈRES'),
  _DivisionRef('PS0280', 'DIVISION 0280 SAINTE-HYACINTHE'),
  _DivisionRef('PS0300', 'DIVISION 0300 SAGUENAY'),
  _DivisionRef('PS0309', 'DIVISION 0309 BOIS FRANC ÉRABLE'),
  _DivisionRef('PS0335', 'DIVISION 0335 SAINT-GEORGES'),
  _DivisionRef('PS0452', 'DIVISION 0452 MONTRÉAL'),
  _DivisionRef('PS0549', 'DIVISION 0549 BAIE-COMEAU'),
  _DivisionRef('PS0789', 'DIVISION 0789 LAURENTIDES'),
  _DivisionRef('PS0843', 'DIVISION 0843 HAUT-RICHELIEU'),
  _DivisionRef('PS0883', 'DIVISION 0883 LANAUDIÈRES'),
  _DivisionRef('PS0907', 'DIVISION 0907 GATINEAU'),
  _DivisionRef('PS0971', 'DIVISION 0971 LAVAL'),
  _DivisionRef('PS1002', 'DIVISION 1002 LONGUEUIL'),
  _DivisionRef('PC0001', 'PATROUILLE CANINE SECTEUR NORD'),
  _DivisionRef('PC0002', 'PATROUILLE CANINE SECTEUR SUD'),
  _DivisionRef('PC0003', 'PATROUILLE CANINE SECTEUR EST'),
  _DivisionRef('PC0004', 'PATROUILLE CANINE SECTEUR OUEST'),
  _DivisionRef('CL0001', 'CLINIQUE'),
  _DivisionRef('EP0001', 'ÉQUIPE PROVINCIAL'),
  _DivisionRef('DIRSAC', 'DIRECTION DES SERVICES À LA COLLECTIVITÉ'),
];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();

  final Set<UserRole> _selectedRoles = {UserRole.volunteer};
  _DivisionRef? _selectedDivision;

  bool _loading = false;
  bool _pwdVisible = false;
  bool _pwd2Visible = false;

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? S.of(context).requiredField : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return S.of(context).requiredField;
    final ok = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(v.trim());
    if (!ok) return S.of(context).emailInvalid;
    return null;
  }

  String? _validatePwd(String? v) {
    if (v == null || v.isEmpty) return S.of(context).requiredField;
    if (v.length < 8) return 'Au moins 8 caractères';
    final upper = RegExp(r'[A-Z]').hasMatch(v);
    final lower = RegExp(r'[a-z]').hasMatch(v);
    final digit = RegExp(r'\d').hasMatch(v);
    final spec = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\];/\\]').hasMatch(v);
    if (!(upper && lower && digit && spec)) {
      return 'Doit contenir majuscule, minuscule, chiffre et caractère spécial';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDivision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez votre division.')),
      );
      return;
    }
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez au moins un rôle.')),
      );
      return;
    }

    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    final name = '$first $last'.trim();
    final email = _emailCtrl.text.trim();
    final password = _pwdCtrl.text;
    final roles = _selectedRoles.toList();
    final divisionCode = _selectedDivision!.code;

    setState(() => _loading = true);
    try {
      await AuthService().sendVerificationCode(email);

      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VerifyEmailScreen(
          name: name,
          email: email,
          password: password,
          roles: roles,
          divisionCode: divisionCode,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _roleChip(UserRole r, {bool enabled = true}) {
    final chosen = _selectedRoles.contains(r);
    return FilterChip(
      selected: chosen,
      label: Text(r.fr),
      onSelected: enabled
          ? (sel) {
        setState(() {
          if (sel) {
            _selectedRoles.add(r);
          } else {
            _selectedRoles.remove(r);
            if (_selectedRoles.isEmpty) {
              _selectedRoles.add(UserRole.volunteer);
            }
          }
        });
      }
          : null,
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.signUpTitle),
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Prénom / Nom
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                                prefixIcon: Icon(Icons.badge_rounded),
                              ),
                              validator: _required,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: _required,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Courriel
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        decoration: InputDecoration(
                          labelText: s.emailLabel,
                          prefixIcon: const Icon(Icons.email_rounded),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 12),

                      // Division
                      DropdownButtonFormField<_DivisionRef>(
                        value: _selectedDivision,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Quelle est votre division ?',
                          prefixIcon: Icon(Icons.apartment_rounded),
                        ),
                        items: _kDivisions
                            .map(
                              (d) => DropdownMenuItem(
                            value: d,
                            child: Text('${d.code} - ${d.label}',
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                            .toList(),
                        onChanged: (d) => setState(() => _selectedDivision = d),
                        validator: (v) =>
                        v == null ? 'Sélection requise' : null,
                      ),
                      const SizedBox(height: 12),

                      // Mot de passe
                      TextFormField(
                        controller: _pwdCtrl,
                        obscureText: !_pwdVisible,
                        decoration: InputDecoration(
                          labelText: s.passwordLabel,
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_pwdVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _pwdVisible = !_pwdVisible),
                          ),
                        ),
                        validator: _validatePwd,
                      ),
                      const SizedBox(height: 8),

                      // Confirmation
                      TextFormField(
                        controller: _pwd2Ctrl,
                        obscureText: !_pwd2Visible,
                        decoration: InputDecoration(
                          labelText: s.passwordConfirmLabel,
                          prefixIcon:
                          const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_pwd2Visible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _pwd2Visible = !_pwd2Visible),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return S.of(context).requiredField;
                          }
                          if (v != _pwdCtrl.text) {
                            return s.passwordMismatch;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Rôles (multi)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Rôles (plusieurs possibles)'),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _roleChip(UserRole.volunteer),
                          _roleChip(UserRole.operations, enabled: false),
                          _roleChip(UserRole.expenses, enabled: false),
                          _roleChip(UserRole.finance),
                          _roleChip(UserRole.admin),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _submit,
                          icon: const Icon(Icons.send_rounded),
                          label: Text(s.continueLabel),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.login_rounded),
                        label: Text(s.backToSignIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
