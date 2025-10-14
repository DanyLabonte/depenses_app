import 'package:flutter/foundation.dart';

/// Notificateur global du compteur de messages non lus.
/// Exemple d’usage (notification entrante) :
///   ChatBadge.unread.value++;
class ChatBadge {
  static final ValueNotifier<int> unread = ValueNotifier<int>(0);
}
