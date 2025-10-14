import 'package:flutter/foundation.dart';

enum ChatTarget { admins, finance, adminsAndFinance }

extension ChatTargetLabel on ChatTarget {
  String get label {
    switch (this) {
      case ChatTarget.admins:
        return 'Administrateurs';
      case ChatTarget.finance:
        return 'Finance';
      case ChatTarget.adminsAndFinance:
        return 'Admins + Finance';
    }
  }
}

/// Message de chat minimal
@immutable
class ChatMessage {
  final String id;
  final String fromEmail;           // expéditeur réel
  final bool fromAgent;             // true = “côté admin/finance”, false = bénévole
  final ChatTarget target;          // à quel groupe s’adresse le message
  final String text;
  final DateTime sentAt;
  final bool read;

  const ChatMessage({
    required this.id,
    required this.fromEmail,
    required this.fromAgent,
    required this.target,
    required this.text,
    required this.sentAt,
    this.read = false,
  });

  ChatMessage copyWith({bool? read}) => ChatMessage(
    id: id,
    fromEmail: fromEmail,
    fromAgent: fromAgent,
    target: target,
    text: text,
    sentAt: sentAt,
    read: read ?? this.read,
  );
}
