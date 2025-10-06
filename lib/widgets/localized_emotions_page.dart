import 'package:flutter/material.dart';
import '../services/app_localization_service.dart';
import '../services/indian_languages_service.dart';

/// Localized Emotions Page
class LocalizedEmotionsPage extends StatefulWidget {
  const LocalizedEmotionsPage({super.key});

  @override
  State<LocalizedEmotionsPage> createState() => _LocalizedEmotionsPageState();
}

class _LocalizedEmotionsPageState extends State<LocalizedEmotionsPage>
    with AutomaticKeepAliveClientMixin {
  final AppLocalizationService _localizationService =
      AppLocalizationService.instance;
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Directionality(
          textDirection: _languageService
              .getTextDirection(_localizationService.currentLanguage),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('how_are_you_feeling'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildEmotionGrid(),
                const SizedBox(height: 20),
                Text(
                  context.t('emotion_history'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildEmotionHistory(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmotionGrid() {
    final emotions = [
      {'key': 'emotion_happy', 'emoji': '😊', 'color': Colors.yellow},
      {'key': 'emotion_sad', 'emoji': '😢', 'color': Colors.blue},
      {'key': 'emotion_angry', 'emoji': '😠', 'color': Colors.red},
      {'key': 'emotion_excited', 'emoji': '🤩', 'color': Colors.orange},
      {'key': 'emotion_calm', 'emoji': '😌', 'color': Colors.green},
      {'key': 'emotion_anxious', 'emoji': '😰', 'color': Colors.purple},
      {'key': 'emotion_love', 'emoji': '🥰', 'color': Colors.pink},
      {'key': 'emotion_grateful', 'emoji': '🙏', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        return _buildEmotionCard(
          context.t(emotion['key'] as String),
          emotion['emoji'] as String,
          emotion['color'] as Color,
        );
      },
    );
  }

  Widget _buildEmotionCard(String emotion, String emoji, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.t('log_emotion')}: $emotion $emoji'),
              backgroundColor: color,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                emotion,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionHistory() {
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          final emotions = ['😊', '😢', '🤩', '😌', '🥰'];
          final emotionNames = [
            context.t('emotion_happy'),
            context.t('emotion_sad'),
            context.t('emotion_excited'),
            context.t('emotion_calm'),
            context.t('emotion_love'),
          ];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[50],
              child:
                  Text(emotions[index], style: const TextStyle(fontSize: 24)),
            ),
            title: Text(emotionNames[index]),
            subtitle: Text('${index + 1} hour${index == 0 ? '' : 's'} ago'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }
}
