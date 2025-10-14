import 'dart:async';

import '../models/chat.dart';
import 'chat_repository.dart';
import 'chat_badge.dart';

/// Démo locale (en mémoire) : simule un agent qui répond.
/// À remplacer par une vraie implémentation réseau plus tard.
class ChatRepositoryMock implements ChatRepository {
  // Un contrôleur par cible, alimenté en mémoire
  final Map<ChatTarget, StreamController<List<ChatMessage>>> _controllers = {
    ChatTarget.admins: StreamController<List<ChatMessage>>.broadcast(),
    ChatTarget.finance: StreamController<List<ChatMessage>>.broadcast(),
    ChatTarget.adminsAndFinance: StreamController<List<ChatMessage>>.broadcast(),
  };

  // Messages en mémoire par cible
  final Map<ChatTarget, List<ChatMessage>> _store = {
    ChatTarget.admins: [],
    ChatTarget.finance: [],
    ChatTarget.adminsAndFinance: [],
  };

  int _seq = 0;
  String _nextId() => '${DateTime.now().millisecondsSinceEpoch}_${_seq++}';

  ChatRepositoryMock({String? seedEmail}) {
    // Message d’accueil pour chaque cible (comme si l’agent saluait)
    for (final t in _store.keys) {
      final m = ChatMessage(
        id: _nextId(),
        fromEmail: 'agent@sja.ca',
        fromAgent: true,
        target: t,
        text: 'Bonjour! Écrivez-nous dans ${t.label}.',
        sentAt: DateTime.now(),
      );
      _store[t] = [m];
      _controllers[t]!.add(List.unmodifiable(_store[t]!));

      // On simule un message entrant = incrément du badge
      ChatBadge.unread.value++;
    }
  }

  @override
  Stream<List<ChatMessage>> messagesFor(ChatTarget target, String forUserEmail) {
    return _controllers[target]!.stream;
  }

  @override
  Future<void> sendMessage({
    required ChatTarget target,
    required String fromEmail,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _nextId(),
      fromEmail: fromEmail,
      fromAgent: false,
      target: target,
      text: text.trim(),
      sentAt: DateTime.now(),
    );
    _store[target]!.add(userMsg);
    _controllers[target]!.add(List.unmodifiable(_store[target]!));

    // Simule une réponse “agent” après 1,2 s
    Future.delayed(const Duration(milliseconds: 1200), () {
      final reply = ChatMessage(
        id: _nextId(),
        fromEmail: 'agent@sja.ca',
        fromAgent: true,
        target: target,
        text: 'Reçu ✔︎  • "${text.trim()}"',
        sentAt: DateTime.now(),
      );
      _store[target]!.add(reply);
      _controllers[target]!.add(List.unmodifiable(_store[target]!));

      // Incrémente badge sur arrivée d’un message agent
      ChatBadge.unread.value++;
    });
  }

  @override
  Future<void> markAllRead(ChatTarget target, String forUserEmail) async {
    // Démo simple : on ne persiste pas l’état “read” par utilisateur ; on vide le badge.
    ChatBadge.unread.value = 0;
  }

  @override
  Future<void> dispose() async {
    for (final c in _controllers.values) {
      await c.close();
    }
  }
}
