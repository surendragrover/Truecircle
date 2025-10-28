#!/bin/bash

# 🚀 TrueCircle Firebase Deployment Script

echo "🎯 Starting TrueCircle Firebase Deployment..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Run code analysis
echo "🔍 Running code analysis..."
flutter analyze

# Build APK
echo "📱 Building Release APK..."
flutter build apk --release --verbose

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ APK Build Successful!"
    
    # Get APK info
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    
    echo "📦 APK Size: $APK_SIZE"
    echo "📍 APK Path: $APK_PATH"
    
    # Deploy to Firebase App Distribution
    echo "🚀 Deploying to Firebase App Distribution..."
    
    # Note: You need to install Firebase CLI and login first:
    # npm install -g firebase-tools
    # firebase login
    # firebase projects:list
    
    firebase appdistribution:distribute "$APK_PATH" \
        --app "1:234567890:android:abcdef123456789012345" \
        --release-notes "🎉 TrueCircle Update: Hindi Coin System + Firebase Integration
        
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
        
        📱 Test the new coin system and provide feedback!" \
        --groups "truecircle-testers"
        
    if [ $? -eq 0 ]; then
        echo "🎉 Deployment Successful!"
        echo "📱 APK uploaded to Firebase App Distribution"
        echo "👥 Notified testers group"
    else
        echo "❌ Deployment Failed"
        exit 1
    fi
    
else
    echo "❌ APK Build Failed"
    exit 1
fi

echo "✅ TrueCircle Firebase Deployment Complete!"