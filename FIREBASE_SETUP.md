# Firebase Setup Instructions

## Missing google-services.json File

Your app build is failing because the Firebase configuration file is missing.

### Steps to Fix:

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com/
   - Select your project: `truecircle-43256654`

2. **Download google-services.json:**
   - Go to Project Settings (⚙️ icon)
   - Select your Android app
   - Click "Download google-services.json"

3. **Place the file:**
   - Copy `google-services.json` to: `android/app/google-services.json`
   - The file should be at: `C:\Users\suren\flutter_app\TC\android\app\google-services.json`

4. **File Structure Should Look Like:**
   ```
   android/
   ├── app/
   │   ├── google-services.json  ← This file is required
   │   ├── build.gradle.kts
   │   └── src/
   ```

### Alternative: Temporary Fix for Development

If you want to build without Firebase temporarily, you can disable Firebase plugins.

### Current Configuration:
- Firebase Core: ✅ Configured in code
- Firebase Analytics: ✅ Configured in code  
- Firebase Crashlytics: ✅ Configured in code
- Missing: google-services.json file

### After adding the file, run:
```bash
flutter clean
flutter pub get
flutter build apk --release
```