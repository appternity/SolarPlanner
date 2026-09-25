@echo off
title SolarPlanner - Install Trust Certificate
echo.
echo ============================================
echo  SolarPlanner - One-time trust setup
echo ============================================
echo.

:: Check if running as admin (required to install into LocalMachine\Root)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please right-click this file and choose "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: Import the certificate into Trusted Root Certification Authorities
certutil -addstore "Root" "%~dp0solarplanner-trust.cer"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install certificate. Check that solarplanner-trust.cer exists in this folder.
    pause
    exit /b 1
)

echo.
echo [OK] Certificate installed successfully!
echo      SolarPlanner will now run without SmartScreen warnings.
echo.
pause
