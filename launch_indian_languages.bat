@echo off
title TrueCircle Indian Languages Demo
echo.
echo ==========================================
echo    TrueCircle Indian Languages Demo
echo    भारतीय भाषा समर्थन प्रदर्शन
echo ==========================================
echo.
echo Starting Indian Languages Support Demo...
echo Features:
echo - 19+ Indian Languages with Native Scripts
echo - असमिया, बंगाली, पूर्वी पंजाबी, गुजराती supported
echo - कन्नड़, मलयालम, तमिल, तेलुगु included
echo - Translation API Integration Ready
echo - Regional Language Grouping
echo.

cd /d "%~dp0"

echo Launching on Windows Desktop...
flutter run -d windows --dart-define-from-file=api.env lib/main_indian_languages_demo.dart

if %errorlevel% neq 0 (
    echo.
    echo ❌ Error launching on Windows. Trying Chrome...
    echo.
    flutter run -d chrome --dart-define-from-file=api.env lib/main_indian_languages_demo.dart
    
    if %errorlevel% neq 0 (
        echo.
        echo ❌ Error launching on Chrome. Please check:
        echo 1. Run 'flutter pub get' first
        echo 2. Ensure api.env file exists
        echo 3. Check Flutter installation
        echo.
        pause
    )
)