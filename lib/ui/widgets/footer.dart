import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '© ${DateTime.now().year} AuthX TOTP',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '版本 1.0.0',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}