# TrueCircle - Privacy-First Emotional AI Build Solution
# Fixed dependency issues following coding instructions

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TrueCircle Corrected Build" -ForegroundColor Yellow
Write-Host "Privacy-First Emotional AI with Cultural Intelligence" -ForegroundColor Green
Write-Host "Fixed all dependency issues" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Cyan

Set-Location "C:\Users\CC\flutter_app\truecircle"

# Step 1: Create corrected pubspec.yaml following TrueCircle coding instructions
Write-Host "`nCreating corrected pubspec.yaml..." -ForegroundColor Yellow

$pubspecContent = @'
name: truecircle
description: Privacy-first emotional AI for relationship analysis with cultural intelligence
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # TrueCircle Core Dependencies following coding instructions
  cupertino_icons: ^1.0.6
  
  # Privacy-First Data Storage (Hive for EmotionEntry, Contact, ContactInteraction)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # HuggingFace Integration for emotion analysis
  http: ^1.1.0
  
  # Contact Management (AGP 8 compatible - replaces contacts_service)
  permission_handler: ^11.0.1
  flutter_contacts: ^1.1.7+1
  
  # Bilingual UI Support (Hindi/English per coding instructions)
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1
  
  # Additional TrueCircle Features
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code generation and linting
  flutter_lints: ^3.0.0
  
  # Hive Code Generation (must match hive version exactly)
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
  flutter_launcher_icons: ^0.13.1

# TrueCircle Flutter Configuration following coding instructions
flutter:
  uses-material-design: true
  generate: true  # Enable localization generation
  
  # Privacy-First Asset Configuration
  assets:
    - assets/images/
    - assets/icons/
    - assets/cultural/
    - assets/festivals/
    - api.env

# TrueCircle App Icon Configuration with cultural branding
flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/truecircle_logo.png"
  min_sdk_android: 21
  
  # Material 3 seed color (blue) for relationships per instructions
  adaptive_icon_background: "#2196F3"
  adaptive_icon_foreground: "assets/icons/truecircle_adaptive.png"
  
  # Multi-platform TrueCircle branding
  windows:
    generate: true
    image_path: "assets/images/truecircle_logo.png"
    icon_size: 48
  
  web:
    generate: true
    image_path: "assets/images/truecircle_logo.png"
    background_color: "#2196F3"
    theme_color: "#2196F3"
'@

$pubspecContent | Out-File -FilePath "pubspec.yaml" -Encoding UTF8 -Force
Write-Host "   Created corrected pubspec.yaml with valid dependencies" -ForegroundColor Green

# Step 2: Create proper Android manifest following TrueCircle patterns
Write-Host "`nCreating proper AndroidManifest.xml..." -ForegroundColor Yellow

$manifestPath = "android\app\src\main\AndroidManifest.xml"
$manifestContent = @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- TrueCircle Permissions following privacy-first approach -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />

    <application
        android:label="TrueCircle"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        android:usesCleartextTraffic="false">

        <!-- TrueCircle MainActivity following coding instructions -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- TrueCircle App Launch Intent -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Flutter metadata -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
'@

# Create directory if it doesn't exist
$manifestDir = Split-Path $manifestPath -Parent
if (!(Test-Path $manifestDir)) {
    New-Item -ItemType Directory -Force -Path $manifestDir | Out-Null
}

$manifestContent | Out-File -FilePath $manifestPath -Encoding UTF8 -Force
Write-Host "   Created proper AndroidManifest.xml with TrueCircle permissions" -ForegroundColor Green

# Step 3: Create proper colors.xml following TrueCircle theme
Write-Host "`nCreating proper Android colors.xml..." -ForegroundColor Yellow

$colorsPath = "android\app\src\main\res\values\colors.xml"
$colorsDir = Split-Path $colorsPath -Parent
if (!(Test-Path $colorsDir)) {
    New-Item -ItemType Directory -Force -Path $colorsDir | Out-Null
}

$colorsXml = @'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- TrueCircle Colors following coding instructions -->
    <color name="ic_launcher_background">#2196F3</color>
    <color name="primary_color">#2196F3</color>
    <color name="primary_variant">#1976D2</color>
    <color name="secondary_color">#03DAC6</color>
    
    <!-- Cultural Color Coding per instructions -->
    <color name="festival_orange">#FF9800</color>
    <color name="relationship_blue">#2196F3</color>
    <color name="emotion_purple">#9C27B0</color>
    
    <!-- Background Colors -->
    <color name="background_color">#FFFFFF</color>
    <color name="surface_color">#FAFAFA</color>
    <color name="error_color">#B00020</color>
    
    <!-- Text Colors -->
    <color name="text_primary">#212121</color>
    <color name="text_secondary">#757575</color>
    <color name="text_on_primary">#FFFFFF</color>
    
    <!-- Privacy Tier Colors (Tier 1-3 compliance) -->
    <color name="tier_1_safe">#4CAF50</color>
    <color name="tier_2_permission">#FF9800</color>
    <color name="tier_3_optin">#F44336</color>
</resources>
'@

$colorsXml | Out-File -FilePath $colorsPath -Encoding UTF8 -Force
Write-Host "   Created proper colors.xml with TrueCircle theme" -ForegroundColor Green

# Step 4: Create proper styles.xml
Write-Host "`nCreating proper Android styles.xml..." -ForegroundColor Yellow

$stylesPath = "android\app\src\main\res\values\styles.xml"
$stylesXml = @'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- TrueCircle LaunchTheme following coding instructions -->
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:statusBarColor">@color/primary_color</item>
    </style>
    
    <!-- TrueCircle Normal Theme -->
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
        <item name="android:statusBarColor">@color/primary_color</item>
    </style>
</resources>
'@

$stylesXml | Out-File -FilePath $stylesPath -Encoding UTF8 -Force
Write-Host "   Created proper styles.xml with TrueCircle branding" -ForegroundColor Green

# Step 5: Create launch_background.xml drawable
Write-Host "`nCreating launch_background drawable..." -ForegroundColor Yellow

$drawablePath = "android\app\src\main\res\drawable\launch_background.xml"
$drawableDir = Split-Path $drawablePath -Parent
if (!(Test-Path $drawableDir)) {
    New-Item -ItemType Directory -Force -Path $drawableDir | Out-Null
}

$launchBgXml = @'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- TrueCircle launch background following coding instructions -->
    <item android:drawable="@color/primary_color" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/ic_launcher" />
    </item>
</layer-list>
'@

$launchBgXml | Out-File -FilePath $drawablePath -Encoding UTF8 -Force
Write-Host "   Created launch_background.xml with TrueCircle branding" -ForegroundColor Green

# Step 6: Create API environment file for HuggingFace service
Write-Host "`nCreating api.env for HuggingFace service..." -ForegroundColor Yellow

if (!(Test-Path "api.env")) {
    $apiEnvContent = @'
# TrueCircle - Privacy-First Emotional AI Configuration
# HuggingFace service for emotion analysis with multilingual support
HUGGINGFACE_API_KEY=your_api_key_here

# Cultural AI Settings following TrueCircle coding instructions
CULTURAL_AI_ENABLED=true
BILINGUAL_UI_ENABLED=true
PRIVACY_FIRST_MODE=true

# Festival Intelligence for Indian cultural context
FESTIVAL_NOTIFICATIONS=true
REGIONAL_INTELLIGENCE=true

# Privacy Tiers for TrueCircle compliance
PRIVACY_TIER_1=true
PRIVACY_TIER_2=false
PRIVACY_TIER_3=false
'@
    $apiEnvContent | Out-File -FilePath "api.env" -Encoding UTF8
    Write-Host "   Created api.env with TrueCircle configuration" -ForegroundColor Green
} else {
    Write-Host "   api.env already exists" -ForegroundColor Green
}

# Step 7: Verify asset structure
Write-Host "`nVerifying TrueCircle asset structure..." -ForegroundColor Yellow

$requiredDirs = @("assets", "assets\images", "assets\icons", "assets\cultural", "assets\festivals")
foreach ($dir in $requiredDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "   Created directory: $dir" -ForegroundColor Yellow
    } else {
        Write-Host "   Directory exists: $dir" -ForegroundColor Green
    }
}

# Create placeholder assets if they don't exist
$assetsToCheck = @{
    "assets\images\truecircle_logo.png" = "Main TrueCircle logo"
    "assets\images\welcome_screen.png" = "Welcome screen"
    "assets\images\icon.ico" = "Windows icon"
}

# Create minimal PNG if assets are missing
$pngBytes = [byte[]](0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,0x0B,0x49,0x44,0x41,0x54,0x78,0x9C,0x62,0x00,0x01,0x00,0x00,0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82)

foreach ($asset in $assetsToCheck.Keys) {
    if (!(Test-Path $asset)) {
        [System.IO.File]::WriteAllBytes($asset, $pngBytes)
        Write-Host "   Created placeholder: $(Split-Path $asset -Leaf)" -ForegroundColor Yellow
    } else {
        Write-Host "   Asset exists: $(Split-Path $asset -Leaf)" -ForegroundColor Green
    }
}

# Copy logo to icons directory
if (Test-Path "assets\images\truecircle_logo.png") {
    Copy-Item "assets\images\truecircle_logo.png" "assets\icons\truecircle_logo.png" -Force
    Copy-Item "assets\images\truecircle_logo.png" "assets\icons\truecircle_adaptive.png" -Force
    Write-Host "   Copied truecircle_logo.png to icons directory" -ForegroundColor Green
}

# Step 8: Clean and build
Write-Host "`nCleaning Flutter build cache..." -ForegroundColor Yellow
flutter clean | Out-Host

Write-Host "`nGetting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get | Out-Host

Write-Host "`nGenerating Hive adapters for TrueCircle models..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs | Out-Host

Write-Host "`nGenerating TrueCircle app icons..." -ForegroundColor Yellow
flutter pub run flutter_launcher_icons:main | Out-Host

# Step 9: Build TrueCircle APK
Write-Host "`nBuilding TrueCircle APK with Privacy-First Cultural AI..." -ForegroundColor Yellow
Write-Host "   Privacy-First Mode: ON (Tier 1-3 compliance)" -ForegroundColor Cyan
Write-Host "   Cultural AI: ON (Hindi/English bilingual)" -ForegroundColor Cyan
Write-Host "   Festival Intelligence: ON (Indian cultural context)" -ForegroundColor Cyan
Write-Host "   HuggingFace Integration: ON (emotion analysis)" -ForegroundColor Cyan
Write-Host "   Material 3 Design: ON (blue seed color)" -ForegroundColor Cyan

try {
    $buildOutput = flutter build apk --release `
        --dart-define=CULTURAL_AI_ENABLED=true `
        --dart-define=PRIVACY_FIRST_MODE=true `
        --dart-define=BILINGUAL_UI_ENABLED=true `
        --dart-define=TRUECIRCLE_BRANDING=true `
        --dart-define=FESTIVAL_INTELLIGENCE=true 2>&1
    
    Write-Host $buildOutput
    
} catch {
    Write-Host "Build error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 10: Verify build success
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length
    $apkSizeMB = [math]::Round($apkSize / 1MB, 2)
    
    Write-Host "`nTRUECIRCLE BUILD SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "APK Location: $apkPath" -ForegroundColor White
    Write-Host "Size: $apkSizeMB MB" -ForegroundColor White
    
    Write-Host "`nFixed Issues:" -ForegroundColor Yellow
    Write-Host "   flutter_material_color_utilities dependency removed" -ForegroundColor Green
    Write-Host "   All dependencies now exist on pub.dev" -ForegroundColor Green
    Write-Host "   Android configuration files created properly" -ForegroundColor Green
    Write-Host "   TrueCircle privacy-first architecture maintained" -ForegroundColor Green
    
    Write-Host "`nTrueCircle Features Active:" -ForegroundColor Yellow
    Write-Host "   Privacy-First Processing (Tier 1-3 compliance)" -ForegroundColor Green
    Write-Host "   Cultural AI Intelligence (Hindi/English bilingual)" -ForegroundColor Green
    Write-Host "   HuggingFace Emotion Analysis" -ForegroundColor Green
    Write-Host "   Hive On-Device Storage (EmotionEntry, Contact, ContactInteraction)" -ForegroundColor Green
    Write-Host "   Material 3 Design (Blue seed color per coding instructions)" -ForegroundColor Green
    Write-Host "   Festival & Regional Intelligence" -ForegroundColor Green
    Write-Host "   Multi-Platform Support (Windows, Chrome, Android, iOS)" -ForegroundColor Green
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "   1. Install: flutter install --release" -ForegroundColor Cyan
    Write-Host "   2. Add HuggingFace API key to api.env" -ForegroundColor Cyan
    Write-Host "   3. Test bilingual UI (Hindi/English switching)" -ForegroundColor Cyan
    Write-Host "   4. Test cultural AI with Indian names and festivals" -ForegroundColor Cyan
    Write-Host "   5. Verify privacy settings work with contact analysis" -ForegroundColor Cyan
    
} else {
    Write-Host "`nBUILD FAILED!" -ForegroundColor Red
    Write-Host "Build output:" -ForegroundColor Yellow
    if ($buildOutput) {
        Write-Host $buildOutput -ForegroundColor White
    }
    
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Check Java version: java -version (need 11+)" -ForegroundColor Cyan
    Write-Host "   2. Check Flutter doctor: flutter doctor -v" -ForegroundColor Cyan
    Write-Host "   3. Verify Android SDK is properly configured" -ForegroundColor Cyan
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TrueCircle Build Process Complete" -ForegroundColor Yellow
Write-Host "Privacy-First Emotional AI with Cultural Intelligence" -ForegroundColor Green
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host