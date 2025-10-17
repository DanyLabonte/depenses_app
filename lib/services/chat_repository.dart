import 'dart:async';
import '../models/chat.dart';

/// Abstraction - remplace par une impl?mentation r?seau (WebSocket, Firestore, REST.)
abstract class ChatRepository {
  /// Stream des messages pour une cible/groupe donn?e
  Stream<List<ChatMessage>> messagesFor(ChatTarget target, String forUserEmail);

  /// Envoie un message vers la cible
  Future<void> sendMessage({
    required ChatTarget target,
    required String fromEmail,
    required String text,
  });

  /// Marque tous les messages de la cible comme lus pour cet utilisateur
  Future<void> markAllRead(ChatTarget target, String forUserEmail);

  /// Lib?rer les ressources
  Future<void> dispose();
}


