// lib/widgets/background.dart
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget? child;
  const Background({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
              : [const Color(0xFFE8F5E9), const Color(0xFFFFFFFF)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/logo.png',
                width: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => Icon(
                  Icons.local_hospital_rounded,
                  size: 200,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                ),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

