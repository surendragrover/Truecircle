param(
  [string]$ProjectPath = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = 'Stop'

# Resolve pubspec files
$pubspec       = Join-Path $ProjectPath 'pubspec.yaml'
$pubspecClean  = Join-Path $ProjectPath 'pubspec.clean.yaml'
$pubspecBackup = Join-Path $ProjectPath 'pubspec.original.yaml'

if (-not (Test-Path $pubspecClean)) {
  Write-Error "pubspec.clean.yaml not found at $pubspecClean"
}

# Backup original pubspec.yaml once
if (Test-Path $pubspec) {
  if (-not (Test-Path $pubspecBackup)) {
    Copy-Item $pubspec $pubspecBackup -Force
    Write-Host "Backed up original pubspec.yaml -> pubspec.original.yaml" -ForegroundColor Yellow
  } else {
    Write-Host "Backup already exists: pubspec.original.yaml" -ForegroundColor DarkGray
  }
}

# Swap clean pubspec into place
Copy-Item $pubspecClean $pubspec -Force
Write-Host "Applied clean pubspec.yaml" -ForegroundColor Green

# Get packages
Push-Location $ProjectPath
try {
  flutter pub get
  flutter analyze
} finally {
  Pop-Location
}

Write-Host "Done. To restore original: Copy pubspec.original.yaml over pubspec.yaml" -ForegroundColor Cyan
