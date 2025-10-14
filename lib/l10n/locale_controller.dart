import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrôleur simple (singleton) pour la langue de l’app.
/// - Persiste la locale choisie
/// - Notifie les listeners quand elle change
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _kPrefKey = 'app_locale';
  Locale? _locale;

  /// Locale actuelle (FR par défaut si rien n’a encore été choisi).
  Locale get locale => _locale ?? const Locale('fr');

  /// À appeler une seule fois au démarrage (déjà fait dans main()).
  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_kPrefKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  /// Change la langue (API “verbeuse”).
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPrefKey, locale.languageCode);
  }

  /// Alias pratique: `set('fr')` ou `set('en')`.
  Future<void> set(String languageCode) => setLocale(Locale(languageCode));
}
