# योगदान दिशानिर्देश / Contributing Guidelines

TrueCircle में योगदान देने के लिए धन्यवाद! 🙏  
Thank you for contributing to TrueCircle! 🙏

## 📋 विषय-सूची / Table of Contents

- [आचार संहिता / Code of Conduct](#code-of-conduct)
- [शुरुआत कैसे करें / Getting Started](#getting-started)
- [विकास वर्कफ़्लो / Development Workflow](#development-workflow)
- [Git वर्कफ़्लो / Git Workflow](#git-workflow)
- [कोडिंग मानक / Coding Standards](#coding-standards)
- [कमिट संदेश / Commit Messages](#commit-messages)
- [पुल रिक्वेस्ट प्रक्रिया / Pull Request Process](#pull-request-process)
- [टेस्टिंग / Testing](#testing)
- [Privacy-First Development](#privacy-first-development)

## 📜 आचार संहिता / Code of Conduct

### हमारी प्रतिबद्धता / Our Pledge

- सभी योगदानकर्ताओं का सम्मान करें / Respect all contributors
- रचनात्मक फीडबैक दें / Provide constructive feedback
- Privacy-first approach का पालन करें / Follow privacy-first approach
- सांस्कृतिक संवेदनशीलता बनाए रखें / Maintain cultural sensitivity

## 🚀 शुरुआत कैसे करें / Getting Started

### आवश्यक शर्तें / Prerequisites

```bash
# Flutter SDK
Flutter 3.35.4 or higher
Dart 3.9.2 or higher

# Required Tools
- Git
- Android Studio / VS Code
- Chrome (for web testing)
```

### रिपॉजिटरी सेटअप / Repository Setup

```bash
# 1. Fork the repository on GitHub
# GitHub पर repository को fork करें

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/Truecircle.git
cd Truecircle

# 3. Add upstream remote
git remote add upstream https://github.com/surendragrover/Truecircle.git

# 4. Install dependencies
flutter pub get

# 5. Generate code
flutter packages pub run build_runner build

# 6. Verify setup
flutter doctor
flutter run -d chrome
```

## 🔄 विकास वर्कफ़्लो / Development Workflow

### 1. Issue से शुरू करें / Start with an Issue

- मौजूदा issue खोजें या नया बनाएं / Find existing issue or create new one
- Issue में अपनी रुचि व्यक्त करें / Express interest in the issue
- समाधान पर चर्चा करें / Discuss solution approach

### 2. Branch बनाएं / Create a Branch

```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 3. विकास / Development

```bash
# Make your changes
# अपने बदलाव करें

# Run frequently
flutter run -d chrome

# Check for errors
flutter analyze

# Format code
dart format .
```

### 4. टेस्ट करें / Test

```bash
# Run tests
flutter test

# Test on different platforms
flutter run -d android
flutter run -d windows
flutter run -d chrome
```

## 🌳 Git वर्कफ़्लो / Git Workflow

### Branch Strategy / ब्रांच रणनीति

```
main (production)
├── develop (integration branch - not used currently)
├── feature/new-feature-name
├── fix/bug-fix-name
├── docs/documentation-update
├── refactor/code-improvement
└── hotfix/critical-fix
```

### Branch नामकरण / Branch Naming

```bash
# Feature branches
feature/cultural-ai-enhancement
feature/hindi-language-support
feature/festival-reminders

# Bug fix branches
fix/hive-adapter-registration
fix/firebase-auth-error
fix/ui-rendering-issue

# Documentation branches
docs/update-readme
docs/api-documentation

# Refactoring branches
refactor/service-locator
refactor/optimize-ai-service
```

## 💻 कोडिंग मानक / Coding Standards

### Flutter/Dart Best Practices

```dart
// 1. Use meaningful variable names
// सार्थक variable names का उपयोग करें
final String userName = 'Dr. Iris';  // Good ✓
final String u = 'Dr. Iris';         // Bad ✗

// 2. Add comments in Hindi or English
// Hindi या English में comments जोड़ें
// यह function user का mood analyze करता है
// This function analyzes user's mood
Future<String> analyzeMood(String input) async {
  // Implementation
}

// 3. Follow privacy-first pattern
// Privacy-first pattern का पालन करें
if (PermissionManager.isSampleMode) {
  // Use demo data
  return await JsonDataService.instance.getData();
}

// 4. Handle errors gracefully
// Errors को gracefully handle करें
try {
  await apiCall();
} catch (e) {
  debugPrint('Error: $e');
  return fallbackValue;
}
```

### File Organization

```
lib/
├── core/           # Core utilities
├── models/         # Data models
├── services/       # Business logic
├── pages/          # UI screens
├── widgets/        # Reusable widgets
└── l10n/           # Localization
```

## 📝 कमिट संदेश / Commit Messages

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types / प्रकार

```
feat:     नई सुविधा / New feature
fix:      बग फिक्स / Bug fix
docs:     डॉक्यूमेंटेशन / Documentation
style:    कोड फॉर्मेटिंग / Code formatting
refactor: कोड रीफैक्टरिंग / Code refactoring
test:     टेस्ट्स / Tests
chore:    बिल्ड/टूल परिवर्तन / Build/tool changes
perf:     परफॉर्मेंस / Performance
ci:       CI/CD changes
```

### Examples / उदाहरण

```bash
# Good commits
feat(ai): add Gemini Nano integration for Android
fix(auth): resolve Firebase authentication timeout
docs(readme): update installation instructions in Hindi
refactor(services): optimize AI service initialization
style(ui): improve Material 3 theme consistency

# Bad commits
update code
fix bug
changes
wip
```

### Commit करने से पहले / Before Committing

```bash
# Stage changes
git add .

# Check what will be committed
git status
git diff --staged

# Commit with meaningful message
git commit -m "feat(cultural-ai): add festival recommendation system"

# Or use interactive commit for multiple changes
git add -p
git commit
```

## 🔃 पुल रिक्वेस्ट प्रक्रिया / Pull Request Process

### 1. अपने बदलाव Push करें / Push Your Changes

```bash
# Push to your fork
git push origin feature/your-feature-name
```

### 2. PR बनाएं / Create Pull Request

- GitHub पर अपने fork में जाएं / Go to your fork on GitHub
- "Compare & pull request" पर क्लिक करें / Click "Compare & pull request"
- PR template भरें / Fill in the PR template
- स्क्रीनशॉट जोड़ें (यदि UI changes हों) / Add screenshots (if UI changes)

### 3. PR Checklist

- [ ] कोड अच्छी तरह से टेस्ट किया गया है / Code is well tested
- [ ] सभी टेस्ट्स पास हो रहे हैं / All tests pass
- [ ] Documentation अपडेट किया गया / Documentation updated
- [ ] Commit messages स्पष्ट हैं / Commit messages are clear
- [ ] Privacy Mode में टेस्ट किया / Tested in Privacy Mode
- [ ] Hindi और English दोनों में टेस्ट किया / Tested in both languages
- [ ] Build errors नहीं हैं / No build errors
- [ ] Code formatted है / Code is formatted

### 4. Review Process

- Maintainers आपके PR को review करेंगे / Maintainers will review your PR
- Requested changes करें / Make requested changes
- Discussion में भाग लें / Participate in discussions
- Approval के बाद merge होगा / Will be merged after approval

## 🧪 टेस्टिंग / Testing

### Unit Tests

```dart
// test/services/ai_service_test.dart
test('AI service should return valid response', () async {
  final aiService = MockAIService();
  final response = await aiService.generateResponse('test');
  expect(response, isNotEmpty);
});
```

### Widget Tests

```dart
// test/widgets/emotion_card_test.dart
testWidgets('Emotion card should display correctly', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Emotions'), findsOneWidget);
});
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/
```

## 🔒 Privacy-First Development

### Key Principles / मुख्य सिद्धांत

1. **Always use Sample Mode**
   ```dart
   // हमेशा sample mode check करें
   if (PermissionManager.isSampleMode) {
     return demoData;
   }
   ```

2. **Use Demo Data**
   ```dart
   // Demo_data/*.json से data load करें
   final data = await JsonDataService.instance.getFestivalsData();
   ```

3. **No Real Permissions**
   ```dart
   // Real device permissions कभी न मांगें
   // Never request real device permissions
   ```

4. **Mock External Services**
   ```dart
   // External services को mock करें
   class MockAuthService implements AuthService {
     Future<bool> signIn() async => true;
   }
   ```

## 📱 प्लेटफ़ॉर्म-विशिष्ट विकास / Platform-Specific Development

### Android Development

```kotlin
// Android native code guidelines
// android/app/src/main/kotlin/

- Follow Kotlin best practices
- Use Method Channels for Flutter communication
- Implement Gemini Nano integration properly
```

### iOS Development

```swift
// iOS native code guidelines
// ios/Runner/

- Follow Swift best practices
- Implement Core ML integration
- Handle platform-specific features
```

## 🐛 बग फिक्स करना / Fixing Bugs

### Process

1. Issue में bug को reproduce करें / Reproduce bug in issue
2. Root cause identify करें / Identify root cause
3. Fix implement करें / Implement fix
4. Test case जोड़ें / Add test case
5. PR submit करें / Submit PR

### Example

```dart
// Before (Bug)
String? userName;
print(userName.length); // Null error

// After (Fix)
String? userName;
print(userName?.length ?? 0); // Null-safe
```

## 🌍 Multilingual Support

### Adding Translations

```bash
# Edit .arb files
lib/l10n/app_en.arb
lib/l10n/app_hi.arb

# Generate translations
flutter gen-l10n
```

### Usage

```dart
// In widgets
Text(AppLocalizations.of(context)!.welcomeMessage)

// For Hindi
Text(AppLocalizations.of(context)!.svaagatSandesh)
```

## 📞 सहायता / Getting Help

### Resources

- 📚 [Complete Documentation](TrueCircle_Complete_Documentation.md)
- 🔒 [Privacy Guide](PRIVACY_DEMO_MODE_GUIDE.md)
- 🤖 [AI Service Guide](INTELLIGENT_SERVICE_SELECTION_GUIDE.md)
- 📱 [Android Gemini Guide](ANDROID_GEMINI_NANO_GUIDE.md)

### Communication

- **GitHub Issues**: तकनीकी समस्याओं के लिए / For technical problems
- **GitHub Discussions**: सामान्य चर्चा के लिए / For general discussions
- **PR Comments**: कोड review के लिए / For code reviews

## 🙏 धन्यवाद / Thank You

आपके योगदान से TrueCircle को बेहतर बनाने में मदद मिलती है!  
Your contributions help make TrueCircle better!

Happy Coding! 🚀 आनंदमय कोडिंग! 🚀
