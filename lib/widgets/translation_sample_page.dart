import 'package:flutter/material.dart';
import '../services/indian_languages_service.dart';
import '../services/translation_api_service.dart';
import '../widgets/indian_language_selector.dart';

/// Complete translation sample page
/// Shows real translation API integration with Indian languages
class TranslationSamplePage extends StatefulWidget {
  const TranslationSamplePage({super.key});

  @override
  State<TranslationSamplePage> createState() => _TranslationSamplePageState();
}

class _TranslationSamplePageState extends State<TranslationSamplePage>
    with TickerProviderStateMixin {
  final _languageService = IndianLanguagesService.instance;
  final _translationService = TranslationApiService.instance;
  final _sourceController = TextEditingController();
  final _targetController = TextEditingController();

  bool _isTranslating = false;
  String? _detectedLanguage;
  List<String> _translationHistory = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Initialize translation service
    _initializeTranslation();

  // Set some sample text
    _sourceController.text = "Hello, welcome to TrueCircle!";
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _initializeTranslation() async {
    // In real app, this would come from api.env
    const demoApiKey = "sample_api_key_for_testing";
    _translationService.initialize(demoApiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Demo'),
        backgroundColor: Colors.indigo[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.indigo[50]!,
                  Colors.blue[50]!,
                  Colors.purple[25]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header with language selector
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Translation interface
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTranslationCard(),
                            const SizedBox(height: 20),
                            _buildQuickPhrases(),
                            const SizedBox(height: 20),
                            _buildHistory(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.translate, color: Colors.indigo, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Translation API Sample',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Real-time translation with Indian languages',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current language display
            ListenableBuilder(
              listenable: _languageService,
              builder: (context, child) {
                final currentLang = _languageService.currentLanguage;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language, color: Colors.indigo[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Current: ${currentLang.nameNative}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily:
                              _languageService.getFontFamily(currentLang.code),
                        ),
                      ),
                      const Spacer(),
                      // Quick language selector
                      CompactLanguageSelector(
                        onLanguageChanged: (language) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source text input
            const Text(
              'Enter text to translate:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sourceController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Type your message here...',
                prefixIcon: const Icon(Icons.edit),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_detectedLanguage != null)
                      Chip(
                        label: Text(_detectedLanguage!.toUpperCase()),
                        backgroundColor: Colors.green[100],
                      ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _sourceController.clear();
                        _targetController.clear();
                        setState(() {
                          _detectedLanguage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              onChanged: (text) {
                _detectLanguage(text);
              },
            ),

            const SizedBox(height: 20),

            // Translation controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTranslating ? null : _translateText,
                    icon: _isTranslating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.translate),
                    label:
                        Text(_isTranslating ? 'Translating...' : 'Translate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _swapLanguages,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Swap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Translated text output
            const Text(
              'Translation:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListenableBuilder(
                listenable: _languageService,
                builder: (context, child) {
                  final currentLang = _languageService.currentLanguage;
                  return TextField(
                    controller: _targetController,
                    maxLines: null,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Translation will appear here...',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily:
                          _languageService.getFontFamily(currentLang.code),
                    ),
                    textDirection:
                        _languageService.getTextDirection(currentLang.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPhrases() {
    return ListenableBuilder(
      listenable: _languageService,
      builder: (context, child) {
        final currentLang = _languageService.currentLanguage;
        final phrases = _translationService.getCommonPhrases(currentLang.code);

        if (phrases.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Phrases in ${currentLang.nameNative}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            _languageService.getFontFamily(currentLang.code),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: phrases.map((phrase) {
                    return ActionChip(
                      label: Text(
                        phrase,
                        style: TextStyle(
                          fontFamily:
                              _languageService.getFontFamily(currentLang.code),
                        ),
                      ),
                      backgroundColor: Colors.indigo[50],
                      onPressed: () {
                        _sourceController.text = phrase;
                        _translateToEnglish(phrase);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    if (_translationHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Translation History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _translationHistory.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _translationHistory.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text(_translationHistory[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Copy to clipboard functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _detectLanguage(String text) async {
    if (text.trim().isEmpty) {
      setState(() {
        _detectedLanguage = null;
      });
      return;
    }

    try {
      final detected = await _translationService.detectLanguage(text);
      setState(() {
        _detectedLanguage = detected;
      });
    } catch (e) {
      // Handle error silently for demo
    }
  }

  void _translateText() async {
    if (_sourceController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final currentLang = _languageService.currentLanguage;
      final translatedText = await _translationService.translate(
        _sourceController.text,
        currentLang.code,
      );

      _targetController.text = translatedText;

      // Add to history
      setState(() {
        _translationHistory.insert(
            0, '$translatedText (${currentLang.nameNative})');
        if (_translationHistory.length > 10) {
          _translationHistory = _translationHistory.take(10).toList();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _translateToEnglish(String phrase) async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final translatedText = await _translationService.translate(phrase, 'en');
      _targetController.text = translatedText;

      setState(() {
        _translationHistory.insert(0, '$translatedText (English)');
        if (_translationHistory.length > 10) {
          _translationHistory = _translationHistory.take(10).toList();
        }
      });
    } catch (e) {
      // Handle error silently for demo
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    final temp = _sourceController.text;
    _sourceController.text = _targetController.text;
    _targetController.text = temp;
  }

  void _clearAll() {
    _sourceController.clear();
    _targetController.clear();
    setState(() {
      _detectedLanguage = null;
      _translationHistory.clear();
    });
  }
}
