import 'package:flutter/material.dart';
import 'services/indian_languages_service.dart';
import 'pages/indian_languages_page.dart';
import 'widgets/translation_sample_page.dart';

/// Indian Languages Sample App
/// Complete Indian language selector with native scripts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indian Languages Service
  await IndianLanguagesService.initialize();

  runApp(const IndianLanguagesSampleApp());
}

class IndianLanguagesSampleApp extends StatelessWidget {
  const IndianLanguagesSampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueCircle Indian Languages',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.indigo[100],
          foregroundColor: Colors.black87,
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const IndianLanguagesLauncher(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IndianLanguagesLauncher extends StatefulWidget {
  const IndianLanguagesLauncher({super.key});

  @override
  State<IndianLanguagesLauncher> createState() =>
      _IndianLanguagesLauncherState();
}

class _IndianLanguagesLauncherState extends State<IndianLanguagesLauncher>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[100]!,
              Colors.blue[50]!,
              Colors.purple[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // App logo/icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo[400]!,
                                  Colors.blue[400]!
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.language,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          const Text(
                            'TrueCircle',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Indian Languages Support',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'भारतीय भाषा समर्थन',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Features preview
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.indigo[200]!),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FeatureItem(
                                        icon: '🌐', label: 'Multi\nScript'),
                                    FeatureItem(
                                        icon: '🇮🇳',
                                        label: 'Indian\nLanguages'),
                                    FeatureItem(
                                        icon: '📝', label: 'Native\nNames'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FeatureItem(
                                        icon: '🔄', label: 'Auto\nTranslation'),
                                    FeatureItem(
                                        icon: '⚡', label: 'Quick\nSwitch'),
                                    FeatureItem(
                                        icon: '🎯', label: 'Regional\nSupport'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Popular languages preview
                                const Text(
                                  'Popular Languages:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: _languageService.popularLanguages
                                      .take(5)
                                      .map((lang) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.indigo[200]!),
                                      ),
                                      child: Text(
                                        lang.nameNative,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Language statistics
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '📊 Language Statistics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatChip(
                                '${IndianLanguagesService.supportedLanguages.length}',
                                'Total'),
                            _buildStatChip(
                                '${_languageService.availableLanguages.length}',
                                'Supported'),
                            _buildStatChip(
                                '${_getUniqueScripts().length}', 'Scripts'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Sample text in current language
                        ListenableBuilder(
                          listenable: _languageService,
                          builder: (context, child) {
                            final currentLang =
                                _languageService.currentLanguage;
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Current: ${currentLang.nameNative}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: _languageService
                                      .getFontFamily(currentLang.code),
                                ),
                                textDirection: _languageService
                                    .getTextDirection(currentLang.code),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Launch buttons
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _launchLanguageSelector,
                            icon: const Icon(Icons.language),
                            label: const Text(
                              'Open Language Selector',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showLanguageList,
                            icon: const Icon(Icons.list),
                            label: const Text('View All Languages'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.indigo[400]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showFeatures,
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Features Overview'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.blue[400]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _launchTranslationSample,
                            icon: const Icon(Icons.translate),
                            label: const Text('Translation API Sample'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Set<String> _getUniqueScripts() {
    return IndianLanguagesService.supportedLanguages
        .map((lang) => lang.script)
        .toSet();
  }

  void _launchLanguageSelector() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const IndianLanguagesPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _launchTranslationSample() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
                        const TranslationSamplePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showLanguageList() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.list, color: Colors.indigo, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'All Indian Languages',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: IndianLanguagesService.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language =
                        IndianLanguagesService.supportedLanguages[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          language.nameNative,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily:
                                _languageService.getFontFamily(language.code),
                          ),
                        ),
                        subtitle: Text(
                            '${language.nameEnglish} • ${language.script}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              language.isSupported
                                  ? Icons.check_circle
                                  : Icons.help_outline,
                              color: language.isSupported
                                  ? Colors.green
                                  : Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              language.code.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _languageService.setLanguage(language.code);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Language changed to ${language.nameNative}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchLanguageSelector();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open Full Interface'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatures() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Language Features'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureDetail('🌐 Multi-Script Support',
                  'Support for Devanagari, Bengali, Tamil, Telugu, Gujarati, and more scripts.'),
              _buildFeatureDetail('🇮🇳 Complete Indian Coverage',
                  'All major Indian languages including Assamese, Bengali, Gujarati, Hindi, etc.'),
              _buildFeatureDetail('📝 Native Script Display',
                  'Languages shown in their own native scripts for authentic experience.'),
              _buildFeatureDetail('🔄 Auto Translation',
                  'Automatic translation support when translation API is enabled.'),
              _buildFeatureDetail('⚡ Quick Language Switch',
                  'Fast switching between popular languages with chips.'),
              _buildFeatureDetail('🎯 Regional Grouping',
                  'Languages organized by regions: North, South, East, West India.'),
              _buildFeatureDetail('📊 Live Statistics',
                  'Real-time display of supported languages and scripts.'),
              _buildFeatureDetail('🎨 Custom Font Support',
                  'Appropriate font rendering for each script and language.'),
              _buildFeatureDetail('🌍 RTL Support',
                  'Right-to-left text direction support for languages like Urdu.'),
              _buildFeatureDetail('🔧 Developer Friendly',
                  'Easy integration with translation APIs and language services.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchLanguageSelector();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureDetail(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String icon;
  final String label;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
