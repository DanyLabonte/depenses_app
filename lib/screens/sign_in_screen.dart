import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:flutter/material.dart';
import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:depenses_app/screens/app_shell.dart';
import 'package:depenses_app/screens/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _rememberMe = false;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    // TODO: remplace par ta vraie logique dÃ¢â‚¬â„¢authent (AuthService().signIn(...))
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppShell(currentUserEmail: _emailCtrl.text.trim()),
      ),
    );
  }

  void _onForgotPassword() {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.forgotPasswordTitle),
        content: Text(s.forgotPasswordSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final email = _emailCtrl.text.trim();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.checkInbox(email))),
              );
            },
            child: Text(s.sendReset),
          ),
        ],
      ),
    );
  }

  void _demoLogin(String emailLabel) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppShell(currentUserEmail: emailLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 64, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        s.signInTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: s.emailLabel,
                          prefixIcon: const Icon(Icons.alternate_email_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return s.requiredField;
                          if (!v.contains('@')) return s.emailInvalid;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: s.passwordLabel,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? s.requiredField : null,
                      ),
                      const SizedBox(height: 8),

                      // Remember + Forgot
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) => setState(() => _rememberMe = val ?? false),
                          ),
                          const Text('Rester connect?'),
                          const Spacer(),
                          TextButton(
                            onPressed: _onForgotPassword,
                            child: Text(s.forgotPasswordLink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _onSignIn,
                          icon: _loading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.login_rounded),
                          label: Text(s.signInButton),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Sign up
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(s.signUpTitle),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Theme.of(context).dividerColor, height: 1),
                      const SizedBox(height: 12),

                      // Demo section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          s.demoSectionTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => _demoLogin('volunteer@sja.ca'),
                            child: Text(s.demoVolunteer),
                          ),
                          OutlinedButton(
                            onPressed: () => _demoLogin('admin@sja.ca'),
                            child: Text(s.demoAdmin),
                          ),
                          OutlinedButton(
                            onPressed: () => _demoLogin('finance@sja.ca'),
                            child: Text(s.demoFinance),
                          ),
                        ],
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



