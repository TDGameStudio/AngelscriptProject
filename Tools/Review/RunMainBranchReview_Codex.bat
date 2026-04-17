@echo off
setlocal
chcp 65001 >nul 2>&1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0powershell\RunMainBranchReview_Codex.ps1" %*
exit /b %ERRORLEVEL%
