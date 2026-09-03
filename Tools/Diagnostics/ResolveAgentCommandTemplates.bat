@echo off
setlocal

where pwsh.exe >nul 2>nul
if errorlevel 1 (
    echo PowerShell 7 ^(pwsh.exe^) is required. 1>&2
    exit /b 1
)

pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0powershell\ResolveAgentCommandTemplates.ps1" %*
exit /b %ERRORLEVEL%
