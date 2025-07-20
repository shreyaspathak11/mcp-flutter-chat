# MCP Flutter Chat - Full Stack Launcher
Write-Host "Starting MCP Flutter Chat App..." -ForegroundColor Green
Write-Host ""

Write-Host "1. Starting Flask MCP Server..." -ForegroundColor Yellow
Start-Process -FilePath "python" -ArgumentList "app.py" -WorkingDirectory "..\mcp-chat-app" -WindowStyle Hidden

Write-Host "   Waiting for server to start..."
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "2. Starting Flutter Web App..." -ForegroundColor Yellow
flutter run -d chrome

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
