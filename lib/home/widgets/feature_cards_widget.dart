import 'package:flutter/material.dart';
import '../../cbt/cbt_hub_page.dart';
import '../../iris/dr_iris_welcome_page.dart';
import '../../emotional_awareness/emotional_awareness_page.dart';

/// Feature Cards Widget - Main feature cards for all app features
class FeatureCardsWidget extends StatelessWidget {
  const FeatureCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wellness Tools',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A145D), // Deep Purple
          ),
        ),
        const SizedBox(height: 16),

        // CBT Techniques Feature
        _FeatureCard(
          title: '🧠 CBT Techniques',
          description: 'Cognitive Behavioral Therapy tools and exercises',
          icon: Icons.psychology_rounded,
          color: const Color(0xFF6366F1), // Primary TrueCircle 💙
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CBTHubPage()),
          ),
        ),
        const SizedBox(height: 16),

        // Dr. Iris AI Feature
        _FeatureCard(
          title: '🤖 Dr. Iris AI',
          description: 'Your personal AI wellness assistant',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF8B5CF6), // Hope Purple 💜
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFAB47BC)],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DrIrisWelcomePage()),
          ),
        ),
        const SizedBox(height: 16),

        // Emotional Check-in Feature
        _FeatureCard(
          title: '😊 Emotional Check-in',
          description: 'Track and understand your emotions daily',
          icon: Icons.mood_rounded,
          color: const Color(0xFFF4AB37), // Warm Gold 💛
          gradient: const LinearGradient(
            colors: [Color(0xFFF4AB37), Color(0xFFFF8A65)],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmotionalAwarenessPage()),
          ),
        ),
        const SizedBox(height: 16),

        // Sleep Tracking Feature (Coming Soon)
        _FeatureCard(
          title: '😴 Sleep Tracker',
          description: 'Monitor your sleep patterns and quality',
          icon: Icons.bedtime_rounded,
          color: const Color(0xFF42A5F5), // Sky Blue 💤
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF14B8A6)],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('😴 Sleep tracking feature coming soon!'),
                backgroundColor: Color(0xFF42A5F5),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Meditation Feature (Coming Soon)
        _FeatureCard(
          title: '🧘‍♀️ Meditation',
          description: 'Guided meditation and mindfulness exercises',
          icon: Icons.spa_rounded,
          color: const Color(0xFF66BB6A), // Spring Green 🌿
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF14B8A6)],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🧘‍♀️ Meditation feature coming soon!'),
                backgroundColor: Color(0xFF66BB6A),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Feature Card - Individual feature card with gradient and animations
class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            // Icon Container with Gradient
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),

            // Content - सामग्री
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A145D), // Deep Purple
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow Icon - तीर आइकन
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
