# TrueCircle

TrueCircle is a Flutter app focused on emotional support, guided reflection, and structured conversation flows.

## Project Status

- Android build is stabilized after native toolchain alignment.
- Prompt engine routing supports:
  - `relationship`
  - `app_management`
  - `general`
- Hindi/Urdu native script and roman cues are supported in prompt routing.

## Requirements

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Android Studio + Android SDK + NDK + CMake
- Java 17
- For iOS builds: macOS + Xcode + CocoaPods

## Local Setup

```bash
flutter pub get
```

Run app (debug):

```bash
flutter run
```

## Android Build

Debug APK:

```bash
flutter build apk --debug
```

Release AAB (recommended for Play Store):

```bash
flutter build appbundle --release
```

Notes:

- Native toolchain is pinned for compatibility in Gradle config.
- If native cache issues appear, clear and rebuild:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## iOS Build

iOS build requires macOS machine with Xcode and CocoaPods.

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release --no-codesign --obfuscate --split-debug-info=build/ios/symbols
```

Signed IPA:

```bash
flutter build ipa --release
```

With export options:

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions-AppStore.plist
```

## Investor/Release Docs

Plain text docs are available in:

- `investers/INVESTOR_UPDATE.txt`
- `investers/PLAY_STORE_RELEASE_NOTES.txt`
- `investers/PRE_ROLLOUT_QA_CHECKLIST.txt`

## Useful Links

- [Flutter Docs](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
