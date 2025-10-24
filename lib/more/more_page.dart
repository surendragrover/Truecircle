import 'package:flutter/material.dart';
import '../services/json_data_service.dart';
import '../festivals/festivals_page.dart';
import '../relationships/relationship_insights_page.dart';
import '../sleep/sleep_tracker_page.dart';
import '../meditation/meditation_guide_page.dart';
import '../safety/immediate_help_page.dart';
import '../safety/safety_plan_page.dart';
import '../marketplace/marketplace_page.dart';
import '../rewards/rewards_page.dart';
import '../emotional_awareness/emotional_awareness_page.dart';
import '../how_truecircle_works_page.dart';
import '../legal/privacy_policy_page.dart';
import '../legal/terms_conditions_page.dart';
import 'model_roles_page.dart';
import 'brand_preview_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset('assets/images/truecircle_logo.png', height: 24),
        ),
        titleSpacing: 0,
        title: const Text('More'),
      ),
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
            icon: Icons.palette_outlined,
            title: 'Brand Preview (logo/theme)',
            page: const BrandPreviewPage(),
          ),
          _actionTile(
            context,
            icon: Icons.download_for_offline,
            title: 'Prefill data (offline)',
            subtitle: 'Visual fill from local JSON and scoring examples',
            onTap: () => _importPrefillData(context),
          ),
          _actionTile(
            context,
            icon: Icons.info_outline,
            title: 'Scoring and removal info',
            subtitle:
                'Prefilled items will hide/remove as you add your entries; no network',
            onTap: () => _showScoringInfo(context),
          ),
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
            icon: Icons.celebration_outlined,
            title: 'Festivals',
            page: const FestivalsPage(),
          ),
          _tile(
            context,
            icon: Icons.favorite_outline,
            title: 'Relationship Insights',
            page: const RelationshipInsightsPage(),
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
          _tile(
            context,
            icon: Icons.emoji_events_outlined,
            title: 'Rewards',
            page: const RewardsPage(),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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

  Future<void> _importPrefillData(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    int total = 0;
    try {
      final svc = JsonDataService.instance;
      // Core demos
      final breathing = await svc.getBreathingSessions();
      final mood = await svc.getMoodJournalEntries();
      final checkins = await svc.getEmotionalCheckins();
      final sleep = await svc.getSleepTrackerEntries();
      final meditation = await svc.getMeditationGuides();
      final relInsights = await svc.getRelationshipInsights();
      final relInteractions = await svc.getRelationshipInteractions();
      final festivals = await svc.getFestivalsList();
      // CBT-related warm-up (to reduce first-open lag)
      final cbtTechniques = await svc.getCbtTechniques();
      final cbtThoughts = await svc.getCbtThoughts();
      final copingCards = await svc.getCopingCards();
      final cbtLessons = await svc.getCbtMicroLessons();
      final eaCats = await svc.getEmotionalAwarenessCategories();
      // Optional reading content
      final articles = await svc.getPsychologyArticles();
      total =
          breathing.length +
          mood.length +
          checkins.length +
          sleep.length +
          meditation.length +
          relInsights.length +
          relInteractions.length +
          festivals.length +
          cbtTechniques.length +
          cbtThoughts.length +
          copingCards.length +
          cbtLessons.length +
          eaCats.length +
          articles.length;
    } catch (_) {
      // ignore and still show a gentle message
    } finally {
      if (navigator.canPop()) {
        navigator.pop();
      }
    }

    // Removed context.mounted check to satisfy lint rule
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Offline content is ready (total ~$total items). This is only for visual guidance — as you add your own entries/logs, it will gradually hide.',
        ),
      ),
    );
  }

  void _showScoringInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Scoring and removal process',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                '• Prefilled content is for examples/visual guidance so you can see how scoring/analysis will look with your entries.\n'
                '• As you add your own entries (Mood, Sleep, Breathing, etc.), example items will automatically hide/remove.\n'
                '• No network/permissions — everything is from local JSON, on-device.\n'
                '• You can edit/delete your entries anytime; example items are only for reference.',
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
