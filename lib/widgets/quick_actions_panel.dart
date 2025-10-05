import 'package:flutter/material.dart';

/// Unified Quick Actions Panel for TrueCircle
class QuickActionsPanel extends StatelessWidget {
  final List<QuickActionItem> actions;
  final bool isHindi;

  const QuickActionsPanel({
    super.key,
    required this.actions,
    this.isHindi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi ? 'त्वरित कार्य' : 'Quick Actions',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions
              .map((action) => _buildActionCard(context, action))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, QuickActionItem action) {
    return GestureDetector(
      onTap: action.onPressed,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: action.color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, color: action.color, size: 32),
              const SizedBox(height: 8),
              Text(
                isHindi ? action.labelHi : action.labelEn,
                style: TextStyle(
                  color: action.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String labelEn;
  final String labelHi;
  final Color color;
  final VoidCallback onPressed;

  QuickActionItem({
    required this.icon,
    required this.labelEn,
    required this.labelHi,
    required this.color,
    required this.onPressed,
  });
}
