import 'package:flutter/material.dart';
import 'package:depenses_app/services/chat_badge.dart';

/// Petite bulle flottante "messagerie" d?pla?able fa?on Messenger.
/// - Appuie: d?clenche onTap
/// - Drag: on peut la d?placer librement ? l'?cran
/// - Affiche un badge non-lu via ChatBadge.unread
class ChatHead extends StatefulWidget {
  final VoidCallback onTap;
  final Offset initialOffset;

  const ChatHead({
    super.key,
    required this.onTap,
    this.initialOffset = const Offset(24, 24),
  });

  @override
  State<ChatHead> createState() => _ChatHeadState();
}

class _ChatHeadState extends State<ChatHead> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    // marge pour ne pas passer sous la barre du bas
    final bottomSafe = padding.bottom + 72;

    // borne lÃ¢â‚¬â„¢offset pour rester visible
    Offset _clamp(Offset o) {
      final dx = o.dx.clamp(8.0, size.width - 68.0);
      final dy = o.dy.clamp(padding.top + 8.0, size.height - bottomSafe);
      return Offset(dx, dy);
    }

    final pos = _clamp(_offset);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _offset = _clamp(_offset + d.delta)),
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
              ),
              child: const Icon(Icons.chat_bubble, color: Colors.white),
            ),
            // Badge non-lu
            Positioned(
              right: -4,
              top: -4,
              child: ValueListenableBuilder<int>(
                valueListenable: ChatBadge.unread,
                builder: (context, count, _) {
                  if (count <= 0) return const SizedBox.shrink();
                  final text = count > 99 ? '99+' : '$count';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)],
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


