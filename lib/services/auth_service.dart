// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:depenses_app/models/user_role.dart';

/// Service dÃ¢â‚¬â„¢authentification/stockage local (POC)
/// - Comptes persist?s (SharedPreferences JSON)
/// - V?rification dÃ¢â‚¬â„¢email par code (6 chiffres / 15 min)
/// - Inscription avec MULTI r?les + stockage division + date dÃ¢â‚¬â„¢adhÃ¯Â¿Â½sion
/// - Historique des demandes de r?les (pending/approved/rejected)
/// - Notif "finance" simul?e
class AuthService {
  // ---------------- Singleton ----------------
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  // ---------------- Storage keys -------------
  static const _kUsers = 'auth_users_v2';
  static const _kPending = 'role_pending';
  static const _kApproved = 'role_approved';
  static const _kRejected = 'role_rejected';
  static const _kSeeded = 'auth_seeded_v2';

  // V?rif email (simu) - non utilis?s directement ici mais conserv?s pour compat
  static const _kVerifyCodeValue = 'verify.code.value';
  static const _kVerifyCodeEmail = 'verify.code.email';

  // Division & date dÃ¢â‚¬â„¢adhÃ¯Â¿Â½sion (par email)
  static const _kUserDivisionCode = 'user.division.code';
  static const _kUserJoinDate = 'user.join.date';

  // (optionnel) utilisateur courant pour un futur vrai signOut()
  static const _kCurrentUser = 'auth_current_user';

  // ---------------- In-memory ----------------
  /// Utilisateurs persist?s (liste de maps normalis?s)
  /// user schema:
  /// {
  ///   'name': String,
  ///   'email': String (lowercase),
  ///   'passwordHash': String (sha256),
  ///   'role': String,                 // compat: r?le principal (hist.)
  ///   'roles': List<String>,          // multi-r?les (labels)
  ///   'approved': bool,
  ///   'lastPasswordChange': String (ISO8601),
  ///   'passwordHistory': List<String> (sha256, plus r?cent en t?te)
  /// }
  final List<Map<String, dynamic>> _users = [];

  /// Demandes de r?le
  final List<Map<String, String>> _pendingRoleRequests = [];
  final List<Map<String, String>> _approvedRoleRequests = [];
  final List<Map<String, String>> _rejectedRoleRequests = []; // {. , reason}

  /// Tickets "mot de passe oubli?" (m?moire uniquement)
  /// resetId -> { email, code, expiresAt }
  final Map<String, Map<String, dynamic>> _resetTickets = {};

  /// Codes de v?rification email (m?moire, dur?e 15 min)
  /// email -> { code, expiresAt }
  final Map<String, Map<String, dynamic>> _emailVerifyCodes = {};

  // ---------------- Helpers ------------------
  String _norm(String email) => email.trim().toLowerCase();
  String _hash(String s) => sha256.convert(utf8.encode(s)).toString();

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  List<Map<String, dynamic>> _decodeListMapDynamic(String? s) {
    if (s == null || s.isEmpty) return [];
    final raw = jsonDecode(s);
    if (raw is List) {
      return raw
          .cast<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList()
          .cast<Map<String, dynamic>>();
    }
    return [];
  }

  List<Map<String, String>> _toStringMapList(List<Map<String, dynamic>> src) {
    return src
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))
        .toList();
  }

  Future<void> _loadAll() async {
    final p = await SharedPreferences.getInstance();

    _users
      ..clear()
      ..addAll(_decodeListMapDynamic(p.getString(_kUsers)));

    _pendingRoleRequests
      ..clear()
      ..addAll(_toStringMapList(_decodeListMapDynamic(p.getString(_kPending))));

    _approvedRoleRequests
      ..clear()
      ..addAll(_toStringMapList(_decodeListMapDynamic(p.getString(_kApproved))));

    _rejectedRoleRequests
      ..clear()
      ..addAll(_toStringMapList(_decodeListMapDynamic(p.getString(_kRejected))));
  }

  Future<void> _saveAll() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUsers, jsonEncode(_users));
    await p.setString(_kPending, jsonEncode(_pendingRoleRequests));
    await p.setString(_kApproved, jsonEncode(_approvedRoleRequests));
    await p.setString(_kRejected, jsonEncode(_rejectedRoleRequests));
  }

  Map<String, dynamic>? _findUser(String emailNorm) {
    for (final u in _users) {
      if (_norm(u['email'] ?? '') == emailNorm) return u;
    }
    return null;
  }

  // ====== Seed comptes de d?mo =======
  Future<void> ensureSeed() async {
    final p = await SharedPreferences.getInstance();
    final already = p.getBool(_kSeeded) ?? false;
    await _loadAll();
    if (already) return;

    final adminHash = _hash('Admin123!');
    final userHash = _hash('User123!');

    _users.addAll([
      {
        'name': 'Admin D?mo',
        'email': 'admin@sja.ca',
        'passwordHash': adminHash,
        'role': 'Administrateur',
        'roles': <String>['Administrateur', 'Responsable finance'],
        'approved': true,
        'lastPasswordChange':
        DateTime.now().subtract(const Duration(days: 35)).toIso8601String(),
        'passwordHistory': <String>[adminHash],
      },
      {
        'name': 'Benevole D?mo',
        'email': 'user@example.com',
        'passwordHash': userHash,
        'role': 'B?n?vole SAC',
        'roles': <String>['B?n?vole SAC'],
        'approved': true,
        'lastPasswordChange':
        DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'passwordHistory': <String>[userHash],
      },
    ]);

    // Exemple de demande en attente
    _pendingRoleRequests.add({
      'name': 'Alice Tremblay',
      'email': 'alice@example.com',
      'requestedRole': 'Chef divisionnaire',
    });

    await _saveAll();
    await p.setBool(_kSeeded, true);
  }

  // ===== V?rification email (simu)
  Future<void> sendVerificationCode(String email) async {
    final e = _norm(email);
    final rand = Random.secure();
    final code = List.generate(6, (_) => rand.nextInt(10)).join();
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));
    _emailVerifyCodes[e] = {
      'code': code,
      'expiresAt': expiresAt.toIso8601String(),
    };
    debugPrint(
        '[AuthService] Code envoy? ? $email => $code (expire $expiresAt)');
    await Future.delayed(const Duration(milliseconds: 120));
  }

  Future<bool> verifyEmailCode(String email, String code) async {
    final e = _norm(email);
    final entry = _emailVerifyCodes[e];
    if (entry == null) return false;
    final stored = (entry['code'] ?? '').toString();
    final exp = _parseDate(entry['expiresAt']);
    if (exp == null || DateTime.now().isAfter(exp)) {
      _emailVerifyCodes.remove(e);
      return false;
    }
    final ok = stored == code.trim();
    if (ok) _emailVerifyCodes.remove(e);
    await Future.delayed(const Duration(milliseconds: 80));
    return ok;
  }

  /// Validation de base de lÃ¢â‚¬â„¢email (+ duplication locale)
  Future<String?> validateEmail(String email) async {
    final e = _norm(email);

    final formatOk =
        RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(e) &&
            !e.contains('..') &&
            !e.endsWith('.');
    if (!formatOk) return 'Adresse invalide.';

    const disposable = {
      'mailinator.com',
      'yopmail.com',
      'tempmail.com',
      '10minutemail.com'
    };
    final domain = e.split('@').last;
    if (disposable.contains(domain)) return 'Adresse jetable non autoris?e.';

    await _loadAll();
    if (_findUser(e) != null) return 'Cette adresse est d?j? utilis?e.';
    return null;
  }

  // ===== Division & Date dÃ¢â‚¬â„¢adhÃ¯Â¿Â½sion (stockage local par email)
  Future<void> setUserDivision(String email, String? divisionCode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('$_kUserDivisionCode:${_norm(email)}', divisionCode ?? '');
  }

  Future<String?> getUserDivision(String email) async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString('$_kUserDivisionCode:${_norm(email)}');
    if (v == null || v.isEmpty) return null;
    return v;
  }

  Future<void> setUserJoinDate(String email, DateTime when) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        '$_kUserJoinDate:${_norm(email)}', when.toIso8601String());
  }

  Future<DateTime?> getUserJoinDate(String email) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('$_kUserJoinDate:${_norm(email)}');
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  // ===== Inscription / r?les
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _loadAll();
    final e = _norm(email);
    if (_findUser(e) != null) {
      throw Exception('Un compte existe d?j? pour cet email.');
    }

    final approved = !role.requiresApproval;
    final now = DateTime.now();
    final hash = _hash(password);

    final user = {
      'name': name.trim(),
      'email': e,
      'passwordHash': hash,
      'role': _roleLabel(role),
      'roles': <String>[_roleLabel(role)],
      'approved': approved,
      'lastPasswordChange': now.toIso8601String(),
      'passwordHistory': <String>[hash],
    };

    _users.add(user);

    if (!approved) {
      _pendingRoleRequests.add({
        'name': user['name'] as String,
        'email': e,
        'requestedRole': _roleLabel(role),
      });
    }

    await _saveAll();
    return !approved; // true => en attente / false => actif
  }

  /// Inscription avec MULTI r?les + division (utilis?e par VerifyEmailScreen)
  Future<bool> registerWithRoles({
    required String name,
    required String email,
    required String password,
    required List<UserRole> roles,
    String? divisionCode,
  }) async {
    if (roles.isEmpty) throw Exception('Aucun r?le fourni.');
    await _loadAll();
    final e = _norm(email);
    if (_findUser(e) != null) {
      throw Exception('Un compte existe d?j? pour cet email.');
    }

    final now = DateTime.now();
    final hash = _hash(password);

    final needsApproval = roles.any((r) => r.requiresApproval);
    final primary = roles.first;

    final user = {
      'name': name.trim(),
      'email': e,
      'passwordHash': hash,
      'role': _roleLabel(primary), // compat
      'roles': roles.map(_roleLabel).toList(), // multi
      'approved': !needsApproval,
      'lastPasswordChange': now.toIso8601String(),
      'passwordHistory': <String>[hash],
    };

    _users.add(user);

    if (needsApproval) {
      for (final r in roles.where((r) => r.requiresApproval)) {
        _pendingRoleRequests.add({
          'name': user['name'] as String,
          'email': e,
          'requestedRole': _roleLabel(r),
        });
      }
    }

    await _saveAll();

    // On garde les infos saisies ? lÃ¢â‚¬â„¢inscription
    await setUserDivision(email, divisionCode);
    await setUserJoinDate(email, DateTime.now());

    return needsApproval; // true => en attente / false => actif
  }

  Future<Map<String, dynamic>> createAccount({
    required String name,
    required String email,
    required String password,
    required String requestedRole,
  }) async {
    final role = _roleFromLegacy(requestedRole);
    final needsApproval = await register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    return {
      'name': name.trim(),
      'email': _norm(email),
      'role': _roleLabel(role),
      'approved': !needsApproval,
    };
  }

  // ===== Connexion / D?connexion
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    await _loadAll();
    final e = _norm(email);
    final u = _findUser(e);
    if (u == null) throw Exception('Identifiants invalides.');
    if ((_hash(password)) != (u['passwordHash'] ?? '')) {
      throw Exception('Identifiants invalides.');
    }
    final p = await SharedPreferences.getInstance();
    await p.setString(_kCurrentUser, e);
    return u;
  }

  Future<Map<String, dynamic>> quickSignIn({required String email}) async {
    await _loadAll();
    final e = _norm(email);
    final u = _findUser(e);
    if (u == null) throw Exception('Aucun compte trouv? pour $email.');
    final p = await SharedPreferences.getInstance();
    await p.setString(_kCurrentUser, e);
    return u;
  }

  /// D?connexion (POC) : on efface juste lÃ¢â‚¬â„¢utilisateur courant
  Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kCurrentUser);
  }

  /// Suppression de compte (POC) : supprime lÃ¢â‚¬â„¢utilisateur + prefs associ?es
  Future<void> deleteAccount(String email) async {
    await _loadAll();
    final e = _norm(email);

    _users.removeWhere((u) => _norm(u['email'] ?? '') == e);

    final p = await SharedPreferences.getInstance();
    await p.remove('$_kUserDivisionCode:$e');
    await p.remove('$_kUserJoinDate:$e');
    await p.remove(_kCurrentUser);

    await _saveAll();
  }

  // ===== Profil & rotation (optionnel)
  Future<_UserProfile?> profileForEmail(String email) async {
    await _loadAll();
    final u = _findUser(_norm(email));
    if (u == null) return null;
    return _UserProfile(
      email: u['email'] ?? '',
      displayName: u['name'] ?? '',
      lastPasswordChange: _parseDate(u['lastPasswordChange']),
    );
  }

  RotationInfo? rotationDue(DateTime? lastChange) {
    if (lastChange == null) return null;
    final now = DateTime.now();
    final diff = now.difference(lastChange).inDays;
    final overdue = diff > 30;
    final daysLeft = overdue ? 0 : (30 - diff);
    final lastStr =
        '${lastChange.year}-${lastChange.month.toString().padLeft(2, '0')}-${lastChange.day.toString().padLeft(2, '0')}';
    if (diff >= 25) {
      return RotationInfo(
          overdue: overdue, daysLeft: daysLeft, lastChangeStr: lastStr);
    }
    return null;
  }

  // ===== Changement de mot de passe
  bool _isReused(Map<String, dynamic> user, String newPassword) {
    final nh = _hash(newPassword);
    final current = (user['passwordHash'] ?? '') as String;
    final hist =
        (user['passwordHistory'] as List?)?.cast<String>() ?? const <String>[];
    final lastFive = <String>[
      if (current.isNotEmpty) current,
      ...hist,
    ].take(5).toList();
    return lastFive.contains(nh);
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _loadAll();
    final e = _norm(email);
    final u = _findUser(e);
    if (u == null) throw Exception('Compte introuvable.');

    if (_hash(currentPassword) != (u['passwordHash'] ?? '')) {
      throw Exception('Mot de passe actuel incorrect.');
    }
    if (_isReused(u, newPassword)) {
      throw Exception('Vous ne pouvez pas r?utiliser vos 5 derniers mots de passe.');
    }

    final oldHash = (u['passwordHash'] ?? '') as String;
    final nh = _hash(newPassword);

    final hist = List<String>.from(
        (u['passwordHistory'] as List?)?.cast<String>() ?? const <String>[]);
    if (oldHash.isNotEmpty) hist.insert(0, oldHash);
    while (hist.length > 5) hist.removeLast();

    u['passwordHash'] = nh;
    u['passwordHistory'] = hist;
    u['lastPasswordChange'] = DateTime.now().toIso8601String();

    await _saveAll();
  }

  // ===== Mot de passe oubli?
  Future<PasswordResetResponse> requestPasswordReset(String email) async {
    await _loadAll();
    final e = _norm(email);
    final u = _findUser(e);
    if (u == null) throw Exception('Aucun compte trouv? pour ce courriel.');

    final rand = Random.secure();
    final code = List.generate(6, (_) => rand.nextInt(10)).join();
    final resetId =
    List.generate(24, (_) => rand.nextInt(16).toRadixString(16)).join();
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));

    _resetTickets[resetId] = {
      'email': e,
      'code': code,
      'expiresAt': expiresAt.toIso8601String(),
    };

    debugPrint(
        '[AuthService] Reset $resetId pour $email / code=$code (expire $expiresAt)');
    return PasswordResetResponse(resetId);
  }

  Future<void> completePasswordReset({
    required String resetId,
    required String code,
    required String newPassword,
  }) async {
    await _loadAll();
    final t = _resetTickets[resetId];
    if (t == null) {
      throw Exception('Lien/identifiant de r?initialisation invalide.');
    }
    final expires = _parseDate(t['expiresAt']);
    if (expires == null || DateTime.now().isAfter(expires)) {
      _resetTickets.remove(resetId);
      throw Exception('Le code a expir?. Merci de refaire une demande.');
    }
    if ((t['code'] ?? '') != code.trim()) {
      throw Exception('Code invalide.');
    }

    final e = t['email'] as String;
    final u = _findUser(e);
    if (u == null) throw Exception('Compte introuvable.');

    if (_isReused(u, newPassword)) {
      throw Exception('Vous ne pouvez pas r?utiliser vos 5 derniers mots de passe.');
    }

    final oldHash = (u['passwordHash'] ?? '') as String;
    final nh = _hash(newPassword);

    final hist = List<String>.from(
        (u['passwordHistory'] as List?)?.cast<String>() ?? const <String>[]);
    if (oldHash.isNotEmpty) hist.insert(0, oldHash);
    while (hist.length > 5) hist.removeLast();

    u['passwordHash'] = nh;
    u['passwordHistory'] = hist;
    u['lastPasswordChange'] = DateTime.now().toIso8601String();

    _resetTickets.remove(resetId);
    await _saveAll();
  }

  // ===== API R?les (compat UI)
  List<Map<String, String>> get pendingRoleRequests =>
      List<Map<String, String>>.from(_pendingRoleRequests);

  Map<String, List<Map<String, String>>> userRoleStatus(String email) {
    final e = _norm(email);
    return {
      'pending':
      _pendingRoleRequests.where((r) => _norm(r['email'] ?? '') == e).toList(),
      'approved':
      _approvedRoleRequests.where((r) => _norm(r['email'] ?? '') == e).toList(),
      'rejected':
      _rejectedRoleRequests.where((r) => _norm(r['email'] ?? '') == e).toList(),
    };
  }

  void approveChef(String email) => approveRoleRequest(email);

  void rejectChef(String email, {String reason = 'Refus? par administrateur'}) =>
      rejectRoleRequest(email, reason: reason);

  void approveRoleRequest(String email) {
    final e = _norm(email);
    final idx =
    _pendingRoleRequests.indexWhere((r) => _norm(r['email'] ?? '') == e);
    if (idx >= 0) {
      final req = _pendingRoleRequests.removeAt(idx);
      _approvedRoleRequests.add(req);
      _saveAll();
    }
  }

  void rejectRoleRequest(String email, {String reason = 'Refus?'}) {
    final e = _norm(email);
    final idx =
    _pendingRoleRequests.indexWhere((r) => _norm(r['email'] ?? '') == e);
    if (idx >= 0) {
      final req = _pendingRoleRequests.removeAt(idx);
      _rejectedRoleRequests.add({...req, 'reason': reason});
      _saveAll();
    }
  }

  // --------------- Utils r?les ---------------
  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.volunteer:
        return 'B?n?vole SAC';
      case UserRole.finance:
        return 'Responsable finance';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.operations:
        return 'Op?rations';
      case UserRole.expenses:
        return 'D?penses';
    }
  }

  UserRole _roleFromLegacy(String label) {
    final l = label.trim().toLowerCase();
    if (l.contains('finance')) return UserRole.finance;
    if (l.contains('admin')) return UserRole.admin;
    if (l.contains('op?ration')) return UserRole.operations;
    if (l.contains('operation')) return UserRole.operations;
    if (l.contains('d?pense') || l.contains('depense')) return UserRole.expenses;
    return UserRole.volunteer;
  }

  Future<bool> userHasRole(String email, UserRole role) async {
    await _loadAll();
    final e = _norm(email);
    final u = _findUser(e);
    if (u == null) return false;

    String labelOf(UserRole r) => _roleLabel(r);

    final roles = (u['roles'] as List?)
        ?.map((v) => (v ?? '').toString())
        .toList() ??
        const <String>[];
    if (roles.contains(labelOf(role))) return true;

    final legacy = (u['role'] ?? '').toString();
    return legacy == labelOf(role);
  }

  // ===== Notifications finance (mock)
  Future<List<String>> getFinanceEmails() async => ['finance@sja.ca'];

  Future<void> notifyFinanceNewExpense({
    required String createdBy,
    required double amount,
    required String category,
  }) async {
    final finance = await getFinanceEmails();
    for (final f in finance) {
      debugPrint('?? [PUSH MOCK] To=$f | Nouvelle d?pense de $createdBy '
          '(${amount.toStringAsFixed(2)} \$) dans "$category"');
    }
  }
}

// ===== Mod?les auxiliaires expos?s ? lÃ¢â‚¬â„¢UI ===================================

class _UserProfile {
  final String email;
  final String displayName;
  final DateTime? lastPasswordChange;
  _UserProfile({
    required this.email,
    required this.displayName,
    required this.lastPasswordChange,
  });
}

class RotationInfo {
  final bool overdue; // true si > 30 jours depuis dernier changement
  final int daysLeft; // jours restants avant 30 jours
  final String lastChangeStr; // yyyy-mm-dd
  RotationInfo(
      {required this.overdue,
        required this.daysLeft,
        required this.lastChangeStr});
}

/// R?ponse de cr?ation de ticket de r?initialisation de mot de passe.
class PasswordResetResponse {
  final String resetId;
  PasswordResetResponse(this.resetId);
}


