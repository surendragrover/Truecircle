# TrueCircle Deprecations

Central log of deprecated APIs, pages, flags, and planned removal timelines. This supports a clean migration from legacy "Demo" terminology to privacy-first "Sample Data" / "Privacy Mode" patterns.

| Item | Type | Current Status | First Deprecated (Commit/Date) | Planned Removal | Replacement / Notes |
|------|------|----------------|--------------------------------|-----------------|---------------------|
| `DailyProgressDemoPage` (lib/pages/daily_progress_demo_page.dart) | UI Page | REMOVED (placeholder/neutralized file pending physical deletion) | 2025-10-03 | ASAP (next cleanup PR) | Use `DailyProgressPage` |
| `MoodEntryDemoPage` | UI Page | REMOVED | 2025-10-03 | Complete | Use `MoodEntryPage` |
| `ServiceLocatorDemoPage` | UI Page | REMOVED (no file; references purged) | 2025-10-03 | Complete | `ServiceLocatorPage` |
| `CommunicationTrackerDemoPage` | UI Page | REMOVED | 2025-10-03 | Complete | `CommunicationTrackerPage` |
| `SampleFeaturesShowcase` former name `DemoFeaturesShowcase` | Widget | RENAMED | 2025-10-03 | Complete | `SampleFeaturesShowcase` |
| `PermissionManager.isDemoMode` | Flag | Deprecated (forwards to `isPrivacyMode`) | 2025-10-03 | 2025-11-01 | Use `PermissionManager.isPrivacyMode` |
| Deprecated demo accessor wrappers in `privacy_service.dart` (e.g. `getDemo*`) | Service Methods | Still present | 2025-10-03 | 2025-11-15 | Use corresponding sample/privacy methods |
| `daily_progress_demo_page.dart` skip entry in token guard | Build/Tooling | Transitional ignore | 2025-10-03 | Remove when file deleted | Remove ignore line in `tool/demo_token_guard.dart` |

## Removal Process Checklist
1. Ensure no imports reference the deprecated symbol.
2. Add deprecation annotation (`@Deprecated`) where supported before removal (minimum one release / 2 weeks grace unless critical fix).
3. Update docs & README (and screenshots if relevant).
4. Run token guard and analyzer to ensure no reintroduction of legacy terms.
5. Remove transitional token guard exceptions.

## Immediate Next Removals
- Physically delete `lib/pages/daily_progress_demo_page.dart` once analyzer confirms zero references (currently tool struggled to purge; manual delete recommended).
- After deletion, edit `tool/demo_token_guard.dart` to remove the line ignoring this filename.

## Future Cleanup Targets
- Eliminate `isDemoMode` after 2025-11-01; search & replace fallback usages; then remove forwarder.
- Remove `getDemo*` wrappers in `privacy_service.dart` after 2025-11-15.

## Notes
- Token guard (CI) blocks accidental reintroduction of legacy "Demo" wording; allowed only in this file and explicit `@Deprecated` lines (or lines tagged with `// allow_demo_token`).
- Keep this file updated when adding or resolving any deprecations to maintain a single source of truth.
