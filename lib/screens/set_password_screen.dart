import "package:flutter/material.dart";
typedef PasswordUpdater = Future<void> Function(String newPassword);

class SetPasswordScreen extends StatefulWidget {
  final PasswordUpdater onUpdate;
  const SetPasswordScreen({super.key, required this.onUpdate});
  @override State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}
class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _f1 = TextEditingController(), _f2 = TextEditingController();
  bool _busy = false;
  @override void dispose(){ _f1.dispose(); _f2.dispose(); super.dispose(); }
  Future<void> _submit() async {
    final a = _f1.text.trim(), b = _f2.text.trim();
    if (a.isEmpty || a.length < 8) { _snack("Mot de passe trop court (min 8)."); return; }
    if (a != b) { _snack("Les mots de passe ne correspondent pas."); return; }
    setState(()=>_busy=true);
    try { await widget.onUpdate(a); if (mounted) Navigator.of(context).pop(true); }
    catch (e) { _snack("Ãƒâ€°chec : $e"); }
    finally { if (mounted) setState(()=>_busy=false); }
  }
  void _snack(String m)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  @override Widget build(BuildContext ctx){
    return Scaffold(
      appBar: AppBar(title: const Text("DÃƒÂ©finir un mot de passe")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller:_f1,obscureText:true,decoration: const InputDecoration(labelText:"Nouveau mot de passe")),
          const SizedBox(height:12),
          TextField(controller:_f2,obscureText:true,decoration: const InputDecoration(labelText:"Confirmer le mot de passe")),
          const SizedBox(height:24),
          ElevatedButton(onPressed:_busy?null:_submit, child: const Text("Enregistrer")),
        ]),
      ),
    );
  }
}