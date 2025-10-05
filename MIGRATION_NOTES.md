# Migration Notes: Demo -> Sample / Privacy Mode Refactor (October 2025)

This document summarizes the API and terminology changes introduced during the migration from "Demo" terminology to the privacy-first "Sample" / "Privacy Mode" model.

## Summary
- All user-facing references to "Demo Mode" replaced with "Privacy Mode".
- All "Demo Data" wording replaced with "Sample Data".
- Legacy demo pages removed; primary pages now use sample naming.
- Deprecated methods retained temporarily with `@Deprecated` annotations.

## Removed / Replaced Concepts
| Old Term / API | New Term / API | Status |
| -------------- | -------------- | ------ |
| Demo Mode | Privacy Mode | Complete rename |
| Demo Data | Sample Data | Complete rename |
| `isDemoMode()` | `isPrivacyMode()` | Removed (use new) |
| `generateDemoData()` (models) | `generateSampleData()` | Old wrapper deprecated |
| `getDemoContactsData()` | `getSampleContactsData()` | Deprecated wrapper |
| `getDemoCallLogsData()` | `getSampleCallLogsData()` | Deprecated wrapper |
| `getDemoMessagesData()` | `getSampleMessagesData()` | Deprecated wrapper |
| `MoodEntryService.getDemoData()` | `MoodEntryService.getSampleData()` | Deprecated wrapper |
| `DailyProgressService.getDemoData()` | `DailyProgressService.getSampleData()` | Deprecated wrapper |
| `_generateDemoAnalysis()` | `_generateSampleAnalysis()` | Renamed |
| `_getDemoAchievements()` | `_getSampleAchievements()` | Renamed |
| Legacy pages: `mood_entry_demo_page.dart`, `daily_progress_demo_page.dart` | Use `mood_entry_page.dart`, `daily_progress_page.dart` | Removed |

## Deprecated APIs (Safe Replacements)
```dart
@Deprecated('Use getSampleContactsData instead')
List<Map<String,dynamic>> getDemoContactsData();

@Deprecated('Use getSampleCallLogsData instead')
List<Map<String,dynamic>> getDemoCallLogsData();

@Deprecated('Use getSampleMessagesData instead')
List<Map<String,dynamic>> getDemoMessagesData();

@Deprecated('Use getSampleData instead')
Future<List<MoodEntry>> getDemoData(); // MoodEntryService

@Deprecated('Use getSampleData instead')
Future<List<DailyProgress>> getDemoData(); // DailyProgressService
```
Plan to remove these in the next major cleanup (target: November 2025) after confirming no remaining internal references.

## Data / Metadata Changes
- Contact, mood, mental health sample identifiers now use `sample_*` prefix.
- Metadata map keys changed from `demo: true` to `sample: true` (some legacy compatibility keys like `isDemo` may exist temporarily inside sample fixture objects).
- NLP metadata updated: `{'sample': true}` marks privacy-mode generated analysis.

## File System Changes
- Deleted: `breathing_demo_data_service.dart`, `comprehensive_demo_data_service.dart`, `mood_entry_demo_page.dart`, `daily_progress_demo_page.dart`.
- Added / Active: `breathing_sample_data_service.dart`, `comprehensive_sample_data_service.dart`.

## Privacy & Mode Behavior
- Privacy Mode always enabled in current distribution; real device permissions are not requested.
- All relationship, mood, emotion analysis relies on local sample JSON or locally generated synthetic records.

## Migration Guidance
1. Replace any usage of deprecated `getDemo*` methods with the corresponding `getSample*` method.
2. Remove conditional logic branching on `isDemoMode()`; use `isPrivacyMode()` exclusively.
3. Audit UI strings for any remaining "Demo" occurrences before shipping.
4. Plan removal: search for `@Deprecated('Use getSample` to find candidates for deletion.

## Recommended CI Guard (Concept)
Add a lint/check script that fails if new occurrences of whole word `Demo` appear under `lib/` (excluding `Demo_data/` assets and this migration file):
```bash
# pseudo-check
grep -R --line-number --word-regexp Demo lib/ | grep -v Demo_data || true
```
Integrate into your CI pipeline and fail build if output is non-empty.

## Future Cleanup Targets
- Remove deprecated wrappers after a stability window.
- Consider renaming any lingering `isDemo` flags inside sample objects to `isSample` (with a compatibility period if serialized externally—currently all local only).
- Rename assets folder `Demo_data/` to `Sample_data/` once downstream references and store listings are updated (low priority for now due to path stability).

## Changelog Entry (Suggested)
```
Refactor: Unified privacy terminology (Demo -> Privacy Mode / Sample Data). Added getSample* APIs, deprecated legacy getDemo* methods, removed legacy demo pages, and standardized internal analysis helpers.
```

---
Maintainer: Add updates here as you remove deprecated APIs or adjust privacy model.
