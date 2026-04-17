@echo off
setlocal
chcp 65001 >nul 2>&1
set "PS_EXE=powershell"
where pwsh >nul 2>nul
if not errorlevel 1 set "PS_EXE=pwsh"
if "%PS_EXE%"=="powershell" if exist "C:\Program Files\PowerShell\7\pwsh.exe" set "PS_EXE=C:\Program Files\PowerShell\7\pwsh.exe"
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0RunImplementTestCoverage.ps1" -MaxIterations 1000 %*
exit /b %ERRORLEVEL%
