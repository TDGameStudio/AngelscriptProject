@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0powershell\Test-AutomationEntryPoints.ps1" %*
exit /b %ERRORLEVEL%
