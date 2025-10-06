@echo off
title TrueCircle - Complete Multilingual App
echo.
echo ==========================================
echo    TrueCircle - हर भारतीय भाषा में
echo    Complete Indian Languages Support
echo ==========================================
echo.
echo Starting TrueCircle with full localization...
echo.
echo Features:
echo - Complete app in Hindi, Bengali, Tamil, Telugu
echo - असमिया, गुजराती, कन्नड़, मलयालम, मराठी
echo - पंजाबी, उर्दू, नेपाली, ओडिया support
echo - Real-time language switching
echo - Cultural AI with regional insights
echo - Festival reminders in native languages
echo - Emotion tracking with localized UI
echo.

cd /d "%~dp0"

echo Launching TrueCircle Multilingual App...
flutter run -d windows --dart-define-from-file=api.env lib/main_localized_app.dart

if %errorlevel% neq 0 (
    echo.
    echo ❌ Error launching on Windows. Trying Chrome...
    echo.
    flutter run -d chrome --dart-define-from-file=api.env lib/main_localized_app.dart
    
    if %errorlevel% neq 0 (
        echo.
        echo ❌ Error launching app. Please check:
        echo 1. Run 'flutter pub get' first
        echo 2. Ensure api.env file exists
        echo 3. Check Flutter installation
        echo.
        pause
    )
)