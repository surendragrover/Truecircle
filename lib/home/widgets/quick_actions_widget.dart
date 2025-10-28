import 'package:flutter/material.dart';
import '../../safety/immediate_help_page.dart';
import '../../safety/instant_relief_page.dart';
import '../../meditation/meditation_guide_page.dart';
import '../../festivals/festivals_page.dart';
import '../../rewards/rewards_page.dart';

/// Quick Actions Widget - Quick action buttons for common tasks
class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A145D), // Deep Purple
          ),
        ),
        const SizedBox(height: 16),
        // Row 1
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Instant Relief',
                subtitle: 'Breathe & ground',
                icon: Icons.spa_rounded,
                color: const Color(0xFF66BB6A),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InstantReliefPage()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Meditation Guide',
                subtitle: 'Find inner peace',
                icon: Icons.self_improvement_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MeditationGuidePage(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2 - Emergency & Festivals
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'SOS',
                subtitle: 'Immediate help',
                icon: Icons.emergency_rounded,
                color: const Color(0xFFEF4444),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImmediateHelpPage()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Festivals',
                subtitle: 'Celebrate connections',
                icon: Icons.celebration_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FestivalsPage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 3 - Rewards (single card centered)
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(), // Empty space
            ),
            Expanded(
              flex: 2,
              child: _QuickActionCard(
                title: 'Rewards',
                subtitle: 'Badges & milestones',
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RewardsPage()),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(), // Empty space
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual quick action card
class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A145D), // Deep Purple
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
