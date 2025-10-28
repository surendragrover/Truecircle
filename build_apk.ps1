# TrueCircle APK Builder Script
# Quick build script for mass market devices

Write-Host "🚀 TrueCircle APK Builder Starting..." -ForegroundColor Green

# Clean previous build
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow

# Kill any dart processes that might be locking the build folder
Stop-Process -Name "dart" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "flutter" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Try to remove build folder multiple times if needed
$attempts = 0
while ((Test-Path "build") -and ($attempts -lt 5)) {
    $attempts++
    Write-Host "   Attempt $attempts to clean build folder..." -ForegroundColor Gray
    try {
        Remove-Item -Path "build" -Recurse -Force -ErrorAction Stop
        Write-Host "   ✅ Build folder cleaned" -ForegroundColor Green
        break
    } catch {
        Write-Host "   ⚠️ Build folder in use, waiting..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

if (Test-Path "build") {
    Write-Host "   ⚠️ Could not remove build folder completely, continuing anyway..." -ForegroundColor Yellow
}

# Flutter clean
Write-Host "🔄 Flutter clean..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Analyze code
Write-Host "🔍 Analyzing code..." -ForegroundColor Yellow
flutter analyze

# Build APK for mass market (multiple architectures)
Write-Host "🏗️ Building APK for mass market devices..." -ForegroundColor Green
Write-Host "📱 Targeting: armeabi-v7a, arm64-v8a, x86, x86_64" -ForegroundColor Cyan

flutter build apk --release --target-platform android-arm,android-arm64,android-x64 --split-per-abi

# Check if build was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK Build Successful!" -ForegroundColor Green
    Write-Host "📍 APK Location: build\app\outputs\flutter-apk\" -ForegroundColor Cyan
    
    # List generated APKs
    Write-Host "📱 Generated APKs:" -ForegroundColor Yellow
    Get-ChildItem -Path "build\app\outputs\flutter-apk\*.apk" | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "   • $($_.Name) - ${size}MB" -ForegroundColor White
    }
    
    # Open folder
    Write-Host "📂 Opening APK folder..." -ForegroundColor Cyan
    Start-Process "build\app\outputs\flutter-apk"
    
} else {
    Write-Host "❌ APK Build Failed!" -ForegroundColor Red
    Write-Host "Check the errors above and fix them." -ForegroundColor Yellow
}

Write-Host "🏁 Build process completed." -ForegroundColor Green