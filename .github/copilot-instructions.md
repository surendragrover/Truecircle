# TrueCircle - AI Coding Agent Instructions

## 🎯 Project Overview
TrueCircle is a privacy-first Flutter app for emotional relationship analysis using cultural AI and on-device processing. Currently optimized for Google Play Store compliance with zero-permission architecture and mock data patterns.

## 🏗️ Architecture & Critical Patterns

### Zero-Permission Privacy Model
- **CRITICAL**: App runs in "sample mode" only (`PermissionManager.isSampleMode = true`)
- NO real device permissions requested (Google Play Store compliant)
- All analysis uses `Demo_data/*.json` files via `JsonDataService`
- Mock implementations for all external services (auth, contacts, etc.)

### Data Layer Architecture
- **Hive Storage**: `lib/models/` with `*.g.dart` generated files (run `flutter packages pub run build_runner build`)
- **JSON Assets**: Real data loaded from `Demo_data/` folder, cached by `JsonDataService.instance`
- **Cultural AI**: `CulturalRegionalAI` loads festivals data for Indian context
- **Mock Services**: Firebase disabled, auth uses mock patterns in `AuthService`

### Service Dependencies (Current State)
```yaml  
# Firebase DISABLED for compatibility - uses mock implementations
# HuggingFace integration requires null-safety fixes (_token!.isNotEmpty)
# Permission system always returns safe/sample values
```

## 🔧 Development Workflow & Build Issues

### Current Technical Challenges
- **Firebase Disabled**: All Firebase deps commented out in pubspec.yaml
- **Dependency Conflicts**: 17 packages outdated due to version constraints  
- **Null Safety**: HuggingFace service needs `_token!.isNotEmpty` patterns
- **Build Failures**: Chrome/Windows builds fail on Firebase type resolution

### Essential Commands
```bash
# Clean build process (required for dependency issues)
flutter clean
Remove-Item -Path "build","dart_tool" -Recurse -Force  # PowerShell
flutter pub get
flutter packages pub run build_runner build

# Testing platforms
flutter run -d chrome    # Web testing (currently failing)
flutter run -d windows   # Desktop (Firebase C++ compilation issues)
flutter build apk        # Android build (main target)
```

### Code Generation Dependencies
- Hive models require `@HiveType(typeId: X)` with unique IDs
- Build runner conflicts: use `build_runner: ^2.4.13` (not latest)
- Always run after model changes: `build_runner build --delete-conflicting-outputs`

## 📱 Key Development Patterns

### JSON Data Loading Pattern
```dart
// Standard pattern for loading demo data:
final jsonService = JsonDataService.instance;
final festivalsData = await jsonService.getFestivalsData();
final relationshipData = await jsonService.getRelationshipData();
```

### Cultural AI Integration
```dart
// CulturalRegionalAI loads from JsonDataService, not hardcoded data:
final analysis = await CulturalRegionalAI.analyzeFestivalConnections(contact, interactions);
// Always returns bilingual responses (Hindi/English)
```

### Mock Service Implementation
```dart
// All external services use mock patterns:
class AuthService {
  bool _isLoggedIn = false;
  Future<String?> signIn() async => _isLoggedIn = true; // Mock implementation
}
```

### Null Safety & Firebase Compatibility
```dart
// Current workarounds for build issues:
if (_token != null && _token!.isNotEmpty)  // HuggingFace pattern
// import 'package:firebase_core/firebase_core.dart'; // Commented out
```

### Bilingual UI Implementation
- Static text: `AppLocalizations` from generated `.arb` files
- Dynamic AI responses: Both Hindi/English in same response
- Cultural context switching based on contact relationship type

## 🎨 UI Components & Styling

### Theme System
- Custom theme in `main.dart` with seed color `Colors.blue`
- Card-based design with 12px border radius
- Cultural color coding: Orange (festivals), Blue (relationships), Purple (emotions)

### Widget Structure
- `widgets/truecircle_logo.dart`: Logo with multiple styles
- `widgets/cultural_ai_dashboard.dart`: Festival and regional intelligence
- `widgets/interactive_ai_ui.dart`: Conversational AI interface
- Consistent use of emoji for emotional expression

### Navigation Patterns
- Tab-based navigation via floating action buttons
- Modal dialogs for data entry (emotion logging, contact editing)
- Contextual menus for advanced features

## 🔌 External Integrations

### HuggingFace AI
- API key stored in `api.env` (never commit this file)
- Models: emotion analysis, sentiment, multilingual support
- Graceful degradation when API unavailable

### Payment & Monetization
- Tiered features: Free (limited AI), Premium (unlimited)
- Razorpay integration for Indian market
- Google Mobile Ads for free tier

## 🚀 Feature Development Guidelines

### Adding New AI Features
1. Check privacy tier in `PRIVACY_STRATEGY.md`
2. Add to `FeatureManager` with appropriate gating
3. Implement culturally appropriate responses
4. Test with Hindi/English content

### Contact Analysis Enhancements
- Always preserve existing `Contact.metadata` structure
- Update `lastAnalyzed` timestamp after processing
- Respect `PrivacySettings` for each analysis type

### Festival & Cultural Features
- Use `CulturalRegionalAI.getUpcomingFestivals()` for current data
- Include regional variations (North/South India differences)
- Generate appropriate greetings in user's preferred language

## 🐛 Common Issues & Solutions

### Build Failures
- **Chrome Build**: Firebase type errors → Comment out Firebase imports
- **Windows Build**: C++ compilation errors → Use mock auth implementations  
- **APK Build**: Asset bundling errors → Check pubspec.yaml asset paths
- **Permission Errors**: Build folders locked → `Remove-Item -Recurse -Force build`

### Dependency Version Conflicts
- **Analyzer Conflicts**: Use `build_runner: ^2.4.13` not latest
- **HuggingFace Null Safety**: Use `_token!.isNotEmpty` pattern
- **Firebase Compatibility**: Keep Firebase deps commented out in pubspec.yaml

### Hive Code Generation
- Run `build_runner build --delete-conflicting-outputs` after model changes
- Ensure unique `typeId` for each `@HiveType` class
- Generated `*.g.dart` files must be committed to version control

## 🚀 Feature Development Guidelines

### Privacy-Safe Implementation
- Always check `PermissionManager.isSampleMode` (always returns true)
- Use `Demo_data/*.json` files instead of real device data
- Implement graceful fallbacks when external APIs unavailable
- Mock all external service dependencies

### Cultural Features
- Festival data comes from `Demo_data/TrueCircle_Festivals_Data.json`
- Regional AI responses include both Hindi/English text
- Use `CulturalRegionalAI.getUpcomingFestivals()` for current context

### Performance Patterns
- JsonDataService caches loaded data automatically
- Use `ValueListenableBuilder` with Hive boxes for reactive UI
- Batch process large datasets to prevent UI blocking

When working on this codebase, prioritize Google Play Store compliance, mock data patterns, and build compatibility over feature completeness.