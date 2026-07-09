@echo off
chcp 65001 >nul
echo Starting HTTP server for web build...
echo Open http://localhost:8000 in your browser.
echo Press Ctrl+C to stop.
echo.
python -m http.server 8000 -d "%~dp0bin\web"
if errorlevel 1 (
    echo Python not found. Try:
    echo   npx http-server "%~dp0bin\web"
)
pause
