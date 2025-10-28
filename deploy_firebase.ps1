# 🚀 TrueCircle Firebase Deployment Script (Windows PowerShell)

Write-Host "🎯 Starting TrueCircle Firebase Deployment..." -ForegroundColor Green

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Run code analysis
Write-Host "🔍 Running code analysis..." -ForegroundColor Cyan
flutter analyze

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Code analysis failed!" -ForegroundColor Red
    exit 1
}

# Build APK
Write-Host "📱 Building Release APK..." -ForegroundColor Blue
flutter build apk --release --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK Build Successful!" -ForegroundColor Green
    
    # Get APK info
    $APK_PATH = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $APK_PATH) {
        $APK_SIZE = (Get-Item $APK_PATH).Length / 1MB
        Write-Host "📦 APK Size: $($APK_SIZE.ToString('N2')) MB" -ForegroundColor White
        Write-Host "📍 APK Path: $APK_PATH" -ForegroundColor White
        
        # Deploy to Firebase App Distribution
        Write-Host "🚀 Deploying to Firebase App Distribution..." -ForegroundColor Magenta
        
        # Check if Firebase CLI is installed
        try {
            firebase --version | Out-Null
            Write-Host "✅ Firebase CLI found" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Firebase CLI not found. Please install:" -ForegroundColor Red
            Write-Host "npm install -g firebase-tools" -ForegroundColor Yellow
            Write-Host "firebase login" -ForegroundColor Yellow
            exit 1
        }
        
        # Firebase App Distribution command
        $releaseNotes = @"
🎉 TrueCircle Update: Hindi Coin System + Firebase Integration

✨ New Features:
- Coin reward system with daily login bonuses
- Firebase analytics and crashlytics  
- Marketplace discount system (40% cap)
- Communication tracker integration

🔧 Improvements:
- Fixed all lint issues
- Updated dependencies
- Better error handling
- Performance optimizations

📱 Test the new coin system and provide feedback!
"@
        
        Write-Host "📝 Release Notes:" -ForegroundColor Cyan
        Write-Host $releaseNotes -ForegroundColor Gray
        
        # Note: Replace with your actual Firebase App ID
        firebase appdistribution:distribute $APK_PATH --app "YOUR_FIREBASE_APP_ID" --release-notes $releaseNotes --groups "truecircle-testers"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "🎉 Deployment Successful!" -ForegroundColor Green
            Write-Host "📱 APK uploaded to Firebase App Distribution" -ForegroundColor Green
            Write-Host "👥 Notified testers group" -ForegroundColor Green
        } else {
            Write-Host "❌ Deployment Failed" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ APK file not found at $APK_PATH" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ APK Build Failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ TrueCircle Firebase Deployment Complete!" -ForegroundColor Green