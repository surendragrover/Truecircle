# TrueCircle Troubleshooting Guide / समस्या निवारण गाइड

## 🆘 समस्या हो रही है? / Having Problems?

यह गाइड TrueCircle ऐप में आने वाली सामान्य समस्याओं को हल करने में मदद करेगा।
This guide will help you solve common problems in the TrueCircle app.

---

## 🔧 सामान्य समस्याएं / Common Issues

### 1. अनुवाद काम नहीं कर रहा / Translation Not Working

**समस्या / Problem:**
- ऐप में हिंदी अनुवाद नहीं दिख रहा है
- Translation to Hindi is not showing
- सभी text अंग्रेजी में दिख रहा है
- All text appears in English only

**समाधान / Solution:**

#### विकल्प A: Google Translate API Key सेटअप करें
#### Option A: Set up Google Translate API Key

1. **Google Cloud Console खोलें / Open Google Cloud Console:**
   - जाएं: https://console.cloud.google.com/
   - Go to: https://console.cloud.google.com/

2. **नया प्रोजेक्ट बनाएं या मौजूदा चुनें:**
   - Create new project or select existing one

3. **Translation API सक्षम करें / Enable Translation API:**
   - जाएं: APIs & Services > Library
   - खोजें: "Cloud Translation API"
   - Search for: "Cloud Translation API"
   - "Enable" पर क्लिक करें

4. **API Key बनाएं / Create API Key:**
   - जाएं: APIs & Services > Credentials
   - "Create Credentials" > "API Key"
   - Key कॉपी करें / Copy the key

5. **api.env फ़ाइल में Key डालें / Add Key to api.env:**
   ```
   GOOGLE_TRANSLATE_API_KEY=your_actual_api_key_here
   ```

6. **ऐप पुनः शुरू करें / Restart the app**

#### विकल्प B: सीमित अनुवाद मोड में चलाएं
#### Option B: Use Limited Translation Mode

यदि आप API key नहीं लगाना चाहते:
If you don't want to set up API key:

- ऐप स्वचालित रूप से बुनियादी अनुवाद का उपयोग करेगा
- App will automatically use basic fallback translations
- सामान्य शब्द और वाक्यांश अनुवादित होंगे
- Common words and phrases will be translated
- पूर्ण अनुवाद के लिए API key की जरूरत होगी
- Full translation requires API key

---

### 2. डॉ. आइरिस काम नहीं कर रही / Dr. Iris Not Working

**समस्या / Problem:**
- डॉ. आइरिस केवल नमूना उत्तर दे रही है
- Dr. Iris only giving sample responses
- AI सुविधाएं उपलब्ध नहीं हैं
- AI features not available

**समाधान / Solution:**

1. **Settings में जाएं / Go to Settings:**
   - Settings > AI Models
   - सेटिंग्स > AI मॉडल

2. **AI Models डाउनलोड करें / Download AI Models:**
   - "Download Models" बटन दबाएं
   - Press "Download Models" button
   - डाउनलोड पूरा होने तक प्रतीक्षा करें
   - Wait for download to complete

3. **ऐप पुनः शुरू करें / Restart app**

4. **यदि समस्या बनी रहे:**
   - सुनिश्चित करें कि इंटरनेट कनेक्शन स्थिर है
   - Ensure internet connection is stable
   - कम से कम 500MB स्टोरेज खाली हो
   - At least 500MB storage should be free

**वैकल्पिक समाधान / Alternative:**
- डॉ. आइरिस बिना AI models के नमूना मोड में चलेगी
- Dr. Iris will work in sample mode without AI models
- यह मददगार उत्तर देगी लेकिन पूर्ण AI क्षमताओं के बिना
- It will give helpful responses but without full AI capabilities

---

### 3. ऐप धीमी चल रही है / App Running Slow

**समस्या / Problem:**
- ऐप धीमी है
- App is slow
- प्रतिक्रियाएं देर से आ रही हैं
- Responses are delayed

**समाधान / Solution:**

1. **Cache साफ़ करें / Clear Cache:**
   - Settings > Storage > Clear Cache
   - सेटिंग्स > स्टोरेज > कैश साफ़ करें

2. **पुराना डेटा हटाएं / Delete Old Data:**
   - बहुत पुराने mood entries हटाएं
   - Delete very old mood entries
   - अनावश्यक contacts हटाएं
   - Remove unnecessary contacts

3. **ऐप पुनः इंस्टॉल करें / Reinstall App:**
   - सभी डेटा का बैकअप लें
   - Backup all data first
   - ऐप अनइंस्टॉल करें
   - Uninstall app
   - फिर से इंस्टॉल करें
   - Install again

---

### 4. Features काम नहीं कर रहे / Features Not Working

**समस्या / Problem:**
- कुछ सुविधाएं उपलब्ध नहीं हैं
- Some features not available
- "Coming Soon" दिख रहा है
- Shows "Coming Soon"

**समाधान / Solution:**

**यह सामान्य है / This is normal:**
- TrueCircle नई सुविधाएं जोड़ रहा है
- TrueCircle is adding new features
- कुछ सुविधाएं अभी विकास में हैं
- Some features are under development
- अपडेट के लिए ऐप स्टोर देखें
- Check app store for updates

**अभी उपलब्ध सुविधाएं / Currently Available Features:**
✅ Dr. Iris चैट (Sample & AI मोड)
✅ Mood Tracking
✅ Contact Management
✅ Daily Progress
✅ Loyalty Points
✅ Festival Intelligence
✅ Relationship Insights

---

### 5. भाषा नहीं बदल रही / Language Not Changing

**समस्या / Problem:**
- भाषा स्विच नहीं हो रही है
- Language not switching
- Settings में बदलाव दिख नहीं रहा
- Changes in Settings not visible

**समाधान / Solution:**

1. **ऐप पूरी तरह बंद करें / Completely close app:**
   - Recent apps से ऐप बंद करें
   - Close from recent apps
   - फिर से खोलें / Reopen

2. **Language Service रीसेट करें / Reset Language Service:**
   - Settings > Language > Reset
   - सेटिंग्स > भाषा > रीसेट
   - पसंदीदा भाषा फिर से चुनें
   - Select preferred language again

3. **यदि अभी भी काम नहीं करे:**
   - ऐप की cache साफ़ करें
   - Clear app cache
   - या ऐप डेटा साफ़ करें (सभी settings रीसेट हो जाएंगी)
   - Or clear app data (will reset all settings)

---

## 🔍 सहायता के लिए संपर्क / Contact for Help

यदि समस्या अभी भी बनी रहे / If problem persists:

1. **In-App Help:**
   - Dr. Iris Dashboard > Help Icon (?)
   - "Help" button दबाएं
   - समस्या का विवरण दें

2. **GitHub Issues:**
   - https://github.com/surendragrover/Truecircle/issues
   - समस्या की रिपोर्ट करें
   - Report the issue

3. **Error Details Include करें / Include Error Details:**
   - क्या समस्या है? / What is the problem?
   - कब हुई? / When did it happen?
   - कौन सी feature में? / Which feature?
   - Screenshot यदि संभव हो / Screenshot if possible

---

## 📱 System Requirements / सिस्टम आवश्यकताएं

**Minimum:**
- Android 6.0+ या iOS 12.0+
- 2GB RAM
- 500MB खाली स्टोरेज / 500MB free storage

**Recommended:**
- Android 10.0+ या iOS 14.0+
- 4GB RAM
- 1GB खाली स्टोरेज / 1GB free storage
- स्थिर इंटरनेट कनेक्शन (AI features के लिए)
- Stable internet connection (for AI features)

---

## 🌟 Tips for Best Experience / सर्वोत्तम अनुभव के लिए सुझाव

1. **नियमित अपडेट करें / Regular Updates:**
   - ऐप को हमेशा अपडेट रखें
   - Keep the app updated always

2. **Stable Internet:**
   - AI features के लिए WiFi उपयोग करें
   - Use WiFi for AI features
   - Mobile data से बचें (बड़े downloads के लिए)
   - Avoid mobile data (for large downloads)

3. **Storage Management:**
   - कम से कम 500MB खाली स्टोरेज रखें
   - Keep at least 500MB free storage
   - पुराने entries साफ़ करते रहें
   - Clean old entries periodically

4. **Battery Optimization:**
   - TrueCircle को battery optimization से exclude करें
   - Exclude TrueCircle from battery optimization
   - यह background sync के लिए मदद करेगा
   - This helps with background sync

---

## ✅ Quick Checklist / त्वरित जांच सूची

किसी भी समस्या से पहले यह जांचें:
Before reporting any issue, check this:

- [ ] Internet connection working? / इंटरनेट काम कर रहा है?
- [ ] Latest app version installed? / नवीनतम ऐप संस्करण है?
- [ ] Sufficient storage available? / पर्याप्त स्टोरेज है?
- [ ] Tried restarting the app? / ऐप रीस्टार्ट किया?
- [ ] Checked api.env file? / api.env फ़ाइल जांची?
- [ ] Reviewed this guide? / यह गाइड पढ़ी?

---

## 📞 Emergency Contact / आपातकालीन संपर्क

For urgent issues / तत्काल समस्याओं के लिए:
- GitHub: https://github.com/surendragrover/Truecircle
- Create an issue with tag: `urgent` / `तत्काल`

---

**Remember / याद रखें:**
TrueCircle आपकी गोपनीयता और मानसिक स्वास्थ्य के लिए बनाया गया है।
TrueCircle is built for your privacy and mental wellness.

यदि कोई तकनीकी समस्या है, तो हम मदद के लिए यहां हैं!
If there's a technical issue, we're here to help!

🌟 धन्यवाद / Thank You 🌟
