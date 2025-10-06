# 🚀 TrueCircle Google APIs Setup Guide

## 📋 Step-by-Step Setup Instructions

### 1. 🌐 Google Cloud Console Setup

#### A. Create Project
1. Visit: https://console.cloud.google.com/
2. Click "New Project"
3. Name: `truecircle-app`
4. Click "Create"

#### B. Enable Required APIs
Navigate to "APIs & Services" > "Library" and enable:

✅ **AI & Machine Learning APIs:**
- Google Gemini API
- Cloud Translation API
- Natural Language API

✅ **Maps & Location APIs:**
- Maps JavaScript API
- Places API
- Geocoding API

✅ **Firebase APIs:**
- Firebase Realtime Database API
- Cloud Firestore API
- Firebase Authentication API

✅ **Other APIs:**
- YouTube Data API (future)
- Google Drive API (backup)

#### C. Create API Keys
1. Go to "Credentials" > "Create Credentials" > "API Key"
2. Create separate keys for:
   - **General Cloud API Key**
   - **Gemini AI Key**
   - **Translation Key** 
   - **Maps Key**
   - **Places Key**

#### D. Restrict API Keys (Security)
For each key, click "Restrict Key" and:
- **Application restrictions**: Add your app package name
- **API restrictions**: Limit to specific APIs only

### 2. 🤖 Google Gemini AI Setup

#### Get Gemini API Key:
1. Visit: https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy key to `api.env`: `GOOGLE_GEMINI_API_KEY=your_key_here`

#### Gemini Pro Features:
- Cultural context understanding
- Hindi-English conversations
- Relationship advice generation
- Festival recommendations

### 3. 🌐 Google Translate API Setup

#### Enable Translation API:
1. In Cloud Console, enable "Cloud Translation API"
2. Create restricted API key
3. Add to `api.env`: `GOOGLE_TRANSLATE_API_KEY=your_key_here`

#### Translation Features:
- Hindi ↔ English translation
- Auto language detection
- Cultural context preservation
- On-device ML Kit (no API key needed)

### 4. 🗺️ Google Maps & Places Setup

#### Maps API:
1. Enable "Maps JavaScript API"
2. Create restricted key
3. Add domains: `localhost`, your app domain
4. Add to `api.env`: `GOOGLE_MAPS_API_KEY=your_key_here`

#### Places API:
1. Enable "Places API"
2. Create restricted key
3. Add to `api.env`: `GOOGLE_PLACES_API_KEY=your_key_here`

### 5. 📱 Google AdMob Setup

#### Create AdMob Account:
1. Visit: https://apps.admob.com/
2. Sign in with Google account
3. Click "Add App" > "Add your app manually"
4. App name: "TrueCircle"
5. Platform: Android/iOS

#### Generate Ad Unit IDs:
**Banner Ads:**
```
ADMOB_BANNER_AD_ID=ca-app-pub-YOUR_PUBLISHER_ID/BANNER_UNIT_ID
```

**Interstitial Ads:**
```
ADMOB_INTERSTITIAL_AD_ID=ca-app-pub-YOUR_PUBLISHER_ID/INTERSTITIAL_UNIT_ID
```

**Rewarded Ads:**
```
ADMOB_REWARDED_AD_ID=ca-app-pub-YOUR_PUBLISHER_ID/REWARDED_UNIT_ID
```

#### App IDs:
```
ADMOB_APP_ID_ANDROID=ca-app-pub-YOUR_PUBLISHER_ID~APP_ID
ADMOB_APP_ID_IOS=ca-app-pub-YOUR_PUBLISHER_ID~APP_ID
```

### 6. 🔐 Google Sign-In Setup

#### OAuth 2.0 Setup:
1. Go to Cloud Console > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"

#### For Android:
1. Application type: "Android"
2. Package name: `com.truecircle.app`
3. SHA-1 certificate fingerprint (get from `keytool`)
4. Copy Client ID to `api.env`

#### For iOS:
1. Application type: "iOS"
2. Bundle ID: `com.truecircle.app`
3. Copy Client ID to `api.env`

#### For Web:
1. Application type: "Web application"
2. Add authorized domains
3. Copy Client ID to `api.env`

### 7. 🔥 Firebase Setup

#### Create Firebase Project:
1. Visit: https://console.firebase.google.com/
2. Click "Create a project"
3. Project name: `truecircle-app`
4. Enable Google Analytics (optional)

#### Add Apps:
**Android App:**
1. Click "Add app" > Android
2. Package name: `com.truecircle.app`
3. Download `google-services.json`
4. Place in `android/app/`

**iOS App:**
1. Click "Add app" > iOS
2. Bundle ID: `com.truecircle.app`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`

**Web App:**
1. Click "Add app" > Web
2. App nickname: `TrueCircle Web`
3. Copy Firebase config to `web/index.html`

### 8. 📄 Update api.env File

Copy this template and fill in your real keys:

```env
# Google Cloud APIs
GOOGLE_CLOUD_API_KEY=AIzaSy_your_actual_cloud_api_key_here
GOOGLE_GEMINI_API_KEY=AIzaSy_your_actual_gemini_key_here
GOOGLE_TRANSLATE_API_KEY=AIzaSy_your_actual_translate_key_here
GOOGLE_MAPS_API_KEY=AIzaSy_your_actual_maps_key_here
GOOGLE_PLACES_API_KEY=AIzaSy_your_actual_places_key_here

# AdMob IDs
ADMOB_APP_ID_ANDROID=ca-app-pub-your_publisher_id~your_app_id
ADMOB_APP_ID_IOS=ca-app-pub-your_publisher_id~your_app_id
ADMOB_BANNER_AD_ID=ca-app-pub-your_publisher_id/your_banner_id
ADMOB_INTERSTITIAL_AD_ID=ca-app-pub-your_publisher_id/your_interstitial_id
ADMOB_REWARDED_AD_ID=ca-app-pub-your_publisher_id/your_rewarded_id

# OAuth Client IDs
GOOGLE_CLIENT_ID_ANDROID=your_android_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_ID_IOS=your_ios_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_ID_WEB=your_web_client_id.apps.googleusercontent.com
```

### 9. 🔒 Security Configuration

#### API Key Restrictions:
- **HTTP referrers**: Add your domains
- **Android apps**: Add package name + SHA-1
- **iOS apps**: Add bundle identifier
- **API restrictions**: Limit to specific APIs only

#### Quotas & Limits:
- Set daily quotas to prevent overuse
- Monitor usage in Cloud Console
- Set up billing alerts

### 10. ✅ Testing Your Setup

#### Verify API Keys:
```bash
# Test Gemini API
curl -H "Content-Type: application/json" \
     -d '{"contents":[{"parts":[{"text":"Hello"}]}]}' \
     -X POST https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_KEY

# Test Translation API
curl -X POST \
     -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d @request.json \
     "https://translation.googleapis.com/language/translate/v2?key=YOUR_KEY"
```

#### Test in TrueCircle:
1. Run app: `flutter run`
2. Navigate to "Google APIs" feature
3. Test each service:
   - ✅ Sign in with Google
   - ✅ Translate Hindi ↔ English
   - ✅ Generate AI responses
   - ✅ Show AdMob ads

### 11. 💰 Pricing & Quotas

#### Free Tiers:
- **Gemini API**: 15 requests/minute free
- **Translation**: 500K characters/month free
- **Maps**: $200 monthly credit
- **AdMob**: You earn revenue!
- **Firebase**: Generous free tier

#### Paid Tiers:
Monitor usage and upgrade when needed.

### 12. 🚀 Production Deployment

#### Before Release:
- [ ] Replace all test API keys with production keys
- [ ] Set up proper API key restrictions
- [ ] Configure AdMob with real ad units
- [ ] Test on multiple devices
- [ ] Monitor API quotas and billing
- [ ] Set up error monitoring

#### App Store Requirements:
- [ ] Add privacy policy for Google services
- [ ] Comply with Google Play/App Store policies
- [ ] Handle API failures gracefully
- [ ] Provide offline functionality

---

## 🎯 Final Result

आपका TrueCircle app अब completely equipped है:

✅ **Google Gemini AI** for cultural intelligence  
✅ **Cloud Translation** for Hindi-English support  
✅ **Google Maps & Places** for location features  
✅ **AdMob** for monetization  
✅ **Google Sign-In** for authentication  
✅ **Firebase** for backend services  
✅ **ML Kit** for on-device processing  

**Total Cost**: $0 - $50/month depending on usage  
**Setup Time**: 2-4 hours  
**Maintenance**: Minimal  

🚀 **Your app is now professional-grade with Google's powerful APIs!**

---

*Last updated: September 28, 2025*  
*Support: Check Google Cloud Console for detailed docs*