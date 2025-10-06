# TrueCircle - Windows Test Clean & Run Script
# Purpose: Fix flaky Flutter test runs by cleaning temp artifacts, killing stray processes,
# refreshing dependencies, and running widget/integration tests in a stable environment.
# Usage examples (PowerShell v5.1):
#   ./truecircle_test_clean_run.ps1
#   ./truecircle_test_clean_run.ps1 -TestFile "test/widget_test.dart"
#   ./truecircle_test_clean_run.ps1 -All
#   ./truecircle_test_clean_run.ps1 -BuildRunner -All

param(
  [string]$TestFile = "test/widget_test.dart",
  [switch]$All,
  [switch]$BuildRunner
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Gray }
function Write-Ok($msg) { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERR]  $msg" -ForegroundColor Red }

try {
  Write-Step "Stopping stray Dart/Flutter test processes"
  Get-Process -Name dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Get-Process -Name flutter_tester -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Write-Ok "Processes stopped (if any were running)"

  Write-Step "Cleaning temp test listener directories"
  $tempPaths = @($env:TEMP, "$env:LOCALAPPDATA\Temp") | Where-Object { $_ -and (Test-Path $_) }
  foreach ($tp in $tempPaths) {
    Write-Info "Scanning: $tp"
    Get-ChildItem -Path $tp -Force -ErrorAction SilentlyContinue | Where-Object {
      $_.Name -like "flutter_test_listener*" -or $_.Name -like "flutter_tools.*"
    } | ForEach-Object {
      Write-Info "Deleting: $($_.FullName)"
      Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
  Write-Ok "Temp cleanup complete"

  Write-Step "Switching to repository root"
  Set-Location -Path $PSScriptRoot
  Write-Ok "Current directory: $(Get-Location)"

  Write-Step "Refreshing Flutter build state"
  try {
    flutter --version | Out-Null
  } catch {
    Write-Err "Flutter SDK not found in PATH. Please install or add to PATH."
    throw
  }

  Write-Info "flutter clean"
  flutter clean

  Write-Info "Removing build/.dart_tool (hard cleanup)"
  Remove-Item -Path "build",".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue

  Write-Info "flutter pub get"
  flutter pub get
  Write-Ok "Dependencies resolved"

  if ($BuildRunner) {
    Write-Step "Running build_runner (Hive codegen)"
    flutter packages pub run build_runner build --delete-conflicting-outputs
    Write-Ok "Code generation complete"
  }

  Write-Step "Running tests"
  if ($All) {
    Write-Info "flutter test (all tests)"
    flutter test
  } else {
    Write-Info "flutter test $TestFile"
    flutter test $TestFile
  }

  Write-Ok "Test run finished"
}
catch {
  Write-Err "Script failed: $($_.Exception.Message)"
  Write-Err $_.Exception.StackTrace
  exit 1
}
