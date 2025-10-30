# TrueCircle Flutter App - AI Coding Agent Instructions

## Architecture Overview

**TrueCircle** is an emotional health Flutter app with offline-first design, featuring CBT tools, AI assistant (Dr. Iris), and emotional wellness tracking.

### Key Architectural Patterns

**Navigation Structure:**
- `main.dart` → `_StartupGate` checks onboarding/phone status via Hive → `RootShell` with bottom nav
- `RootShell` uses `IndexedStack` for persistent state across tabs: Home, CBT Hub, Dr. Iris, More
- Each major feature has its own directory under `lib/` (cbt, iris, emotional_awareness, etc.)

**Data Layer:**
- **Hive** for local storage (see `core/hive_initializer.dart` for adapter registration)
- **JSON assets** in `assets/` and `data/` for static content (CBT techniques, AI prompts, demo data)
- **Service pattern**: Singleton services in `lib/services/` for data access (e.g., `JsonDataService`, `DrIrisSuggestionsService`)

**Offline-First Design:**
- All features work without network connectivity
- On-device AI model via `OnDeviceAIService` (Android TFLite)
- Local JSON files for CBT content, psychology articles, emotional awareness data

## Development Conventions

### File Organization
```
lib/
├── core/           # App-wide utilities (theme, Hive, service locator)
├── models/         # Hive models with manual adapters (avoid build_runner)
├── services/       # Data access layer with singleton pattern
├── [feature]/      # Feature modules (cbt, iris, home, auth, etc.)
└── main.dart       # Entry point with startup flow
```

### State Management
- **Minimal state**: Prefer `StatelessWidget` with service calls
- **Hive boxes**: Use `await Hive.openBox('box_name')` pattern for persistence
- **Service Locator**: `ServiceLocator.instance.get<T>()` for dependency injection (see `core/service_locator.dart`)

### UI Patterns
- **Material 3**: All components use `AppTheme.light()` from `core/app_theme.dart`
- **Card-based layouts**: Consistent `_HubTile` pattern in feature hubs
- **Page structure**: `AppBar` + scrollable body, minimal nested navigation

### Asset Management
- **Static content**: JSON files in `assets/` and `data/` folders
- **Localization ready**: English-only currently, but JSON structure supports i18n
- **AI content**: Prompts in `assets/ai/`, models in `assets/models/`

## Development Workflows

### Adding New Features
1. Create feature directory under `lib/[feature]/`
2. Add route to appropriate hub page (e.g., `CBTHubPage` for CBT features)
3. Register any Hive models in `core/hive_initializer.dart`
4. Add assets to `pubspec.yaml` if needed

### Working with AI/ML
- Dr. Iris responses use `OnDeviceAIService` abstraction
- Fallback to static suggestions from `assets/ai/dr_iris_suggestions.json`
- TFLite model at `assets/models/TrueCircle.tflite` (Android only)

### Data Flow
```
UI → Service → Hive/Asset → UI
```
- Services cache JSON data in memory (see `JsonDataService._cached*` pattern)
- Hive models use manual adapters to avoid build_runner complexity
- All async operations return safe defaults on failure

### Testing/Debugging
- Use `flutter analyze` for linting (follows `package:flutter_lints/flutter.yaml`)
- Demo data in `data/` folder for UI testing without real user data
- Error handling: Services return empty lists/default values rather than throwing

## Key Integration Points

- **Hive Storage**: Models must be registered in `HiveInitializer.registerAdapters()`
- **Theme System**: Use `Theme.of(context).colorScheme` for consistent colors
- **Service Registration**: Register services in `ServiceLocator` before use
- **Asset Loading**: Use `rootBundle.loadString()` pattern with try-catch for missing assets
- **Navigation**: Prefer `Navigator.push()` over named routes for simplicity

## Anti-Patterns to Avoid

- Don't use `build_runner` for Hive adapters (manual adapters preferred)
- Avoid network calls (offline-first philosophy)
- Don't nest navigation too deeply (keep flat structure)
- Avoid global state beyond service locator registry
- Don't skip error handling in asset loading or Hive operations