# TrueCircle-App

**TrueCircle** is an emotional-AI based app designed to help users understand their emotional connections, detect relationship warmth or distance, and encourage meaningful reconnections.

## ✨ Features
- Relationship proximity detection
- Emotional tone analysis
- Connection recharge suggestions
- Private, secure and on-device analysis

## 📦 Tech Stack
- Flutter (Android/iOS)
- Firebase / Supabase
- Natural Language Processing (NLP)
- Multi-language support (English first, Hindi planned)

## 🛠️ Getting Started
```bash
git clone https://github.com/your-username/TrueCircle-App.git
cd TrueCircle-App
flutter pub get
flutter run
```

## 🤝 Contributing
Please contact the owner before making any contributions. This is proprietary software.

## 📄 License
This project is proprietary software. All rights reserved by Surendra Grover.

## 🔒 Terminology Guard (Privacy Mode)
Legacy "Demo" wording has been retired in favor of privacy-first "Sample Data" / "Privacy Mode" language. A token guard ensures old terminology isn’t accidentally reintroduced.

Run locally:
```bash
dart run tool/demo_token_guard.dart
```

If it fails, replace the flagged text. To intentionally keep a deprecated reference (rare), append a comment `// allow_demo_token` on that line.

## 📦 Dependency Stability Strategy
TrueCircle prioritizes long-term runtime stability over chasing latest major versions. Key policies:

- Firebase packages intentionally pinned (3.x/5.x generation) until a scheduled migration window; upgrading piecemeal risks platform init regressions.
- build_runner held at 2.4.13 to avoid analyzer & generator churn; Hive codegen is stable here.
- fl_chart remains on 0.70.x until chart API refactor effort is allocated (1.x introduces breaking constructor/axis changes).
- flutter_lints kept at 4.x to prevent a large influx of non-critical warnings during active feature work.
- Discontinued transitive build_* packages are tolerated short-term; they disappear once the toolchain is deliberately modernized in a controlled pass.

Upgrade cadence:
1. Patch/minor (non-breaking) updates batched quarterly after smoke tests (shared_preferences, url_launcher, path_provider, lottie, etc.).
2. Major library migrations grouped (Firebase set, charts, lint rules) so regression testing is focused and reproducible.
3. After each major batch, run: demo token guard, Hive build, minimal sync validation, Android + Web smoke.

Rationale: Predictable emotional AI behavior & privacy sync correctness are higher priority than adopting latest APIs immediately. This policy reduces support load and unexpected CI breakages.

To propose an early upgrade, open an issue titled `Upgrade Proposal: <package>` with:
- Justification (security, critical bug, required feature)
- Expected breaking changes & files touched
- Rollback plan

This section prevents accidental blanket `flutter pub upgrade --major-versions` commits that could destabilize builds without review.

## 🧰 Automated Maintenance Helpers

To streamline recurring API migrations and terminology audits, the repository includes a few purpose-built Dart scripts:

- `dart run tool/demo_token_guard.dart` — Verifies that legacy "demo" phrasing isn’t reintroduced in copy. Add `// allow_demo_token` to intentionally keep a flagged occurrence.
- `dart run tools/fix_with_opacity.dart --dry-run` — Scans the codebase for deprecated `withOpacity(...)` usages and reports pending fixes. Omit `--dry-run` (optionally add `--verbose`) to rewrite them in-place to `withValues(alpha: ...)`.

Tip: run the fixer right before committing UI work that touches color styles so the analyzer stays green by default.

