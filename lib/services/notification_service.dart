// lib/services/notification_service.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// Mod?le de notification
class NotificationMessage {
  final String to;            // email ou id utilisateur
  final String title;
  final String body;
  final NotificationChannel channel;
  final NotificationPriority priority;
  final String? dedupeKey;    // pour d?duplication/throttle
  final Map<String, dynamic>? data;

  const NotificationMessage({
    required this.to,
    required this.title,
    required this.body,
    this.channel = NotificationChannel.system,
    this.priority = NotificationPriority.normal,
    this.dedupeKey,
    this.data,
  });

  NotificationMessage copyWith({
    String? to,
    String? title,
    String? body,
    NotificationChannel? channel,
    NotificationPriority? priority,
    String? dedupeKey,
    Map<String, dynamic>? data,
  }) {
    return NotificationMessage(
      to: to ?? this.to,
      title: title ?? this.title,
      body: body ?? this.body,
      channel: channel ?? this.channel,
      priority: priority ?? this.priority,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      data: data ?? this.data,
    );
  }

  @override
  String toString() =>
      'NotificationMessage(to=$to, title="$title", body="$body", ch=$channel, prio=$priority, key=$dedupeKey, data=$data)';
}

enum NotificationChannel { system, approval, security, reminder }
enum NotificationPriority { low, normal, high, urgent }

/// Signature dÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢un "sink" (= destination de notification)
typedef NotificationSink = FutureOr<void> Function(NotificationMessage msg);

/// Service centralis? - extensible (console, SnackBar, FCM/APNs, etc.)
class NotificationService {
  NotificationService._();
  static final NotificationService _i = NotificationService._();
  factory NotificationService() => _i;

  // Sinks enregistr?s (console par d?faut)
  final List<NotificationSink> _sinks = [_consoleSink];

  // Anti-spam simple: dedupeKey -> timestamp dernier envoi
  final Map<String, DateTime> _lastSent = {};

  // T?ches planifi?es
  final Map<String, Timer> _scheduled = {}; // scheduleId -> Timer

  /// Ajoute un sink (ex.: FCM, APNs, webhook.)
  void addSink(NotificationSink sink) {
    if (!_sinks.contains(sink)) _sinks.add(sink);
  }

  /// Retire un sink
  void removeSink(NotificationSink sink) => _sinks.remove(sink);

  /// Envoi direct (API r?tro-compatible)
  static void send({
    required String to,
    required String title,
    required String body,
  }) {
    NotificationService().sendMessage(NotificationMessage(to: to, title: title, body: body));
  }

  /// Envoi avec options (canal, priorit?, data, d?duplication)
  Future<void> sendMessage(NotificationMessage msg, {Duration throttle = const Duration(seconds: 5)}) async {
    // D?duplication optionnelle par cl?
    final key = msg.dedupeKey ??
        '${msg.to}|${msg.channel}|${msg.title.hashCode}|${msg.body.hashCode}';
    final now = DateTime.now();
    final last = _lastSent[key];
    if (last != null && now.difference(last) < throttle) {
      // drop silencieux pour ?viter le spam
      return;
    }
    _lastSent[key] = now;

    for (final sink in List<NotificationSink>.from(_sinks)) {
      try {
        await sink(msg);
      } catch (_) {
        // on isole les erreurs de sink pour ne pas bloquer les autres
      }
    }
  }

  /// Envoi ? plusieurs destinataires
  Future<void> sendToMany(List<String> recipients, NotificationMessage base, {Duration? throttle}) async {
    for (final r in recipients) {
      await sendMessage(base.copyWith(to: r), throttle: throttle ?? const Duration(seconds: 5));
    }
  }

  /// "Topics" na?fs (r?sout une liste dÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢emails et envoie ? chacun)
  Future<void> sendTopic(String topic, NotificationMessage base, List<String> Function(String topic) resolveEmails) async {
    final emails = resolveEmails(topic);
    await sendToMany(emails, base);
  }

  /// Planifie une notification (retourne un id ? utiliser pour annuler)
  String schedule(NotificationMessage msg, Duration delay, {String? scheduleId}) {
    final id = scheduleId ?? 'sched_${DateTime.now().microsecondsSinceEpoch}_${msg.hashCode}';
    cancel(id); // si existait
    _scheduled[id] = Timer(delay, () {
      // fire-and-forget
      unawaited(sendMessage(msg));
      _scheduled.remove(id);
    });
    return id;
  }

  /// Annule une notification planifi?e
  void cancel(String scheduleId) {
    _scheduled.remove(scheduleId)?.cancel();
  }

  /// Vide toute la planification (utile tests)
  void cancelAll() {
    for (final t in _scheduled.values) {
      t.cancel();
    }
    _scheduled.clear();
  }

  // ????????????????????????????????????????????????????????????????????????????
  // Sinks fournis
  // ????????????????????????????????????????????????????????????????????????????

  /// Sink console (toujours pr?sent)
  static Future<void> _consoleSink(NotificationMessage msg) async {
    // ignore: avoid_print
    print('[NOTIFY] to=${msg.to} | ${msg.title} - ${msg.body}  (ch=${msg.channel}, prio=${msg.priority})');
  }

  /// Sink SnackBar (in-app). A appeler une fois au d?marrage avec un GlobalKey<ScaffoldMessengerState>.
  NotificationSink snackBarSinkWith(GlobalKey<ScaffoldMessengerState> messengerKey) {
    return (NotificationMessage msg) {
      final ctx = messengerKey.currentContext;
      if (ctx == null) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(msg.body),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          showCloseIcon: true,
        ),
      );
    };
  }

  // ????????????????????????????????????????????????????????????????????????????
  // Templates courants (facultatifs)
  // ????????????????????????????????????????????????????????????????????????????

  Future<void> notifyApprovalLevel1({
    required String requesterEmail,
    required String approverName,
    required String expenseId,
    required double amount,
  }) async {
    await sendMessage(
      NotificationMessage(
        to: requesterEmail,
        title: 'rÃƒÂ©clamation #$expenseId approuv?e (N1)',
        body: 'Par $approverName - ${amount.toStringAsFixed(2)} \$',
        channel: NotificationChannel.approval,
        priority: NotificationPriority.normal,
        dedupeKey: 'apprL1:$expenseId:$requesterEmail',
        data: {'expenseId': expenseId, 'level': 1},
      ),
    );
  }

  Future<void> notifyApprovalFinal({
    required String requesterEmail,
    required String approverName,
    required String expenseId,
    required double amount,
  }) async {
    await sendMessage(
      NotificationMessage(
        to: requesterEmail,
        title: 'rÃƒÂ©clamation #$expenseId approuv?e (finale)',
        body: 'Par $approverName - ${amount.toStringAsFixed(2)} \$',
        channel: NotificationChannel.approval,
        priority: NotificationPriority.high,
        dedupeKey: 'apprFinal:$expenseId:$requesterEmail',
        data: {'expenseId': expenseId, 'level': 2},
      ),
    );
  }

  Future<void> notifyRejection({
    required String requesterEmail,
    required String approverName,
    required String expenseId,
    required String reason,
  }) async {
    await sendMessage(
      NotificationMessage(
        to: requesterEmail,
        title: 'rÃƒÂ©clamation #$expenseId refus?e',
        body: 'Par $approverName - Motif: $reason',
        channel: NotificationChannel.approval,
        priority: NotificationPriority.normal,
        dedupeKey: 'reject:$expenseId:$requesterEmail',
        data: {'expenseId': expenseId, 'reason': reason},
      ),
    );
  }

  Future<void> notifyPasswordRotationDue({
    required String email,
    required int daysLeft,
  }) async {
    await sendMessage(
      NotificationMessage(
        to: email,
        title: daysLeft <= 0 ? 'Changement de mot de passe requis' : 'Pensez ? changer votre mot de passe',
        body: daysLeft <= 0
            ? 'Votre mot de passe doit ?tre mis ? jour avant de continuer.'
            : 'Il vous reste $daysLeft jour(s) avant l'?ch?ance.',
        channel: NotificationChannel.security,
        priority: daysLeft <= 0 ? NotificationPriority.urgent : NotificationPriority.normal,
        dedupeKey: 'pwdRotation:$email',
      ),
    );
  }

  Future<void> notifyMonthlyReminder({
    required String email,
    required String message,
  }) async {
    await sendMessage(
      NotificationMessage(
        to: email,
        title: 'Rappel mensuel',
        body: message,
        channel: NotificationChannel.reminder,
        priority: NotificationPriority.low,
        dedupeKey: 'monthly:$email:${DateTime.now().month}',
      ),
    );
  }
}


