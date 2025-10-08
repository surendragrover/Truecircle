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
- Full bilingual support (Hindi & English)
- On-device AI with cloud fallback
- Google Translate API for enhanced translations

## 🛠️ Getting Started
```bash
git clone https://github.com/your-username/TrueCircle-App.git
cd TrueCircle-App
flutter pub get
flutter run
```

## 🆘 Having Problems? / समस्या हो रही है?

If you're experiencing difficulties with the app, we have comprehensive help available:

### Quick Help Access
1. **In-App Help Menu**: Tap the `?` icon in the app header
2. **Troubleshooting Guide**: See [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md)
3. **Common Issues**:
   - Translation not working → Check `api.env` file
   - Dr. Iris in sample mode → Download AI models from Settings
   - App running slow → Clear cache in Settings

### API Configuration
The app works without API keys, but some features are limited. To enable full functionality:

1. Copy `api.env` to your project root (already present)
2. Add your Google Translate API key:
   ```
   GOOGLE_TRANSLATE_API_KEY=your_actual_key_here
   ```
3. Get your API key from: https://console.cloud.google.com/apis/credentials

**Note**: Without API keys, the app uses fallback translations and sample AI responses. Core features still work!

### Bilingual Support
- The app fully supports Hindi (हिन्दी) and English
- Error messages appear in both languages
- Help documentation available in both languages
- Fallback translations work even without API keys

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

