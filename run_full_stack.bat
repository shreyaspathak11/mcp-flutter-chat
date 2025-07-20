@echo off
echo Starting MCP Flutter Chat App...
echo.
echo 1. Starting Flask MCP Server...
start /B cmd /c "cd ..\mcp-chat-app && python app.py"
timeout /t 3 /nobreak > nul
echo.
echo 2. Starting Flutter Web App...
flutter run -d chrome
pause
