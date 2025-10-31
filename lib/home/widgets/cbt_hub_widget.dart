import 'package:flutter/material.dart';
import '../../cbt/cbt_hub_page.dart';
import '../../cbt/cbt_personal_context_form.dart';
import '../../cbt/cbt_thoughts_page.dart';
import '../../cbt/coping_cards_page.dart';
import '../../cbt/cbt_micro_lessons_page.dart';
import '../../cbt/cbt_techniques_page.dart';
import '../../cbt/phq9_page.dart';
import '../../cbt/gad7_page.dart';
import '../../cbt/psychology_articles_page.dart';
import '../../widgets/entry_box.dart';
import '../../core/log_service.dart';

/// CBT Hub Widget - All CBT features in one centralized hub
/// All CBT techniques and tools in one place
class CBTHubWidget extends StatelessWidget {
  const CBTHubWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CBT Hub Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CBT Hub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cognitive Behavioral Therapy Tools',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // CBT Features Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildCBTFeatureCard(
                context,
                'Personal Setup',
                'Personal Context',
                Icons.person_rounded,
                Colors.indigo,
                () => _openPersonalContextForm(context),
              ),
              _buildCBTFeatureCard(
                context,
                'Thought Diary',
                'Track & analyze thoughts',
                Icons.edit_note_rounded,
                Colors.blue,
                () => _openThoughtDiary(context),
              ),
              _buildCBTFeatureCard(
                context,
                'Coping Cards',
                'Positive affirmations',
                Icons.style_rounded,
                Colors.green,
                () => _openCopingCards(context),
              ),
              _buildCBTFeatureCard(
                context,
                'Micro Lessons',
                'Quick CBT learning',
                Icons.school_rounded,
                Colors.orange,
                () => _openMicroLessons(context),
              ),
              _buildCBTFeatureCard(
                context,
                'CBT Techniques',
                'Proven strategies',
                Icons.lightbulb_rounded,
                Colors.purple,
                () => _openCBTTechniques(context),
              ),
              _buildCBTFeatureCard(
                context,
                'Screening Tests',
                'Emotional health assessment',
                Icons.quiz_rounded,
                Colors.red,
                () => _openScreeningTests(context),
              ),
              _buildCBTFeatureCard(
                context,
                'Psychology Library',
                'Educational resources',
                Icons.library_books_rounded,
                Colors.teal,
                () => _openPsychologyLibrary(context),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Quick entry for CBT notes
          EntryBox(
            hintText: 'Quick CBT note or thought...',
            submitLabel: 'Save',
            onSubmit: (text) async {
              LogService.instance.log('CBTQuick: $text');
            },
          ),
          const SizedBox(height: 12),
          // Quick Access Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openCBTHubFullView(context),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Explore All CBT Tools'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCBTFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // CBT Feature Navigation Methods
  void _openThoughtDiary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CBTThoughtsPage()),
    );
  }

  void _openCopingCards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CopingCardsPage()),
    );
  }

  void _openMicroLessons(BuildContext context) {
    _showRightSidePopup(context, const CBTMicroLessonsPage());
  }

  void _openCBTTechniques(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CBTTechniquesPage()),
    );
  }

  void _openScreeningTests(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assignment_turned_in_outlined),
              title: const Text('PHQ‑9 (Depression)'),
              subtitle: const Text('Offline self‑assessment'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PHQ9Page()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('GAD‑7 (Anxiety)'),
              subtitle: const Text('Offline self‑assessment'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GAD7Page()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openPsychologyLibrary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PsychologyArticlesPage()),
    );
  }

  /// Shows a right-side sliding popup (modal) containing the given child.
  /// Used for lightweight, focused flows like Micro Lessons.
  void _showRightSidePopup(BuildContext context, Widget child) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.of(context).size;
        final width = size.width;
        // On phones, use nearly full width; on larger screens cap to 520.
        final panelWidth = width < 600 ? width : 520.0;
        return SafeArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: panelWidth,
                height: size.height,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                // Embed the page directly; it can include its own AppBar.
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, widget) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: widget),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  void _openPersonalContextForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CBTPersonalContextForm()),
    );
  }

  void _openCBTHubFullView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CBTHubPage()),
    );
  }
}

/// CBT Feature Page - Individual CBT tool pages
class CBTFeaturePage extends StatelessWidget {
  final String feature;

  const CBTFeaturePage({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getFeatureTitle(feature)), elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFeatureIcon(feature),
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _getFeatureTitle(feature),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getFeatureDescription(feature),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _navigateToFeature(context, feature),
              child: const Text('Start Session'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFeature(BuildContext context, String feature) {
    switch (feature) {
      case 'thought_diary':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CBTThoughtsPage()),
        );
        break;
      case 'coping_cards':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CopingCardsPage()),
        );
        break;
      case 'micro_lessons':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CBTMicroLessonsPage()),
        );
        break;
      case 'techniques':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CBTTechniquesPage()),
        );
        break;
      case 'screening_tests':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PHQ9Page()),
        );
        break;
      case 'psychology_library':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PsychologyArticlesPage()),
        );
        break;
      default:
        // For unknown features, navigate to CBT Hub
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CBTHubPage()),
        );
    }
  }

  String _getFeatureTitle(String feature) {
    switch (feature) {
      case 'thought_diary':
        return 'Thought Diary';
      case 'coping_cards':
        return 'Coping Cards';
      case 'micro_lessons':
        return 'Micro Lessons';
      case 'techniques':
        return 'CBT Techniques';
      case 'screening_tests':
        return 'Screening Tests';
      case 'psychology_library':
        return 'Psychology Library';
      default:
        return 'CBT Feature';
    }
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature) {
      case 'thought_diary':
        return Icons.edit_note_rounded;
      case 'coping_cards':
        return Icons.style_rounded;
      case 'micro_lessons':
        return Icons.school_rounded;
      case 'techniques':
        return Icons.lightbulb_rounded;
      case 'screening_tests':
        return Icons.quiz_rounded;
      case 'psychology_library':
        return Icons.library_books_rounded;
      default:
        return Icons.psychology_rounded;
    }
  }

  String _getFeatureDescription(String feature) {
    switch (feature) {
      case 'thought_diary':
        return 'Record and analyze your thoughts to identify patterns and reframe negative thinking.';
      case 'coping_cards':
        return 'Interactive cards with positive affirmations and coping strategies for difficult moments.';
      case 'micro_lessons':
        return 'Short, focused lessons on emotional health topics and CBT principles.';
      case 'techniques':
        return 'Learn and practice proven CBT techniques for managing emotions and thoughts.';
      case 'screening_tests':
        return 'Professional screening tools like PHQ-9 and GAD-7 for emotional health assessment.';
      case 'psychology_library':
        return 'Educational articles and resources on emotional health and psychological wellbeing.';
      default:
        return 'Explore this CBT feature to improve your mental wellness.';
    }
  }
}

/// Full CBT Hub Page
class CBTHubFullPage extends StatelessWidget {
  const CBTHubFullPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Hub'), elevation: 0),
      body: const Center(
        child: Text(
          'Full CBT Hub Coming Soon!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
