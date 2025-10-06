import 'package:flutter/material.dart';
import 'dart:math' as math;

class AvatarPlaceholder extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const AvatarPlaceholder({
    super.key,
    required this.name,
    this.size = 40,
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // If image URL is provided, show network image
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: _getBackgroundColor(),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback to initials if image fails to load
        },
        child: _buildFallbackContent(),
      );
    }

    // Show initials placeholder
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getBackgroundColor(),
      child: _buildInitials(),
    );
  }

  Widget _buildFallbackContent() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
      ),
      child: _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(name);
    return Text(
      initials,
      style: TextStyle(
        color: textColor ?? Colors.white,
        fontSize: fontSize ?? (size * 0.4),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, math.min(2, words[0].length)).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words.last.substring(0, 1))
          .toUpperCase();
    }
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    // Generate consistent color based on name
    final hash = name.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
      Colors.amber,
    ];

    return colors[hash.abs() % colors.length];
  }
}

class EmotionalScoreAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  final String emotionalScore; // 💙💛🖤
  final double scoreValue; // 0-100

  const EmotionalScoreAvatar({
    super.key,
    required this.name,
    required this.emotionalScore,
    required this.scoreValue,
    this.size = 50,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main avatar
        AvatarPlaceholder(
          name: name,
          size: size,
          imageUrl: imageUrl,
        ),

        // Emotional score indicator
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: _getScoreColor(),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                emotionalScore,
                style: TextStyle(fontSize: size * 0.15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor() {
    if (scoreValue >= 70) return Colors.green.shade100;
    if (scoreValue >= 40) return Colors.orange.shade100;
    return Colors.red.shade100;
  }
}

class ContactPlaceholder extends StatelessWidget {
  final String name;
  final String subtitle;
  final String emotionalScore;
  final double scoreValue;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool showInsights;

  const ContactPlaceholder({
    super.key,
    required this.name,
    required this.subtitle,
    required this.emotionalScore,
    required this.scoreValue,
    this.imageUrl,
    this.onTap,
    this.showInsights = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: EmotionalScoreAvatar(
          name: name,
          emotionalScore: emotionalScore,
          scoreValue: scoreValue,
          imageUrl: imageUrl,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (showInsights) ...[
              const SizedBox(height: 4),
              _buildScoreBar(),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emotionalScore,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              '${scoreValue.round()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildScoreBar() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.grey[300],
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: scoreValue / 100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: _getScoreColor(),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor() {
    if (scoreValue >= 70) return Colors.green;
    if (scoreValue >= 40) return Colors.orange;
    return Colors.red;
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
