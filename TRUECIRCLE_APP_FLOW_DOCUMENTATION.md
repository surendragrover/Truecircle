# TrueCircle App Flow Documentation
## Updated User Journey with Offline AI Model Download

### 📱 Complete App Flow (Updated October 2025)

#### 1. **App Installation & First Launch**
```
User installs TrueCircle from Play Store/App Store
↓
App launches for the first time
↓
AuthWrapper checks phone verification status
↓
Shows LoginSignupPage (if not verified)
```

#### 2. **Phone Number Verification**
```
User enters phone number
↓
OTP verification process
↓
AuthService.isPhoneVerified = true
↓
AuthWrapper checks AI models download status
```

#### 3. **🆕 AI Models Download (New Flow)**
```
AuthWrapper detects: !_areModelsDownloaded()
↓
Shows ModelDownloadProgressPage
↓
Platform Detection:
• Android → Google Gemini Nano SDK (50MB)
• iPhone → Apple CoreML Models (45MB)
• Windows → TensorFlow Lite (35MB)
• Web → WebAssembly Engine (30MB)
↓
Simulated Download Process (1-2 minutes):
1. Platform compatibility check
2. Fetching AI models list
3. Starting download
4. Downloading models
5. Installing models
6. Initializing AI Engine
7. Final setup
8. ✅ Download completed
↓
Hive box: ai_models_downloaded = true
↓
Navigate to How TrueCircle Works page
```

#### 4. **Main App Access**
```
AuthWrapper checks both:
• Phone verified ✅
• Models downloaded ✅
↓
Shows GiftMarketplacePage (main app)
```

---

### 🔧 Technical Implementation

#### **AuthWrapper Logic (Updated)**
```dart
class AuthWrapper extends StatefulWidget {
  bool _areModelsDownloaded() {
    final box = Hive.box('truecircle_settings');
    return box.get('ai_models_downloaded', defaultValue: false) as bool;
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Check phone verification
    if (!_authService.isPhoneVerified) {
      return const LoginSignupPage();
    }
    
    // Step 2: Check AI models download
    if (!_areModelsDownloaded()) {
      return const ModelDownloadProgressPage();
    }
    
    // Step 3: Everything ready - show main app
    return const GiftMarketplacePage();
  }
}
```

#### **ModelDownloadProgressPage Features**
- ✅ Platform-specific model detection
- ✅ Animated progress indicator with pulse effect
- ✅ Real-time step-by-step updates
- ✅ Hindi/English bilingual support
- ✅ Persistent storage in Hive
- ✅ Automatic navigation after completion

---

### 🎯 User Experience Benefits

#### **First-Time Setup (New)**
1. **Clear Progress Indication**: Users see exactly what's happening
2. **Platform-Aware**: Shows relevant model info for their device
3. **One-Time Process**: Never happens again after first install
4. **Offline Forever**: After models download, no internet needed

#### **Educational Flow**
1. **Number Verification** → **Model Download** → **How TrueCircle Works**
2. Users understand the app's offline capabilities upfront
3. Clear explanation of privacy-first architecture

---

### 📚 Updated How TrueCircle Works Page

#### **New Content Added:**

**Getting Started Tab:**
```
📱 Complete Setup Process:
1. App Download (Play Store/App Store)
2. Number Verification (OTP)
3. ⏳ AI Models Download (1-2 minutes)
   • Android: Google Gemini Nano SDK
   • iPhone: CoreML Models  
   • Windows/Web: TensorFlow Lite Models
4. Language selection (Hindi/English)
5. Privacy Mode selection
6. Basic preferences
7. First Emotional Check-in

🔄 One-Time Download:
Models download once, app works offline forever.
```

**AI Technology Tab:**
```
📱 Platform-Specific AI Models:
• Android: Google Gemini Nano SDK (50MB)
• iPhone/iPad: Apple CoreML Models (45MB)  
• Windows: TensorFlow Lite Models (35MB)
• Web: WebAssembly AI Engine (30MB)

🔧 Smart Download System:
• Auto-detects platform
• Downloads right model automatically
• Background installation
• User waits 1-2 minutes
• Lifetime offline after download
```

---

### ❓ Updated FAQ

#### **New Questions Added:**

**General FAQ:**
```
Q: App install के बाद कैसे setup होती है?
A: Install के बाद ये steps होते हैं:
1. Number verification (OTP)
2. AI Models download (1-2 मिनट):
   • Android: Google Gemini Nano SDK
   • iPhone: CoreML Models
   • PC: TensorFlow Lite
3. Language selection
4. Privacy settings

Models एक बार download के बाद app हमेशा offline काम करती है!
```

**Technical FAQ:**
```
Q: AI Models कैसे download होते हैं?
A: App install के बाद automatic download होता है:

📱 Platform-wise Models:
• Android: Google Gemini Nano SDK (50MB)
• iPhone: Apple CoreML Models (45MB)
• Windows: TensorFlow Lite (35MB)
• Web: WebAssembly Engine (30MB)

⏱️ Download Time: 1-2 मिनट
🔄 Frequency: One-time only
📶 Required: Wi-Fi recommended
💾 Storage: Models permanently saved on device
```

---

### 🔄 Navigation Flow

```
LoginSignupPage
    ↓ (after OTP verification)
ModelDownloadProgressPage
    ↓ (after models downloaded)
HowTrueCircleWorksPage
    ↓ (user learns about app)
GiftMarketplacePage (Main App)
```

---

### 💾 Data Storage

#### **Hive Box: 'truecircle_settings'**
```dart
{
  'ai_models_downloaded': true/false,
  'models_download_date': '2025-10-01T10:30:00.000Z',
  'platform_info': 'Android Gemini Nano SDK',
  'model_size_downloaded': 50000000 // bytes
}
```

---

### 🚀 Benefits of New Flow

1. **User Education**: Users understand offline capabilities immediately
2. **Privacy Assurance**: Clear message that data stays on device
3. **Expectation Setting**: Users know it's one-time setup
4. **Platform Optimization**: Each device gets best AI performance
5. **Smooth Onboarding**: Progressive disclosure of app features

---

### 🔧 Future Enhancements

1. **Model Update System**: Check for newer models periodically
2. **Download Resume**: Handle network interruptions
3. **Storage Management**: Let users see model sizes
4. **Background Download**: Download while user explores other features
5. **Selective Downloads**: Let users choose which AI features to enable

---

### 📱 Platform-Specific Notes

#### **Android**
- Uses Google's Gemini Nano SDK
- Requires Android 8.0+ for full AI features
- Downloads during first launch

#### **iPhone/iPad**
- Uses Apple's CoreML framework
- Optimized for Neural Engine
- Smaller model size due to platform optimization

#### **Windows/Mac**
- Uses TensorFlow Lite
- CPU-optimized models
- Cross-platform compatibility

#### **Web Browser**
- WebAssembly-based AI engine
- Works in all modern browsers
- Progressive loading for better UX

---

This documentation ensures that the new offline AI model download flow is clearly explained to users and provides a seamless onboarding experience while emphasizing TrueCircle's privacy-first, offline-capable architecture.