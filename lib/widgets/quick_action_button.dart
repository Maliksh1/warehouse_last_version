import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback?
      onPressed; // Made onPressed required (nullable for disabled state)

  const QuickActionButton({
    // Added const key and super.key
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed, // Make onPressed required (or optional if button can be disabled)
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed, // Use the provided onPressed callback
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // Use theme's ElevatedButton style defaults unless overridden here
      ),
    );
  }
}
