@echo off
setlocal
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "PS_EXE=powershell"
set "OUTPUT_FILE=%~1"

where pwsh >nul 2>nul
if not errorlevel 1 set "PS_EXE=pwsh"
if "%PS_EXE%"=="powershell" if exist "C:\Program Files\PowerShell\7\pwsh.exe" set "PS_EXE=C:\Program Files\PowerShell\7\pwsh.exe"

if "%OUTPUT_FILE%"=="" set "OUTPUT_FILE=1.txt"

echo [run-hello-codex.bat] Starting Codex hello test
echo [run-hello-codex.bat] Shell: %PS_EXE%
echo [run-hello-codex.bat] Output file: %OUTPUT_FILE%

call "%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%hello-codex.ps1" -OutputFile "%OUTPUT_FILE%"
exit /b %ERRORLEVEL%
