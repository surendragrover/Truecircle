# truecircle

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## iOS Build

iOS build ke liye macOS machine (Xcode + CocoaPods) required hai.

Local build commands (macOS):

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release --no-codesign --obfuscate --split-debug-info=build/ios/symbols
```

Repository me CI workflow add hai:

- File: `.github/workflows/ios-build.yml`
- Trigger: `main/master` push ya manual `workflow_dispatch`
- Output artifact: `ios-runner-app` (`Runner.app.zip`)

Signed IPA banane ke liye Apple signing/certificates ke saath:

```bash
flutter build ipa --release
```

`ExportOptions.plist` based signed IPA (recommended for repeatable release):

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions-AppStore.plist
```

Signing checklist:

1. Xcode me `Runner` target ka bundle identifier set karo (example: `com.yourcompany.truecircle`).
2. Apple Developer portal me App ID create/verify karo.
3. Distribution certificate install karo (Keychain me).
4. App Store provisioning profile create karke machine par install karo.
5. `ios/ExportOptions-AppStore.plist` me:
   - `teamID` update karo
   - `provisioningProfiles` key me actual bundle id aur profile name set karo
6. Release archive/IPA generate karke TestFlight/App Store Connect me upload karo.
