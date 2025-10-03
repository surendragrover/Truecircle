# Changelog

## 1.0.0-beta+1 (2025-10-04)

### Added
- Unified AI Insights Card: Consolidated daily AI suggestions (breathing, meditation, festival, event planning) with orchestrator feature insights into a single on‑device privacy-first panel.
- Offline Dictionary Translator: Lightweight EN→HI token translator with auto Hindi toggle persisted via Hive for article creation.
- CBT Center Modules: Added CBT assessments (PHQ‑9, GAD‑7 demos), Thought Diary, Coping Cards, Micro Lessons, Psychology Articles with tokenized sharing.
- Article P2P Token Sharing: Create, tokenize, redeem, and batch redeem psychology articles; export & inject article stats into orchestrator insights.
- Virtual Gifts System Enhancements: Collapsed Gifts & Bundles ExpansionTile with info dialog, recommended gift badge logic, bundle support, share/redeem codes.
- Metrics Aggregation & Orchestrator Services: Added metrics snapshot, reconnect detection, festival highlight integration, and unified insights injection.
- Festival & Cultural Data: Festival highlight badge, festival message suggestions, bilingual event planning tips.
- Hypnotherapy & Breathing/Meditation Sample Data services.
- Feedback collection (offline) and anonymized summary export.
- Dashboard Feature Visibility CSV for auditing visible vs deep features.

### Changed
- Refactored dashboard layout to prioritize AI-first experience; moved unified AI card near top; collapsed gifts section.
- Updated CBT article creation flow to remove build context usage across async gaps (zero analyzer issues remaining).
- Replaced deprecated `withOpacity` calls with `withValues` for Color alpha adjustments.
- Improved string concatenations -> interpolation & added const optimizations across pages.
- Added info dialog for Gifts & Bundles explaining privacy & points usage.

### Removed
- Legacy `AIDailySuggestionsSection` widget (functionality merged into unified AI card).
- Communication tracker demo page placeholder & unused legacy stubs.

### Fixed
- Eliminated all analyzer lints (including use_build_context_synchronously) – current status: 0 issues.
- YAML indentation issue in `pubspec.yaml` for translation assets.
- Async context safety in token creation dialogs (navigator/messenger captured before awaits).

### Privacy & Offline
- Reinforced zero-permission sample mode patterns: all AI insights generated on-device; no external data upload.
- Offline model download banner with simulated progress & platform labeling.

### Developer Notes
- New services and models added under `lib/services` & `lib/models` require running:
  `flutter packages pub run build_runner build --delete-conflicting-outputs` for Hive model codegen.
- Consider pruning disabled Firebase dependencies or gating them behind feature flags before production release.

---
Next planned (not yet implemented): quick actions refactor, tag filtering & archive distinction for articles, progress snapshot enhancements, optional shimmer placeholders.
