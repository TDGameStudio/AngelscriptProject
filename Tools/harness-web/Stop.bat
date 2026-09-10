@echo off
setlocal
chcp 65001 >nul

where pwsh.exe >nul 2>nul
if errorlevel 1 (
    echo PowerShell 7 ^(pwsh.exe^) is required. 1>&2
    pause
    exit /b 1
)

pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\HarnessWeb.ps1" -Action Stop
set EXITCODE=%ERRORLEVEL%
pause
exit /b %EXITCODE%
