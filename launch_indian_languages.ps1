# TrueCircle Indian Languages Demo Launcher
# PowerShell script for running Indian Languages feature

param(
    [string]$Platform = "windows"
)

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "   TrueCircle Indian Languages Demo" -ForegroundColor Green
Write-Host "   भारतीय भाषा समर्थन प्रदर्शन" -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🌐 Features:" -ForegroundColor Blue
Write-Host "• 19+ Indian Languages with Native Scripts" -ForegroundColor White
Write-Host "• असमिया, बंगाली, पूर्वी पंजाबी, गुजराती supported" -ForegroundColor White
Write-Host "• कन्नड़, मलयालम, तमिल, तेलुगु included" -ForegroundColor White
Write-Host "• Translation API Integration Ready" -ForegroundColor White
Write-Host "• Regional Language Grouping (North/South/East/West)" -ForegroundColor White
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
Write-Host "🚀 Launching Indian Languages Demo..." -ForegroundColor Green

# Function to launch on specific platform
function Start-Platform {
    param([string]$targetPlatform)
    
    Write-Host "Starting on $targetPlatform..." -ForegroundColor Cyan
    
    $process = Start-Process -FilePath "flutter" -ArgumentList @(
        "run", 
        "-d", $targetPlatform,
        "--dart-define-from-file=api.env",
        "lib/main_indian_languages_demo.dart"
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
    Write-Host "✓ Indian Languages Demo launched successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 Demo Features:" -ForegroundColor Blue
    Write-Host "• Language Selector with Native Scripts" -ForegroundColor White
    Write-Host "• Regional Language Grouping" -ForegroundColor White
    Write-Host "• Popular Languages Quick Access" -ForegroundColor White
    Write-Host "• Translation API Integration" -ForegroundColor White
    Write-Host "• Language Statistics Display" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Failed to launch demo" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure Flutter is properly installed" -ForegroundColor White
    Write-Host "2. Run 'flutter doctor' to check setup" -ForegroundColor White
    Write-Host "3. Verify api.env file has valid API key" -ForegroundColor White
    Write-Host "4. Try running: flutter clean && flutter pub get" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host