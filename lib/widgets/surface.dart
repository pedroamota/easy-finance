import 'package:flutter/material.dart';

class Surface extends StatelessWidget {
  const Surface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}
