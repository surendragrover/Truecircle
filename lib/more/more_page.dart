import 'package:flutter/material.dart';
import '../relationships/relationship_insights_page.dart';
import '../sleep/sleep_tracker_page.dart';
import '../meditation/meditation_guide_page.dart';
import '../safety/immediate_help_page.dart';
import '../safety/safety_plan_page.dart';
import '../safety/instant_relief_page.dart';
import '../marketplace/marketplace_page.dart';
import '../emotional_awareness/emotional_awareness_page.dart';
import '../communication/communication_tracker_page.dart';
import '../communication/interactive_insights_dashboard.dart';
import '../how_truecircle_works_page.dart';
import '../legal/privacy_policy_page.dart';
import '../legal/terms_conditions_page.dart';
import '../learn/faq_page.dart';
import 'developer_options_page.dart';
import 'model_roles_page.dart';
import 'comprehensive_user_profile_builder.dart';
import '../core/truecircle_app_bar.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TrueCircleAppBar(title: 'More'),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'For visual guidance in the CBT hub and other pages, some prefilled content may be shown. As you add your own entries, this content will gradually hide.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          _tile(
            context,
            icon: Icons.psychology_alt_outlined,
            title: 'Emotional Awareness (Questions)',
            page: const EmotionalAwarenessPage(),
          ),
          _tile(
            context,
            icon: Icons.info_outline,
            title: 'How TrueCircle Works',
            page: const HowTrueCircleWorksPage(),
          ),
          _tile(
            context,
            icon: Icons.integration_instructions_outlined,
            title: 'AI Model Roles (Defined)',
            page: const ModelRolesPage(),
          ),
          _tile(
            context,
            icon: Icons.person_add_alt_1,
            title: 'Complete Profile Builder',
            page: const ComprehensiveUserProfileBuilder(),
          ),
          // Developer/internal utilities removed for end users:
          // - Brand Preview (logo/theme)
          // - Data Preloading Status
          // - Prefill data (offline)
          // - Scoring and removal info
          const Divider(height: 24),
          _tile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            page: const PrivacyPolicyPage(),
          ),
          _tile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            page: const TermsConditionsPage(),
          ),
          const Divider(height: 24),
          _tile(
            context,
            icon: Icons.help_outline,
            title: 'FAQ',
            page: const FaqPage(),
          ),
          const SizedBox(height: 4),
          // Festivals moved to Home Quick Actions (removed from More to avoid duplication)
          _tile(
            context,
            icon: Icons.people_outline,
            title: 'Communication Tracker',
            page: const CommunicationTrackerPage(),
          ),
          _tile(
            context,
            icon: Icons.favorite_outline,
            title: 'Relationship Insights',
            page: const RelationshipInsightsPage(),
          ),
          _tile(
            context,
            icon: Icons.psychology_outlined,
            title: 'Interactive AI Insights',
            page: const InteractiveInsightsDashboard(),
          ),
          _tile(
            context,
            icon: Icons.nights_stay_outlined,
            title: 'Sleep Tracker',
            page: const SleepTrackerPage(),
          ),
          _tile(
            context,
            icon: Icons.self_improvement_outlined,
            title: 'Meditation Guide',
            page: const MeditationGuidePage(),
          ),
          const Divider(height: 24),
          _tile(
            context,
            icon: Icons.spa_outlined,
            title: 'Instant Relief',
            page: const InstantReliefPage(),
          ),
          _tile(
            context,
            icon: Icons.health_and_safety_outlined,
            title: 'Immediate Help',
            page: const ImmediateHelpPage(),
          ),
          _tile(
            context,
            icon: Icons.fact_check_outlined,
            title: 'Safety Plan',
            page: const SafetyPlanPage(),
          ),
          const Divider(height: 24),
          _tile(
            context,
            icon: Icons.storefront_outlined,
            title: 'Marketplace',
            page: const MarketplacePage(),
          ),
          // Rewards moved to Home Quick Actions (removed from More to avoid duplication)
          const Divider(height: 24),
          _tile(
            context,
            icon: Icons.build_circle_outlined,
            title: 'Developer Options',
            page: const DeveloperOptionsPage(),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
    );
  }
}
