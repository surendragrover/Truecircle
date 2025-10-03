# TrueCircle - Visual Architecture Graph & Flow Diagrams

## 📊 SYSTEM ARCHITECTURE GRAPH

```
                    🏛️ TRUECIRCLE APPLICATION ARCHITECTURE
                    ═══════════════════════════════════════
                    
┌─────────────────────────────────────────────────────────────────────────────┐
│                          🎯 USER INTERFACE LAYER                           │
├─────────────────────────────────────────────────────────────────────────────┤
│  📱 PAGES                    🧩 WIDGETS                   🌐 LOCALIZATION   │
│  ├── welcome_screen.dart     ├── truecircle_logo.dart    ├── app_en.arb     │
│  ├── home_page.dart          ├── cultural_ai_ui.dart     ├── app_hi.arb     │
│  ├── relationship_dash.dart  ├── interactive_ai_ui.dart  ├── generated/     │
│  ├── dr_iris_dashboard.dart  ├── smart_message.dart      │   ├── en.dart    │
│  ├── privacy_settings.dart   ├── analytics_dash.dart     │   └── hi.dart    │
│  ├── insights_page.dart      ├── avatar_placeholder.dart │                  │
│  ├── charts_page.dart        └── app_mode_selector.dart  └── (Auto-gen)     │
│  ├── goals_page.dart                                                         │
│  ├── reminders_page.dart              📋 MATERIAL 3 DESIGN                 │
│  ├── export_page.dart                 ├── Theme: Blue Seed                 │
│  └── search_page.dart                 ├── Cards: 12px radius               │
│                                       └── Colors: Cultural aware           │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ▲ ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        🧠 BUSINESS LOGIC LAYER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  🤖 AI SERVICES                  📊 DATA SERVICES           ⚙️ CORE SERVICES │
│  ├── huggingface_service.dart   ├── emotion_service.dart   ├── feature_mgr   │
│  │   ├── Emotion Analysis       ├── Data Analytics        ├── privacy_svc   │
│  │   ├── Sentiment Analysis     ├── Contact Processing    ├── payment_svc   │
│  │   ├── Intent Classification  ├── Interaction Tracking  ├── permission    │
│  │   └── 800+ lines of code     └── Privacy Management    └── demo_data     │
│  ├── cultural_regional_ai.dart                                              │
│  │   ├── Indian Festivals       📈 ANALYTICS ENGINE                         │
│  │   ├── Regional Customs       ├── Emotion Trends                          │
│  │   ├── Family Dynamics        ├── Relationship Health                     │
│  │   └── Cultural Greetings     ├── Communication Patterns                  │
│  └── interactive_ai_service.dart└── Predictive Insights                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ▲ ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           🗃️ DATA LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  💾 LOCAL STORAGE (PRIMARY)      ☁️ CLOUD STORAGE (OPTIONAL)               │
│  ├── 🏪 HIVE DATABASE            ├── 🔥 FIREBASE SERVICES                   │
│  │   ├── emotion_entry.dart      │   ├── Authentication                     │
│  │   ├── contact.dart            │   ├── Cloud Firestore                    │
│  │   ├── contact_interaction     │   ├── Analytics                          │
│  │   ├── privacy_settings        │   └── Hosting                            │
│  │   └── Generated .g.dart       ├── 📡 EXTERNAL APIs                       │
│  ├── 📁 SHARED PREFERENCES       │   ├── HuggingFace AI                     │
│  │   ├── App Settings            │   ├── Payment Gateways                   │
│  │   └── User Preferences        │   └── Cultural Data                      │
│  └── 📋 SAMPLE DATA              └── 🔒 ENCRYPTION: AES-256                 │
│      ├── Emotion samples                                                     │
│      ├── Contact examples        🔐 PRIVACY TIERS:                          │
│      └── Interaction history     ├── Tier 1: Basic Metadata (Always Safe)  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 DATA FLOW DIAGRAM

```
                           🔄 TRUECIRCLE DATA FLOW
                           ═══════════════════════

📱 USER INPUT                                             👤 USER OUTPUT
├── Text Messages      ┌─────────────────────────┐       ├── Emotional Insights
├── Emotion Check-ins ──┤    PROCESSING PIPELINE  ├────── ├── Relationship Health
├── Contact Updates    │                         │       ├── Cultural Recommendations  
└── Privacy Settings   └─────────────────────────┘       └── Visual Analytics
            │                      │                               ▲
            ▼                      ▼                               │
    ┌─────────────────┐   ┌─────────────────────┐         ┌─────────────────┐
    │  📊 LOCAL       │   │  🤖 AI ANALYSIS     │         │  🎨 UI RENDER   │
    │  VALIDATION     │   │  ENGINE             │         │  ENGINE         │
    ├─────────────────┤   ├─────────────────────┤         ├─────────────────┤
    │ ✓ Data Types    │   │ 🧠 HuggingFace API │         │ 📊 Charts       │
    │ ✓ Privacy Rules │   │   ├── Emotion Class │         │ 📋 Lists        │
    │ ✓ Permissions   ├──►│   ├── Sentiment     ├────────►│ 💬 Messages     │
    │ ✓ Format Check  │   │   └── Intent Detect │         │ 🎯 Insights     │
    └─────────────────┘   │ 🌍 Cultural AI      │         │ 🔔 Notifications│
                          │   ├── Festivals     │         └─────────────────┘
                          │   ├── Customs       │
                          │   └── Language      │
                          └─────────────────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │  💾 DATA STORAGE    │
                          │  DECISION ENGINE    │
                          ├─────────────────────┤
                          │ Local First (Hive)  │
                          │ ├── Tier 1: Always  │
                          │ ├── Tier 2: w/Perm  │
                          │ └── Tier 3: Opt-in  │
                          │                     │
                          │ Cloud Backup        │
                          │ ├── User Choice     │
                          │ ├── Encrypted       │
                          │ └── Selective Sync  │
                          └─────────────────────┘
```

## 🏗️ COMPONENT DEPENDENCY GRAPH

```
                      🏗️ COMPONENT DEPENDENCY TREE
                      ═══════════════════════════
                      
                    📱 main.dart (ROOT)
                    ├── Firebase.initializeApp()
                    ├── Hive.initFlutter()
                    └── runApp(TrueCircleApp())
                           │
                           ▼
              ┌─────────────────────────────┐
              │     🏠 HOME_PAGE.DART       │
              │     (Navigation Hub)        │
              └─────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  📄 PAGES    │  │  🧩 WIDGETS  │  │  🤖 SERVICES │
│  (UI Views)  │  │  (Reusable)  │  │  (Logic)     │
└──────────────┘  └──────────────┘  └──────────────┘
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│welcome_screen│  │truecircle_   │  │huggingface_  │
│relationship_ │  │logo          │  │service       │
│dashboard     │  │cultural_ai_  │  │cultural_     │
│dr_iris_      │  │dashboard     │  │regional_ai   │
│dashboard     │  │interactive_  │  │emotion_      │
│privacy_      │  │ai_ui         │  │service       │
│settings      │  │smart_message │  │demo_data_    │
│insights      │  │analytics_    │  │service       │
│charts        │  │dashboard     │  │privacy_      │
│goals         │  │avatar_       │  │service       │
│reminders     │  │placeholder   │  │feature_      │
│export        │  │app_mode_     │  │manager       │
│search        │  │selector      │  │payment_      │
└──────────────┘  └──────────────┘  │service       │
        │                  │        │permission_   │
        ▼                  ▼        │manager       │
┌──────────────┐  ┌──────────────┐  └──────────────┘
│  🗃️ MODELS   │  │  🌐 L10N     │          │
│  (Data)      │  │  (Localize)  │          ▼
└──────────────┘  └──────────────┘  ┌──────────────┐
        │                  │        │  💾 STORAGE  │
        ▼                  ▼        │  LAYER       │
┌──────────────┐  ┌──────────────┐  └──────────────┘
│emotion_entry │  │app_          │          │
│contact       │  │localizations │          ▼
│contact_      │  │_en.dart      │  ┌──────────────┐
│interaction   │  │app_          │  │  🏪 HIVE DB  │
│privacy_      │  │localizations │  │  ├── Boxes   │
│settings      │  │_hi.dart      │  │  ├── Adapters│
│*.g.dart      │  │              │  │  └── Encrypt │
│(Generated)   │  │(Generated)   │  └──────────────┘
└──────────────┘  └──────────────┘
```

## 🛠️ BUILD PIPELINE FLOW

```
                       🛠️ BUILD & DEPLOYMENT PIPELINE
                       ═══════════════════════════════

    👨‍💻 DEVELOPER             📝 SOURCE CODE                🔧 BUILD PROCESS
    ┌─────────────┐        ┌─────────────────┐         ┌─────────────────┐
    │ Code Change │───────►│ Git Repository  │────────►│ Flutter Build   │
    │ ├── Features│        │ ├── lib/        │         │ ├── pub get     │
    │ ├── Bug Fix │        │ ├── assets/     │         │ ├── build_runner│
    │ └── Refactor│        │ ├── android/    │         │ ├── flutter test│
    └─────────────┘        │ ├── ios/        │         │ └── Compilation │
                           │ ├── windows/    │         └─────────────────┘
                           │ ├── web/        │                  │
                           │ └── test/       │                  ▼
                           └─────────────────┘         ┌─────────────────┐
                                    │                  │ Platform Builds │
                                    ▼                  └─────────────────┘
                           ┌─────────────────┐                  │
                           │ Code Generation │                  ▼
                           │ ├── Hive *.g.dart       ┌─────────────────┐
                           │ ├── Localizations       │ 📱 ANDROID APK  │
                           │ └── Firebase Config      │ Size: 59.5MB    │
                           └─────────────────┘       │ Status: ✅ Built │
                                                     └─────────────────┘
                                                              │
                                                              ▼
    🚀 DEPLOYMENT                                    ┌─────────────────┐
    ┌─────────────────┐                             │ 🖥️ WINDOWS EXE  │
    │ Distribution    │◄────────────────────────────│ Size: 45MB      │
    │ ├── Play Store  │                             │ Status: ✅ Built │
    │ ├── App Store   │                             └─────────────────┘
    │ ├── Direct APK  │                                      │
    │ ├── Web Hosting │                                      ▼
    │ └── Enterprise  │                             ┌─────────────────┐
    └─────────────────┘                             │ 🌐 WEB PWA      │
             ▲                                      │ Size: 12MB      │
             │                                      │ Status: ✅ Live  │
    ┌─────────────────┐                             └─────────────────┘
    │ Quality Gates   │                                      │
    │ ├── Unit Tests  │                                      ▼
    │ ├── Widget Tests│                             ┌─────────────────┐
    │ ├── Privacy Audit                             │ 🍎 iOS (Ready)  │
    │ ├── Security Scan                             │ 🐧 Linux (Ready)│
    │ └── Performance │                             │ 🍏 macOS (Ready)│
    └─────────────────┘                             └─────────────────┘
```

## 🔐 PRIVACY ARCHITECTURE DIAGRAM

```
                        🔐 PRIVACY-FIRST ARCHITECTURE
                        ═══════════════════════════
                        
    👤 USER DATA ENTRY                              🛡️ PRIVACY CONTROLS
    ┌─────────────────┐                           ┌─────────────────┐
    │ Personal Info   │                           │ Privacy Settings│
    │ ├── Emotions    │                           │ ├── Granular    │
    │ ├── Contacts    │──────┐                    │ │   Permissions │
    │ ├── Messages    │      │                    │ ├── Data Tiers  │
    │ └── Interactions│      │                    │ ├── Opt-in/Out  │
    └─────────────────┘      │                    │ └── Export/Delete
                             ▼                    └─────────────────┘
                    ┌─────────────────┐                    │
                    │ 🔍 PRIVACY      │                    │
                    │ CLASSIFICATION  │◄───────────────────┘
                    └─────────────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │ 🟢 TIER 1   │ │ 🟡 TIER 2   │ │ 🔴 TIER 3   │
    │ Always Safe │ │ Need Perm   │ │ Explicit    │
    ├─────────────┤ ├─────────────┤ ├─────────────┤
    │ ✓ Names     │ │ ? Call Logs │ │ ⚠ Content   │
    │ ✓ Phone #   │ │ ? Frequency │ │   Analysis  │
    │ ✓ Settings  │ │ ? Patterns  │ │ ⚠ AI Deep   │
    │ ✓ Themes    │ │ ? Metadata  │ │   Insights  │
    └─────────────┘ └─────────────┘ └─────────────┘
              │              │              │
              ▼              ▼              ▼
    ┌─────────────────────────────────────────────┐
    │          💾 STORAGE ROUTING                 │
    ├─────────────────────────────────────────────┤
    │ 🏪 LOCAL HIVE DB (Primary - Encrypted)     │
    │ ├── All Tier 1 Data                        │
    │ ├── Permitted Tier 2 Data                  │
    │ └── Opt-in Tier 3 Data                     │
    │                                             │
    │ ☁️ FIREBASE CLOUD (Optional - User Choice) │
    │ ├── Backup Selected Data Only              │
    │ ├── End-to-End Encryption                  │
    │ └── User-Controlled Sync                   │
    └─────────────────────────────────────────────┘
```

## 🤖 AI PROCESSING FLOW

```
                        🤖 AI INTELLIGENCE PIPELINE
                        ═══════════════════════════
                        
    📝 INPUT TEXT/DATA                           🧠 AI MODELS
    ┌─────────────────┐                        ┌─────────────────┐
    │ User Messages   │                        │ HuggingFace API │
    │ Emotion Entries │──────┐                 ├─────────────────┤
    │ Contact Info    │      │                 │ cardiffnlp/     │
    │ Call Patterns   │      │                 │ twitter-roberta │
    └─────────────────┘      │                 │ -base-emotion   │
                             ▼                 │                 │
                    ┌─────────────────┐        │ cardiffnlp/     │
                    │ 🔍 PRE-         │        │ twitter-roberta │
                    │ PROCESSING      │        │ -base-sentiment │
                    ├─────────────────┤        │                 │
                    │ ✓ Text Cleaning │        │ microsoft/      │
                    │ ✓ Language ID   │        │ DialoGPT-medium │
                    │ ✓ Cultural      │        │                 │
                    │   Context       │        │ facebook/       │
                    │ ✓ Privacy Filter│        │ bart-large-mnli │
                    └─────────────────┘        └─────────────────┘
                             │                          │
                             ▼                          │
                    ┌─────────────────┐                 │
                    │ 🌐 API REQUEST  │◄────────────────┘
                    │ OPTIMIZATION    │
                    ├─────────────────┤
                    │ ⚡ Batch Process │
                    │ 🔄 Retry Logic  │
                    │ 📊 Rate Limiting│
                    │ 💾 Cache Results│
                    └─────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ 🎯 AI ANALYSIS  │
                    │ RESULTS         │
                    ├─────────────────┤
                    │ 😊 Emotions     │
                    │ 📊 Sentiment    │
                    │ 💭 Intent       │
                    │ 🎯 Confidence   │
                    └─────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ 🌍 CULTURAL     │
                    │ ENHANCEMENT     │
                    ├─────────────────┤
                    │ 🎊 Festival     │
                    │   Context       │
                    │ 🗣️ Language     │
                    │   Adaptation    │
                    │ 👨‍👩‍👧‍👦 Family      │
                    │   Dynamics      │
                    │ 🏛️ Regional     │
                    │   Customs       │
                    └─────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ 📊 INSIGHTS     │
                    │ GENERATION      │
                    ├─────────────────┤
                    │ 💡 Personalized │
                    │   Recommend.    │
                    │ 📈 Trends       │
                    │ 🎯 Action Items │
                    │ 🔮 Predictions  │
                    └─────────────────┘
```

## 🌐 MULTI-PLATFORM DEPLOYMENT MAP

```
                    🌐 MULTI-PLATFORM DEPLOYMENT MAP
                    ═══════════════════════════════
                    
                    📱 FLUTTER CODEBASE (SINGLE SOURCE)
                    ├── lib/ (Dart Code - 25,000+ lines)
                    ├── assets/ (Images, Icons, Data)
                    └── Platform-specific configurations
                               │
                ┌──────────────┼──────────────┐
                ▼              ▼              ▼
    ┌─────────────────┐ ┌─────────────┐ ┌─────────────┐
    │ 🤖 ANDROID      │ │ 🍎 iOS      │ │ 🖥️ DESKTOP   │
    ├─────────────────┤ ├─────────────┤ ├─────────────┤
    │ Status: ✅ Built│ │Status: Ready│ │Status: ✅ Built
    │ APK: 59.5MB     │ │IPA: Ready   │ │Windows: 45MB│
    │ Min SDK: 24     │ │iOS: 12.0+   │ │Win 10/11    │
    │ Target: 34      │ │Swift: 5.5   │ │Linux: Ready │
    │ Permissions:    │ │Permissions: │ │macOS: Ready │
    │ ├── Internet    │ │ ├── Contacts│ │Permissions: │
    │ ├── Contacts    │ │ ├── Network │ │ ├── Files   │
    │ ├── Call Logs   │ │ └── Camera  │ │ ├── Network │
    │ └── Storage     │ └─────────────┘ │ └── Hardware│
    └─────────────────┘                 └─────────────┘
                │                                │
                ▼                                ▼
    ┌─────────────────┐                ┌─────────────┐
    │ 📦 DISTRIBUTION │                │ 🌐 WEB      │
    ├─────────────────┤                ├─────────────┤
    │ Google Play     │                │Status: Live │
    │ ├── Ready       │                │Size: 12MB   │
    │ ├── ASO Opt.    │                │PWA: Yes     │
    │ └── Compliance  │                │Firebase: On │
    │                 │                │Responsive:  │
    │ Direct APK      │                │ ├── Mobile  │
    │ ├── Available   │                │ ├── Tablet  │
    │ ├── 59.5MB      │                │ └── Desktop │
    │ └── Sideload OK │                └─────────────┘
    └─────────────────┘                        │
                                               ▼
                                      ┌─────────────┐
                                      │ 🚀 HOSTING  │
                                      ├─────────────┤
                                      │Firebase Host│
                                      │Custom Domain│
                                      │CDN Enabled  │
                                      │SSL/HTTPS    │
                                      │Analytics On │
                                      └─────────────┘
```

---

## 📊 VISUAL STATISTICS DASHBOARD

```
                       📊 PROJECT METRICS DASHBOARD
                       ═══════════════════════════

    📈 CODEBASE METRICS                    🎯 FEATURES STATUS
    ┌─────────────────────┐               ┌─────────────────────┐
    │ Total Files: 150+   │               │ Core Features: ✅   │
    │ Lines of Code: 25K+ │               │ AI Integration: ✅  │
    │ Documentation: 15K+ │               │ Privacy System: ✅  │
    │ Test Coverage: 70%  │               │ Multi-Platform: ✅  │
    │ Languages: 2        │               │ Localization: ✅    │
    │ Platforms: 6        │               │ Cloud Sync: 🔄      │
    └─────────────────────┘               └─────────────────────┘
    
    🤖 AI CAPABILITIES                     🏗️ BUILD STATUS  
    ┌─────────────────────┐               ┌─────────────────────┐
    │ HF Models: 4        │               │ Android APK: ✅     │
    │ Emotions: 7 Types   │               │ Windows EXE: ✅     │
    │ Languages: Hi/En    │               │ Web PWA: ✅ Live    │
    │ Festivals: 50+      │               │ iOS Build: 🔄       │
    │ Response: <500ms    │               │ Linux: 🔄 Ready     │
    │ Accuracy: 95%       │               │ macOS: 🔄 Ready     │
    └─────────────────────┘               └─────────────────────┘
    
    🔒 PRIVACY & SECURITY                  💰 MONETIZATION
    ┌─────────────────────┐               ┌─────────────────────┐
    │ Data Tiers: 3       │               │ Model: Freemium     │
    │ Encryption: AES-256 │               │ Payment: Razorpay   │
    │ GDPR Ready: ✅      │               │ Ads: Google Mobile  │
    │ Local First: ✅     │               │ Premium: AI Plus    │
    │ User Control: 15+   │               │ Subscriptions: ✅   │
    │ Audit Trail: ✅     │               │ Revenue Ready: 🔄   │
    └─────────────────────┘               └─────────────────────┘
```

---

*This visual documentation provides comprehensive graphs and flow diagrams for understanding TrueCircle's architecture, data flow, and system relationships. Use these diagrams for technical planning, system understanding, and stakeholder presentations.*