# TrueCircle Complete Multilingual App Launcher
# PowerShell script for running full localized TrueCircle

param(
    [string]$Platform = "windows"
)

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "   TrueCircle - हर भारतीय भाषा में" -ForegroundColor Green
Write-Host "   Complete Indian Languages Support" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🌐 Complete Multilingual Features:" -ForegroundColor Blue
Write-Host "• Full app in Hindi (हिन्दी)" -ForegroundColor White
Write-Host "• Bengali (বাংলা), Tamil (தமிழ்), Telugu (తెలుగు)" -ForegroundColor White
Write-Host "• Gujarati (ગુજરાતી), Kannada (ಕನ್ನಡ), Malayalam (മലയാളം)" -ForegroundColor White
Write-Host "• Marathi (मराठी), Punjabi (ਪੰਜਾਬੀ), Urdu (اردو)" -ForegroundColor White
Write-Host "• Assamese (অসমীয়া), Nepali (नेपाली), Odia (ଓଡ଼ିଆ)" -ForegroundColor White
Write-Host "• Real-time language switching throughout app" -ForegroundColor Green
Write-Host "• Cultural AI with regional insights" -ForegroundColor Green
Write-Host "• Festival reminders in native languages" -ForegroundColor Green
Write-Host "• Emotion tracking with localized UI" -ForegroundColor Green
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version | Select-String "Flutter" | Out-String
    Write-Host "✓ Flutter detected: " -ForegroundColor Green -NoNewline
    Write-Host "$($flutterVersion.Trim())" -ForegroundColor Gray
} catch {
    Write-Host "❌ Flutter not found in PATH!" -ForegroundColor Red
    Write-Host "Please install Flutter and add to PATH" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Change to script directory
Set-Location $PSScriptRoot

# Check for api.env file
if (-not (Test-Path "api.env")) {
    Write-Host "⚠️ api.env file not found. Creating sample..." -ForegroundColor Yellow
    @"
# TrueCircle API Configuration
GOOGLE_TRANSLATE_API_KEY=your_api_key_here
"@ | Out-File -FilePath "api.env" -Encoding UTF8
    Write-Host "✓ Created sample api.env file" -ForegroundColor Green
}

# Get dependencies
Write-Host "📦 Updating dependencies..." -ForegroundColor Blue
flutter pub get | Out-Host

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencies updated successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to update dependencies" -ForegroundColor Red
}

Write-Host ""
Write-Host "🚀 Launching TrueCircle Multilingual App..." -ForegroundColor Green

# Function to launch on specific platform
function Start-Platform {
    param([string]$targetPlatform)
    
    Write-Host "Starting on $targetPlatform..." -ForegroundColor Cyan
    
    $process = Start-Process -FilePath "flutter" -ArgumentList @(
        "run", 
        "-d", $targetPlatform,
        "--dart-define-from-file=api.env",
        "lib/main_localized_app.dart"
    ) -NoNewWindow -Wait -PassThru
    
    return $process.ExitCode
}

# Try launching on specified platform first
$exitCode = Start-Platform -targetPlatform $Platform

# If Windows fails, try Chrome
if ($exitCode -ne 0 -and $Platform -eq "windows") {
    Write-Host ""
    Write-Host "❌ Windows launch failed. Trying Chrome..." -ForegroundColor Yellow
    $exitCode = Start-Platform -targetPlatform "chrome"
}

# Final status
if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "✓ TrueCircle Multilingual App launched successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 App Features Available:" -ForegroundColor Blue
    Write-Host "• Complete UI in your preferred Indian language" -ForegroundColor White
    Write-Host "• Language selector in app bar for quick switching" -ForegroundColor White
    Write-Host "• Localized emotion logging and tracking" -ForegroundColor White
    Write-Host "• Festival reminders with native language wishes" -ForegroundColor White
    Write-Host "• Cultural AI insights in regional context" -ForegroundColor White
    Write-Host "• Settings page with complete language management" -ForegroundColor White
    Write-Host "• Translation demo with real-time conversion" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Quick Start:" -ForegroundColor Cyan
    Write-Host "1. Use language selector in top-right to switch languages" -ForegroundColor White
    Write-Host "2. All text will update to selected language immediately" -ForegroundColor White
    Write-Host "3. Visit Settings > Languages for advanced options" -ForegroundColor White
    Write-Host "4. Test translation features in the demo section" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Failed to launch multilingual app" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure Flutter is properly installed" -ForegroundColor White
    Write-Host "2. Run 'flutter doctor' to check setup" -ForegroundColor White
    Write-Host "3. Try: flutter clean && flutter pub get" -ForegroundColor White
    Write-Host "4. Check if api.env file has valid configuration" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host