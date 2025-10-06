import 'package:flutter/material.dart';
import '../services/app_localization_service.dart';
import '../services/indian_languages_service.dart';
import '../services/festival_data_service.dart';

/// Localized Festivals Page
class LocalizedFestivalsPage extends StatefulWidget {
  const LocalizedFestivalsPage({super.key});

  @override
  State<LocalizedFestivalsPage> createState() => _LocalizedFestivalsPageState();
}

class _LocalizedFestivalsPageState extends State<LocalizedFestivalsPage>
    with AutomaticKeepAliveClientMixin {
  final AppLocalizationService _localizationService =
      AppLocalizationService.instance;
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;
  final FestivalDataService _festivalService = FestivalDataService.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeFestivalData();
  }

  Future<void> _initializeFestivalData() async {
    if (!_festivalService.isInitialized) {
      await _festivalService.initialize();
      if (mounted) setState(() {});
    }
  }

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
                  context.t('upcoming_festivals'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFestivalsList(),
                const SizedBox(height: 20),
                Text(
                  context.t('festival_tips'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFestivalTips(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFestivalsList() {
    if (!_festivalService.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final upcomingFestivals = _festivalService.getUpcomingFestivals();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingFestivals.length,
      itemBuilder: (context, index) {
        final festival = upcomingFestivals[index];
        return _buildFestivalCard(festival);
      },
    );
  }

  Widget _buildFestivalCard(Festival festival) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showFestivalDetails(festival),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                festival.color.withValues(alpha: 0.1),
                festival.color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: festival.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      festival.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        festival.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Jet black text
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        festival.hindiName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Jet black text
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        festival.formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black, // Jet black text - no gray
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: festival.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${festival.daysRemaining} days left',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black, // Jet black - no gray
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFestivalTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTipTile(
              icon: Icons.card_giftcard,
              title: context.t('gift_suggestions'),
              subtitle:
                  '${context.t('dry_fruits')}, ${context.t('sweets')}, ${context.t('flowers')}',
              color: Colors.purple,
            ),
            const Divider(),
            _buildTipTile(
              icon: Icons.message,
              title: context.t('festival_wishes'),
              subtitle: 'Send personalized greetings',
              color: Colors.blue,
            ),
            const Divider(),
            _buildTipTile(
              icon: Icons.home,
              title: context.t('decorations'),
              subtitle: 'Traditional decorating ideas',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black), // Jet black text
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.black), // Jet black text
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black, // Jet black - no gray
      ),
      onTap: () {},
    );
  }

  void _showFestivalDetails(Festival festival) {
    final greetingMessage = _getLocalizedGreeting(festival);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    festival.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          festival.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Jet black text
                          ),
                        ),
                        Text(
                          festival.hindiName,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black, // Jet black text
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          festival.formattedDate,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black, // Jet black text - no gray
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                context.t('festival_wishes'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Jet black text
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: festival.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greetingMessage,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: _languageService.getFontFamily(
                                  _localizationService.currentLanguage),
                              color: Colors.black, // Jet black text
                            ),
                            textDirection: _languageService.getTextDirection(
                                _localizationService.currentLanguage),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Description:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Jet black text
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            festival.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black, // Jet black text
                            ),
                          ),
                          if (festival.culturalTips.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Cultural Tips:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Jet black text
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...festival.culturalTips.map((tip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• $tip',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black, // Jet black text
                                    ),
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get localized greeting message for festival
  String _getLocalizedGreeting(Festival festival) {
    final greetingMessages = festival.greetingMessages;
    // Get current language (unused variable commented out)
    // final currentLang = _localizationService.currentLanguage;

    // Try to get localized greeting or fallback to English
    return greetingMessages['family'] ??
        greetingMessages['formal'] ??
        greetingMessages['casual'] ??
        '${festival.name} wishes! ${festival.emoji}';
  }
}
