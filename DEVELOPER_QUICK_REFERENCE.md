# 🚀 Developer Quick Reference - Hindi Support & Error Handling

## Quick Start

### Using BilingualErrorDialog

```dart
import '../widgets/bilingual_error_dialog.dart';

// Show translation error
BilingualErrorDialog.showTranslationError(context);

// Show AI service error  
BilingualErrorDialog.showAIServiceError(context);

// Show custom error
BilingualErrorDialog.showError(
  context,
  titleEnglish: 'Something went wrong',
  titleHindi: 'कुछ गलत हो गया',
  messageEnglish: 'Please try again',
  messageHindi: 'कृपया पुनः प्रयास करें',
  solutionEnglish: 'Check your internet connection',
  solutionHindi: 'अपना इंटरनेट कनेक्शन जांचें',
  onRetry: () => _retryOperation(),
);

// Show help dialog
BilingualErrorDialog.showHelpDialog(context);

// Show offline mode info
BilingualErrorDialog.showOfflineModeInfo(context);
```

---

## Adding New Error Messages

### Step 1: Identify the error scenario
```dart
try {
  // Your code that might fail
  await someOperation();
} catch (e) {
  // Handle error with bilingual dialog
}
```

### Step 2: Use appropriate dialog
```dart
catch (e) {
  if (!mounted) return;
  
  BilingualErrorDialog.showError(
    context,
    titleEnglish: 'Operation Failed',
    titleHindi: 'ऑपरेशन विफल रहा',
    messageEnglish: 'Could not complete the operation.',
    messageHindi: 'ऑपरेशन पूरा नहीं हो सका।',
    solutionEnglish: 'Please check your settings and try again.',
    solutionHindi: 'कृपया अपनी सेटिंग्स जांचें और पुनः प्रयास करें।',
    onRetry: () {
      Navigator.pop(context);
      _retryOperation();
    },
  );
}
```

---

## Translation Service Usage

### Check if translation is available
```dart
import 'package:truecircle/services/google_translate_service.dart';

if (GoogleTranslateService.isAvailable) {
  // Use full translation
} else {
  // Use fallback translations
}
```

### Get current language
```dart
import '../services/language_service.dart';

final isHindi = LanguageService.instance.isHindi;
final languageCode = LanguageService.instance.languageCode;
```

### Show bilingual text
```dart
Text(
  isHindi 
    ? 'हिंदी में टेक्स्ट' 
    : 'Text in English'
)
```

---

## Adding Fallback Translations

### In google_translate_service.dart:

```dart
static String? _getFallbackTranslation(
    String text, String sourceLanguage, String targetLanguage) {
  final fallbackTranslations = <String, Map<String, String>>{
    // Add your translations here
    'new_word': {'hi': 'नया शब्द', 'en': 'new_word'},
    'नया शब्द': {'en': 'new_word', 'hi': 'नया शब्द'},
  };
  // ... rest of method
}
```

---

## User Notifications

### Friendly SnackBar (Recommended for non-critical info)
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isHindi 
              ? 'हिंदी में संदेश'
              : 'Message in English',
          ),
        ),
      ],
    ),
    backgroundColor: Colors.blue.shade700,
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: isHindi ? 'मदद' : 'Help',
      textColor: Colors.white,
      onPressed: () {
        BilingualErrorDialog.showHelpDialog(context);
      },
    ),
  ),
);
```

### Error Dialog (For critical errors)
```dart
BilingualErrorDialog.showError(
  context,
  titleEnglish: 'Critical Error',
  titleHindi: 'गंभीर त्रुटि',
  messageEnglish: 'Something important failed',
  messageHindi: 'कुछ महत्वपूर्ण विफल रहा',
);
```

---

## Service Status Check

### Check Translation Status
```dart
import 'package:truecircle/services/google_translate_service.dart';

final translationAvailable = GoogleTranslateService.isAvailable;

// Show status
Text(
  translationAvailable
    ? (isHindi ? 'जुड़ा हुआ ✓' : 'Connected ✓')
    : (isHindi ? 'फ़ॉलबैक मोड में' : 'Using fallback mode'),
  style: TextStyle(
    color: translationAvailable 
      ? Colors.green.shade700 
      : Colors.orange.shade700,
  ),
)
```

---

## Debug Logging

### Use consistent prefixes
```dart
debugPrint('✅ Service initialized successfully');
debugPrint('⚠️ Warning: Using fallback mode');
debugPrint('❌ Error: Service failed to initialize');
debugPrint('ℹ️ Info: Loading data...');
```

---

## Common Patterns

### Initialize Service with Error Handling
```dart
Future<void> _initializeService() async {
  try {
    await MyService.initialize();
    debugPrint('✅ MyService initialized');
    setState(() => _serviceAvailable = true);
  } catch (e) {
    debugPrint('❌ MyService initialization failed: $e');
    setState(() => _serviceAvailable = false);
    
    if (mounted) {
      // Show friendly notification
      _showServiceUnavailableNotification();
    }
  }
}
```

### Handle API Key Missing
```dart
Future<void> _initializeWithAPIKey() async {
  try {
    final apiKey = await _loadAPIKey();
    
    if (apiKey == null || apiKey.isEmpty || apiKey.contains('your_')) {
      debugPrint('⚠️ API key not configured - using fallback mode');
      setState(() => _usingFallback = true);
      return;
    }
    
    // Initialize with API key
    await service.initialize(apiKey);
    debugPrint('✅ Service initialized with API key');
    setState(() => _usingFallback = false);
    
  } catch (e) {
    debugPrint('⚠️ Error loading API key: $e');
    setState(() => _usingFallback = true);
  }
}
```

### Graceful Degradation
```dart
Future<String> getTranslation(String text) async {
  try {
    // Try primary method
    if (GoogleTranslateService.isAvailable) {
      return await GoogleTranslateService.translateText(
        text: text,
        sourceLanguage: 'en',
        targetLanguage: 'hi',
      ) ?? text;
    }
    
    // Fallback method
    return await _getFallbackTranslation(text) ?? text;
    
  } catch (e) {
    debugPrint('⚠️ Translation failed: $e - returning original');
    return text; // Always return something
  }
}
```

---

## Testing Checklist

### Before Committing
- [ ] Test without API keys (should use fallback)
- [ ] Test with invalid API keys (should show error)
- [ ] Test language switching (Hindi ↔ English)
- [ ] Test error dialogs show correctly
- [ ] Test help menu is accessible
- [ ] Check debug logs use prefixes (✅⚠️❌ℹ️)

### Manual Testing
- [ ] Open app in Hindi
- [ ] Trigger an error
- [ ] Verify bilingual message shows
- [ ] Check solution section is helpful
- [ ] Verify buttons work (Retry, OK)
- [ ] Check help menu options

---

## Code Style

### DO ✅
```dart
// Good: Bilingual text inline
Text(isHindi ? 'हिंदी' : 'English')

// Good: Use BilingualErrorDialog
BilingualErrorDialog.showError(context, ...)

// Good: Graceful fallback
result ?? fallbackResult ?? defaultValue

// Good: User-friendly debug logs
debugPrint('✅ Service ready');
```

### DON'T ❌
```dart
// Bad: English-only error
throw Exception('Error occurred');

// Bad: Silent failure
try { ... } catch (e) { /* nothing */ }

// Bad: Technical error to user
AlertDialog(content: Text('NullPointerException at line 42'));

// Bad: No fallback
return apiResult; // What if API fails?
```

---

## API Integration Pattern

### Template for New API Service

```dart
class MyNewService {
  static String? _apiKey;
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load API key
      final envString = await rootBundle.loadString('api.env');
      final envLines = envString.split('\n');
      
      for (String line in envLines) {
        if (line.startsWith('MY_API_KEY=')) {
          final keyValue = line.split('=')[1].trim();
          if (keyValue.isNotEmpty && 
              !keyValue.contains('your_') && 
              !keyValue.contains('here')) {
            _apiKey = keyValue;
          }
          break;
        }
      }
      
      _isInitialized = true;
      
      if (_apiKey != null) {
        debugPrint('✅ MyNewService initialized with API key');
      } else {
        debugPrint('⚠️ MyNewService initialized but API key not configured');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading api.env for MyNewService: $e');
      _isInitialized = true; // Still mark as initialized
    }
  }
  
  static bool get isAvailable => _isInitialized && _apiKey != null;
  
  static Future<String?> callAPI(String input) async {
    if (!_isInitialized) await initialize();
    
    if (_apiKey == null) {
      debugPrint('⚠️ MyNewService: No API key, using fallback');
      return _getFallback(input);
    }
    
    try {
      // Make API call
      final result = await _makeAPICall(input);
      return result;
    } catch (e) {
      debugPrint('⚠️ MyNewService API call failed: $e');
      return _getFallback(input);
    }
  }
  
  static String? _getFallback(String input) {
    // Provide basic fallback
    return input; // or some default
  }
}
```

---

## Quick Fix Patterns

### Problem: Service not initializing
```dart
// Add this check
if (!_isInitialized) {
  await initialize();
}
```

### Problem: Silent failure
```dart
// Add this notification
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(isHindi ? 'त्रुटि' : 'Error')),
  );
}
```

### Problem: English-only error
```dart
// Replace with
BilingualErrorDialog.showError(context, ...)
```

### Problem: No fallback
```dart
// Add fallback
return primaryMethod() ?? fallbackMethod() ?? defaultValue;
```

---

## Common Translations

```dart
final commonTranslations = {
  'Error': 'त्रुटि',
  'Loading': 'लोड हो रहा है',
  'Please wait': 'कृपया प्रतीक्षा करें',
  'Try again': 'पुनः प्रयास करें',
  'Cancel': 'रद्द करें',
  'OK': 'ठीक है',
  'Help': 'मदद',
  'Settings': 'सेटिंग्स',
  'Back': 'वापस',
  'Next': 'अगला',
  'Done': 'पूर्ण',
  'Save': 'सहेजें',
  'Delete': 'हटाएं',
  'Edit': 'संपादित करें',
  'Success': 'सफलता',
  'Failed': 'विफल',
};
```

---

## Resources

- **Full Documentation**: See `HINDI_SUPPORT_IMPROVEMENTS.md`
- **User Guide**: See `TROUBLESHOOTING_GUIDE.md`  
- **Visual Guide**: See `CHANGES_VISUAL_GUIDE.md`
- **API Setup**: See `README.md` help section

---

## Getting Help

If you're adding a new feature and need bilingual support:

1. Use `BilingualErrorDialog` for errors
2. Add fallback translations to `google_translate_service.dart`
3. Use `LanguageService.instance.isHindi` for conditional text
4. Test with and without API keys
5. Check this guide for patterns

---

**Remember**: Always fail gracefully. Users should never see technical errors or experience crashes. Every error should be explained in both languages with a solution.
