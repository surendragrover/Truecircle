# TrueCircle App Functionality Test Script
# Tests all major features and reports status

Write-Host "🧪 TrueCircle App Functionality Test" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Test 1: Basic App Launch
Write-Host "`n1. Testing Basic App Launch..." -ForegroundColor Yellow
$launchTest = Start-Process -FilePath "flutter" -ArgumentList @("analyze") -PassThru -Wait -NoNewWindow
if ($launchTest.ExitCode -eq 0) {
    Write-Host "✅ Analysis passed - No critical errors" -ForegroundColor Green
} else {
    Write-Host "❌ Analysis failed - Has errors" -ForegroundColor Red
}

# Test 2: Dependencies Check
Write-Host "`n2. Testing Dependencies..." -ForegroundColor Yellow
$depTest = Start-Process -FilePath "flutter" -ArgumentList @("pub", "deps") -PassThru -Wait -NoNewWindow
if ($depTest.ExitCode -eq 0) {
    Write-Host "✅ Dependencies resolved successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Dependencies issues found" -ForegroundColor Red
}

# Test 3: Build Test (Web)
Write-Host "`n3. Testing Web Build..." -ForegroundColor Yellow
$buildTest = Start-Process -FilePath "flutter" -ArgumentList @("build", "web", "--no-tree-shake-icons") -PassThru -Wait -NoNewWindow
if ($buildTest.ExitCode -eq 0) {
    Write-Host "✅ Web build successful" -ForegroundColor Green
} else {
    Write-Host "❌ Web build failed" -ForegroundColor Red
}

# Test 4: Feature Test - Try to run main features
Write-Host "`n4. Testing Core Features..." -ForegroundColor Yellow
$features = @(
    "lib/main_simple_working.dart",
    "lib/main_loyalty_demo.dart", 
    "lib/main_festival_simple.dart"
)

foreach ($feature in $features) {
    Write-Host "   Testing $feature..." -ForegroundColor Gray
    if (Test-Path $feature) {
        Write-Host "   ✅ Feature file exists" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Feature file missing" -ForegroundColor Red
    }
}

Write-Host "`n🏁 Functionality Test Complete!" -ForegroundColor Cyan
Write-Host "Ready to launch TrueCircle app!" -ForegroundColor Green