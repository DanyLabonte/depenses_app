import 'package:depenses_app/core/l10n/gen/s.dart';
import 'package:flutter/material.dart';
import 'package:depenses_app/core/l10n/gen/s.dart';

class FeedbackScreen extends StatefulWidget {
  final String currentUserEmail;
  const FeedbackScreen({super.key, required this.currentUserEmail});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _toCtrl = TextEditingController(text: 'support@sja.ca');
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _toCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _send() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).feedbackSent)),
    );
    _subjectCtrl.clear();
    _messageCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Line(
            icon: Icons.person_outline_rounded,
            label: s.fromLabel,
            child: SelectableText(widget.currentUserEmail),
          ),
          const SizedBox(height: 8),
          _Line(
            icon: Icons.alternate_email_rounded,
            label: s.toLabel,
            child: TextField(
              controller: _toCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 8),
          _Line(
            icon: Icons.subject_rounded,
            label: s.subjectLabel,
            child: TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 8),
          _Line(
            icon: Icons.chat_bubble_outline_rounded,
            label: s.messageLabel,
            child: TextField(
              controller: _messageCtrl,
              maxLines: 6,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _send,
            icon: const Icon(Icons.send_rounded),
            label: Text(s.sendLabel),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${s.feedbackFooter} Ã¢â‚¬â€ ${widget.currentUserEmail}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _Line({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.35),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18),
              const SizedBox(width: 10),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ]),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}


