import 'package:flutter/material.dart';
import '../services/indian_languages_service.dart';

/// Indian Language Selector Widget
/// Dropdown with all Indian languages in their native scripts
class IndianLanguageSelector extends StatefulWidget {
  final String? selectedLanguage;
  final Function(IndianLanguage)? onLanguageChanged;
  final bool showPopularOnly;
  final bool showRegionalSections;
  final String? title;
  final TextStyle? titleStyle;

  const IndianLanguageSelector({
    super.key,
    this.selectedLanguage,
    this.onLanguageChanged,
    this.showPopularOnly = false,
    this.showRegionalSections = true,
    this.title,
    this.titleStyle,
  });

  @override
  State<IndianLanguageSelector> createState() => _IndianLanguageSelectorState();
}

class _IndianLanguageSelectorState extends State<IndianLanguageSelector> {
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode =
        widget.selectedLanguage ?? _languageService.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: widget.titleStyle ?? Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguageCode,
              isExpanded: true,
              icon: const Icon(Icons.language),
              hint: const Text('Select Language / भाषा चुनें'),
              items: _buildDropdownItems(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguageCode = newValue;
                  });

                  final language = _languageService.getLanguageByCode(newValue);
                  if (language != null && widget.onLanguageChanged != null) {
                    widget.onLanguageChanged!(language);
                  }

                  _languageService.setLanguage(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    if (widget.showPopularOnly) {
      return _languageService.popularLanguages
          .map((language) => _buildLanguageItem(language))
          .toList();
    }

    if (!widget.showRegionalSections) {
      return _languageService.availableLanguages
          .map((language) => _buildLanguageItem(language))
          .toList();
    }

    // Build regional sections
    List<DropdownMenuItem<String>> items = [];

    // Add popular languages first
    items.add(const DropdownMenuItem<String>(
      enabled: false,
      value: null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '🌟 Popular Languages / लोकप्रिय भाषाएं',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 12,
          ),
        ),
      ),
    ));

    for (final language in _languageService.popularLanguages) {
      items.add(_buildLanguageItem(language));
    }

    // Add regional sections
    _languageService.regionalLanguages.forEach((region, languages) {
      items.add(DropdownMenuItem<String>(
        enabled: false,
        value: null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '📍 $region',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 12,
            ),
          ),
        ),
      ));

      for (final language in languages) {
        if (!_languageService.popularLanguages.contains(language)) {
          items.add(_buildLanguageItem(language));
        }
      }
    });

    // Add other languages
    final otherLanguages = _languageService.availableLanguages
        .where((lang) =>
            !_languageService.popularLanguages.contains(lang) &&
            !_languageService.regionalLanguages.values
                .expand((langs) => langs)
                .contains(lang))
        .toList();

    if (otherLanguages.isNotEmpty) {
      items.add(const DropdownMenuItem<String>(
        enabled: false,
        value: null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '🗂️ Other Languages / अन्य भाषाएं',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
        ),
      ));

      for (final language in otherLanguages) {
        items.add(_buildLanguageItem(language));
      }
    }

    return items;
  }

  DropdownMenuItem<String> _buildLanguageItem(IndianLanguage language) {
    return DropdownMenuItem<String>(
      value: language.code,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Language native name (prominent)
            Expanded(
              flex: 2,
              child: Text(
                language.nameNative,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: _languageService.getFontFamily(language.code),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // English name (smaller)
            Expanded(
              flex: 1,
              child: Text(
                language.nameEnglish,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Support indicator
            const SizedBox(width: 8),
            Icon(
              language.isSupported ? Icons.check_circle : Icons.help_outline,
              size: 16,
              color: language.isSupported ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact Language Selector (for app bars, etc.)
class CompactLanguageSelector extends StatefulWidget {
  final Function(IndianLanguage)? onLanguageChanged;

  const CompactLanguageSelector({
    super.key,
    this.onLanguageChanged,
  });

  @override
  State<CompactLanguageSelector> createState() =>
      _CompactLanguageSelectorState();
}

class _CompactLanguageSelectorState extends State<CompactLanguageSelector> {
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<IndianLanguage>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _languageService.currentLanguage.nameNative,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      tooltip: 'Select Language',
      itemBuilder: (context) {
        return _languageService.popularLanguages.map((language) {
          return PopupMenuItem<IndianLanguage>(
            value: language,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language.nameNative,
                    style: TextStyle(
                      fontFamily: _languageService.getFontFamily(language.code),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  language.nameEnglish,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (IndianLanguage language) {
        _languageService.setLanguage(language.code);
        if (widget.onLanguageChanged != null) {
          widget.onLanguageChanged!(language);
        }
        setState(() {});
      },
    );
  }
}

/// Language Settings Card
class LanguageSettingsCard extends StatefulWidget {
  const LanguageSettingsCard({super.key});

  @override
  State<LanguageSettingsCard> createState() => _LanguageSettingsCardState();
}

class _LanguageSettingsCardState extends State<LanguageSettingsCard> {
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.language, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Language Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            IndianLanguageSelector(
              title: 'Primary Language / मुख्य भाषा',
              onLanguageChanged: (language) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to ${language.nameNative}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Translation toggle
            ListenableBuilder(
              listenable: _languageService,
              builder: (context, child) {
                return SwitchListTile(
                  title: const Text('Auto Translation'),
                  subtitle: const Text('Automatically translate content'),
                  value: _languageService.isTranslationEnabled,
                  onChanged: (bool value) {
                    _languageService.toggleTranslation(value);
                  },
                  secondary: const Icon(Icons.translate),
                );
              },
            ),

            const SizedBox(height: 12),

            // Current language info
            ListenableBuilder(
              listenable: _languageService,
              builder: (context, child) {
                final currentLang = _languageService.currentLanguage;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Language: ${currentLang.nameNative}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily:
                              _languageService.getFontFamily(currentLang.code),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Script: ${currentLang.script}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (_languageService.isRTL(currentLang.code))
                        const Text(
                          'Text Direction: Right to Left',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
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
}

/// Multi-language Text Widget
/// Shows text in selected language with fallback
class MultiLanguageText extends StatelessWidget {
  final Map<String, String> translations;
  final String fallbackText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const MultiLanguageText({
    super.key,
    required this.translations,
    required this.fallbackText,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = IndianLanguagesService.instance;

    return ListenableBuilder(
      listenable: languageService,
      builder: (context, child) {
        final currentLangCode = languageService.selectedLanguage;
        final text = translations[currentLangCode] ?? fallbackText;

        return Text(
          text,
          style: style?.copyWith(
                fontFamily: languageService.getFontFamily(currentLangCode),
              ) ??
              TextStyle(
                fontFamily: languageService.getFontFamily(currentLangCode),
              ),
          textAlign: textAlign,
          maxLines: maxLines,
          textDirection: languageService.getTextDirection(currentLangCode),
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        );
      },
    );
  }
}
