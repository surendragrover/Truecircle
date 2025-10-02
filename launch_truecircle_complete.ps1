#!/bin/bash
# TrueCircle App Complete Launcher Script
# Cross-platform launcher for all TrueCircle features

Write-Host "🚀 TrueCircle - Complete Functional App Launcher" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

Write-Host "`n🎯 Select TrueCircle Feature to Launch:" -ForegroundColor Yellow
Write-Host "1. 🏠 Main App (Full Features)" -ForegroundColor Green
Write-Host "2. 💰 Loyalty Points Demo" -ForegroundColor Gold  
Write-Host "3. 🎊 Festival Reminder Demo" -ForegroundColor Orange
Write-Host "4. 🌍 Indian Languages Demo" -ForegroundColor Blue
Write-Host "5. 🧘 Simple Working Version" -ForegroundColor Purple
Write-Host "6. 🔧 Run All Tests" -ForegroundColor Gray

$choice = Read-Host "`nEnter your choice (1-6)"

switch ($choice) {
    1 {
        Write-Host "`n🏠 Launching Main TrueCircle App..." -ForegroundColor Green
        flutter run -d chrome
    }
    2 {
        Write-Host "`n💰 Launching Loyalty Points Demo..." -ForegroundColor Gold
        flutter run -d chrome -t lib/main_loyalty_demo.dart
    }
    3 {
        Write-Host "`n🎊 Launching Festival Reminder Demo..." -ForegroundColor Orange
        flutter run -d chrome -t lib/main_festival_simple.dart
    }
    4 {
        Write-Host "`n🌍 Launching Indian Languages Demo..." -ForegroundColor Blue
        flutter run -d chrome -t lib/main_indian_languages_demo.dart
    }
    5 {
        Write-Host "`n🧘 Launching Simple Working Version..." -ForegroundColor Purple
        flutter run -d chrome -t lib/main_simple_working.dart
    }
    6 {
        Write-Host "`n🔧 Running All Functionality Tests..." -ForegroundColor Gray
        .\test_app_functionality.ps1
    }
    default {
        Write-Host "`n❌ Invalid choice. Launching main app..." -ForegroundColor Red
        flutter run -d chrome
    }
}

Write-Host "`n✅ TrueCircle App Launch Complete!" -ForegroundColor Green