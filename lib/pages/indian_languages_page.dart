import 'package:flutter/material.dart';
import '../services/indian_languages_service.dart';
import '../widgets/indian_language_selector.dart';
import '../widgets/truecircle_logo.dart';

/// Indian Languages Sample Page (privacy-friendly showcase)
/// Shows all supported Indian languages with native scripts
class IndianLanguagesPage extends StatefulWidget {
  const IndianLanguagesPage({super.key});

  @override
  State<IndianLanguagesPage> createState() => _IndianLanguagesPageState();
}

class _IndianLanguagesPageState extends State<IndianLanguagesPage>
    with TickerProviderStateMixin {
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;
  late TabController _tabController;

  // Sample text in different languages
  final Map<String, String> _welcomeTexts = {
    'hi': 'नमस्ते! TrueCircle में आपका स्वागत है',
    'en': 'Welcome to TrueCircle!',
    'bn': 'TrueCircle এ আপনাকে স্বাগতম!',
    'te': 'TrueCircle కు స్వాగతం!',
    'mr': 'TrueCircle मध्ये आपले स्वागत आहे!',
    'ta': 'TrueCircle இல் உங்களை வரவேற்கிறோம்!',
    'gu': 'TrueCircle માં તમારું સ્વાગત છે!',
    'ur': 'TrueCircle میں خوش آمدید!',
    'kn': 'TrueCircle ಗೆ ಸ್ವಾಗತ!',
    'ml': 'TrueCircle ൽ സ്വാഗതം!',
    'pa': 'TrueCircle ਵਿੱਚ ਤੁਹਾਡਾ ਸੁਆਗਤ ਹੈ!',
    'as': 'TrueCircle লৈ আপোনাক স্বাগতম!',
    'or': 'TrueCircle କୁ ସ୍ୱାଗତ!',
    'ne': 'TrueCircle मा तपाईंलाई स्वागत छ!',
    'kok': 'TrueCircle हांत तुमकां येवकार!',
    'mai': 'TrueCircle मे अहाँकेँ स्वागत अछि!',
    'ks': 'TrueCircle मांज़ तुहुंद स्वागत छु!',
  };

  final Map<String, String> _festivalTexts = {
    'hi': '🎊 त्योहारों की शुभकामनाएं',
    'en': '🎊 Festival Greetings',
    'bn': '🎊 উৎসবের শুভেচ্ছা',
    'te': '🎊 పండుగ శుభాకాంక్షలు',
    'mr': '🎊 सणाच्या शुभेच्छा',
    'ta': '🎊 பண்டிகை வாழ்த்துக்கள்',
    'gu': '🎊 તહેવારની શુભકામનાઓ',
    'ur': '🎊 تہوار کی مبارکباد',
    'kn': '🎊 ಹಬ್ಬದ ಶುಭಾಶಯಗಳು',
    'ml': '🎊 ഉത്സവാശംസകൾ',
    'pa': '🎊 ਤਿਉਹਾਰਾਂ ਦੀਆਂ ਮੁਬਾਰਕਾਂ',
    'as': '🎊 উৎসৱৰ শুভেচ্ছা',
    'or': '🎊 ପର୍ବ ଶୁଭେଚ୍ଛା',
    'ne': '🎊 चाडपर्वको शुभकामना',
    'kok': '🎊 पर्वाची शुभकामना',
    'mai': '🎊 त्यौहारक शुभकामना',
    'ks': '🎊 त्यौहारस शुभकामना',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            TrueCircleLogo(
              size: 30,
              showText: false,
              style: LogoStyle.icon,
            ),
            SizedBox(width: 12),
            Text('🌐 Indian Languages'),
          ],
        ),
        backgroundColor: Colors.indigo[100],
        foregroundColor: Colors.black87,
        actions: [
          CompactLanguageSelector(
            onLanguageChanged: (language) {
              setState(() {});
            },
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.language), text: 'Languages'),
            Tab(icon: Icon(Icons.preview), text: 'Preview'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[50]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLanguagesTab(),
            _buildPreviewTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Statistics Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  '📊 Language Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total Languages',
                      '${IndianLanguagesService.supportedLanguages.length}',
                      Icons.language,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Supported',
                      '${_languageService.availableLanguages.length}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Scripts',
                      '${_getUniqueScripts().length}',
                      Icons.text_fields,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Regional Languages
        ..._languageService.regionalLanguages.entries.map((entry) {
          return _buildRegionalSection(entry.key, entry.value);
        }),

        // Other languages
        _buildOtherLanguagesSection(),
      ],
    );
  }

  Widget _buildRegionalSection(String region, List<IndianLanguage> languages) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text('📍 $region'),
        subtitle: Text('${languages.length} languages'),
        children: languages.map((language) {
          return ListTile(
            title: Text(
              language.nameNative,
              style: TextStyle(
                fontFamily: _languageService.getFontFamily(language.code),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('${language.nameEnglish} • ${language.script}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  language.isSupported
                      ? Icons.check_circle
                      : Icons.help_outline,
                  color: language.isSupported ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _previewLanguage(language),
                  tooltip: 'Preview ${language.nameEnglish}',
                ),
              ],
            ),
            onTap: () => _selectLanguage(language),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOtherLanguagesSection() {
    final otherLanguages = IndianLanguagesService.supportedLanguages
        .where((lang) => !_languageService.regionalLanguages.values
            .expand((langs) => langs)
            .contains(lang))
        .toList();

    if (otherLanguages.isEmpty) return const SizedBox.shrink();

    return Card(
      child: ExpansionTile(
        title: const Text('🗂️ Other Languages'),
        subtitle: Text('${otherLanguages.length} languages'),
        children: otherLanguages.map((language) {
          return ListTile(
            title: Text(
              language.nameNative,
              style: TextStyle(
                fontFamily: _languageService.getFontFamily(language.code),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('${language.nameEnglish} • ${language.script}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  language.isSupported
                      ? Icons.check_circle
                      : Icons.help_outline,
                  color: language.isSupported ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _previewLanguage(language),
                ),
              ],
            ),
            onTap: () => _selectLanguage(language),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current language preview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Language Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: _languageService,
                  builder: (context, child) {
                    final currentLang = _languageService.currentLanguage;
                    final welcomeText =
                        _welcomeTexts[currentLang.code] ?? _welcomeTexts['en']!;
                    final festivalText = _festivalTexts[currentLang.code] ??
                        _festivalTexts['en']!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Language: ${currentLang.nameNative}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: _languageService
                                .getFontFamily(currentLang.code),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            welcomeText,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: _languageService
                                  .getFontFamily(currentLang.code),
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: _languageService
                                .getTextDirection(currentLang.code),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Text(
                            festivalText,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: _languageService
                                  .getFontFamily(currentLang.code),
                            ),
                            textDirection: _languageService
                                .getTextDirection(currentLang.code),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Script: ${currentLang.script} • ${currentLang.isSupported ? 'Supported' : 'Limited Support'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Quick language switcher
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Language Switch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _languageService.popularLanguages.map((language) {
                    final isSelected =
                        _languageService.selectedLanguage == language.code;
                    return FilterChip(
                      label: Text(
                        language.nameNative,
                        style: TextStyle(
                          fontFamily:
                              _languageService.getFontFamily(language.code),
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _languageService.setLanguage(language.code);
                          setState(() {});
                        }
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.blue,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: LanguageSettingsCard(),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Set<String> _getUniqueScripts() {
    return IndianLanguagesService.supportedLanguages
        .map((lang) => lang.script)
        .toSet();
  }

  void _previewLanguage(IndianLanguage language) {
    final welcomeText = _welcomeTexts[language.code] ??
        '${language.nameNative} language preview';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview: ${language.nameEnglish}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Native Name: ${language.nameNative}',
              style: TextStyle(
                fontFamily: _languageService.getFontFamily(language.code),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('Script: ${language.script}'),
            const SizedBox(height: 8),
            Text('Support: ${language.isSupported ? 'Full' : 'Limited'}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                welcomeText,
                style: TextStyle(
                  fontFamily: _languageService.getFontFamily(language.code),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: _languageService.getTextDirection(language.code),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _selectLanguage(language);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(IndianLanguage language) {
    _languageService.setLanguage(language.code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to ${language.nameNative}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {});
  }
}
