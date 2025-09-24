# TrueCircle - AI Coding Agent Instructions

## 🎯 Project Overview
TrueCircle is an emotional-AI Flutter app for analyzing relationship health using communication patterns and cultural intelligence. It's privacy-focused with on-device processing and supports Hindi/English bilingual features.

## 🏗️ Architecture & Data Flow

### Core Data Models
- **Hive Storage**: All models in `lib/models/` use Hive for local persistence
  - `EmotionEntry`: Tracks user emotional states with timestamp and intensity
  - `Contact`: Rich contact data with emotional scoring and cultural metadata
  - `ContactInteraction`: Communication history with sentiment analysis
  - `PrivacySettings`: Granular privacy controls
- **Generated Files**: Use `*.g.dart` files via `hive_generator` for serialization

### Service Layer (`lib/services/`)
- **Cultural AI**: `cultural_regional_ai.dart` - Deep Indian cultural intelligence for festivals, language patterns, family dynamics
- **HuggingFace Integration**: `huggingface_service.dart` - Emotion/sentiment analysis with multilingual support
- **Privacy-First**: All AI processing happens on-device, explicit opt-in for content analysis

### UI Architecture
- **Material 3**: Uses Material Design 3 with custom theme
- **Multi-Platform**: Windows, Chrome, Android, iOS support
- **Bilingual UI**: Hindi/English with cultural context switching

## 🔧 Development Workflow

### Essential Commands
```bash
# Setup and run
flutter pub get
flutter packages pub run build_runner build  # Generate Hive adapters
flutter run -d windows                       # Desktop development
flutter run -d chrome                        # Web testing

# Use launch script
launch_truecircle.bat                        # Windows-specific launcher
```

### Code Generation
- Run `build_runner` after modifying Hive models (`@HiveType` classes)
- Localization files auto-generated from `lib/l10n/*.arb` files

### Testing Strategy
- Widget tests in `test/widget_test.dart` 
- Focus on bilingual UI and privacy settings
- Test cultural AI features with sample Hindi/English data

## 📱 Key Patterns & Conventions

### Cultural Intelligence
```dart
// Cultural AI follows specific patterns:
CulturalRegionalAI.analyzeFestivalConnections(contact, interactions);
// Returns festival recommendations with Hindi greetings
// Always include both English/Hindi text in UI responses
```

### Privacy-First Development
- **Tier 1**: Basic contact metadata (always safe)
- **Tier 2**: Communication patterns (user permission required)  
- **Tier 3**: Content analysis (explicit opt-in only)
- Check `PrivacySettings` before any data processing

### Emotion Analysis Pipeline
```dart
// Standard pattern for emotion processing:
final emotionService = EmotionService(Hive.box<EmotionEntry>('emotion_entries'));
final huggingFaceService = await HuggingFaceService.create(); // Loads API key from api.env
final analysis = await huggingFaceService.analyzeEmotion(text);
```

### Bilingual Implementation
- Use `AppLocalizations` for static text
- Dynamic AI responses include both Hindi and English
- Cultural context influences language choice (family = more Hindi, work = more English)

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

### Hive Adapter Errors
- Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
- Ensure all `@HiveType` classes have unique `typeId`

### Permission Issues  
- Check `PermissionManager.checkPermissions()` before contact access
- Graceful handling when permissions denied

### Cultural AI Edge Cases
- Handle mixed language input gracefully
- Default to neutral tone when cultural context unclear
- Respect regional communication style preferences

## 📊 Performance Considerations
- Batch process contact analysis (max 50 contacts at once)
- Cache HuggingFace results to avoid redundant API calls  
- Use `ValueListenableBuilder` with Hive for reactive UI updates
- Limit emotion analysis to recent interactions (last 30 days)

When working on this codebase, prioritize privacy compliance, cultural sensitivity, and graceful degradation of AI features.