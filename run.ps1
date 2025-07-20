# MCP Flutter Chat - PowerShell Runner
Write-Host "Starting MCP Flutter Chat..." -ForegroundColor Green
Write-Host ""

Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
flutter doctor --verbose
Write-Host ""

Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

Write-Host "Choose platform:" -ForegroundColor Cyan
Write-Host "1. Web (Chrome)" -ForegroundColor White
Write-Host "2. Android" -ForegroundColor White
Write-Host "3. iOS (macOS only)" -ForegroundColor White
Write-Host "4. Windows Desktop" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host "Starting Web version..." -ForegroundColor Green
        flutter run -d chrome --web-port 8080
    }
    "2" {
        Write-Host "Starting Android version..." -ForegroundColor Green
        flutter run -d android
    }
    "3" {
        Write-Host "Starting iOS version..." -ForegroundColor Green
        flutter run -d ios
    }
    "4" {
        Write-Host "Starting Windows Desktop version..." -ForegroundColor Green
        flutter run -d windows
    }
    default {
        Write-Host "Invalid choice. Starting Web version by default..." -ForegroundColor Yellow
        flutter run -d chrome --web-port 8080
    }
}

Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
