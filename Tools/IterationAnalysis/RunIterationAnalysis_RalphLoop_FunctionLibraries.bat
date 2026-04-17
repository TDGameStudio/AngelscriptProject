@echo off
setlocal
set "PS_EXE=powershell"
where pwsh >nul 2>nul
if not errorlevel 1 set "PS_EXE=pwsh"
if "%PS_EXE%"=="powershell" if exist "C:\Program Files\PowerShell\7\pwsh.exe" set "PS_EXE=C:\Program Files\PowerShell\7\pwsh.exe"
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0RunIterationAnalysis.ps1" -Module FunctionLibraries %*
exit /b %ERRORLEVEL%
