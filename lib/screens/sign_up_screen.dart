import 'package:flutter/material.dart';
import 'package:depenses_app/widgets/roles_selector.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _pwdCtrl       = TextEditingController();
  final _pwd2Ctrl      = TextEditingController();

  bool _pwdVisible  = false;
  bool _pwd2Visible = false;
  bool _acceptedTerms = false;

  // Rôles sélectionnés (multi) - par défaut Bénévole SAC
  Set<String> _selectedRoles = {'VOL_SAC'};

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ requis' : null;

  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ requis';
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!r.hasMatch(v.trim())) return 'Adresse courriel invalide';
    return null;
  }

  String? _password(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis';
    if (v.length < 8) return 'Au moins 8 caractères';
    return null;
  }

  String? _password2(String? v) {
    if (v != _pwdCtrl.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  void _submit() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez accepter les conditions.')),
      );
      return;
    }
    if (_formKey.currentState?.validate() != true) return;

    // TODO: intégrer le vrai service d’inscription + chaîne d’approbation selon _selectedRoles
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Inscription… Rôles: ${_selectedRoles.join(", ")}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Prénom / Nom
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                              ),
                              validator: _required,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                              ),
                              validator: _required,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Courriel',
                        ),
                        validator: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 12),

                      // Mot de passe
                      TextFormField(
                        controller: _pwdCtrl,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() {
                              _pwdVisible = !_pwdVisible;
                            }),
                            icon: Icon(
                              _pwdVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                        ),
                        obscureText: !_pwdVisible,
                        validator: _password,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 12),

                      // Confirmation
                      TextFormField(
                        controller: _pwd2Ctrl,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() {
                              _pwd2Visible = !_pwd2Visible;
                            }),
                            icon: Icon(
                              _pwd2Visible ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                        ),
                        obscureText: !_pwd2Visible,
                        validator: _password2,
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: 16),

                      // Rôles (multi)
                      RolesSelector(
                        initial: _selectedRoles,
                        onChanged: (set) {
                          setState(() => _selectedRoles = {...set});
                        },
                      ),

                      const SizedBox(height: 16),

                      // Conditions d’utilisation
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (v) =>
                                setState(() => _acceptedTerms = v ?? false),
                          ),
                          const Flexible(
                            child: Text(
                              "J’accepte les conditions d’utilisation",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Boutons
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text("Créer mon compte"),
                      ),

                      const SizedBox(height: 8),

                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.login),
                        label: const Text('Retour à la connexion'),
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