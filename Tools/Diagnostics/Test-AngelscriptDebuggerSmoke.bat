@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0powershell\Test-AngelscriptDebuggerSmoke.ps1" %*
exit /b %ERRORLEVEL%
