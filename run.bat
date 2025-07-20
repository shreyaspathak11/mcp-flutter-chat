@echo off
echo Starting MCP Flutter Chat...
echo.

echo Checking Flutter installation...
flutter doctor --verbose
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Choose platform:
echo 1. Web (Chrome)
echo 2. Android
echo 3. iOS (macOS only)
echo 4. Windows Desktop
echo.

set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" (
    echo Starting Web version...
    flutter run -d chrome --web-port 8080
) else if "%choice%"=="2" (
    echo Starting Android version...
    flutter run -d android
) else if "%choice%"=="3" (
    echo Starting iOS version...
    flutter run -d ios
) else if "%choice%"=="4" (
    echo Starting Windows Desktop version...
    flutter run -d windows
) else (
    echo Invalid choice. Starting Web version by default...
    flutter run -d chrome --web-port 8080
)

pause
