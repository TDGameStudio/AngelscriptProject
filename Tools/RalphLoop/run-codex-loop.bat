@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
echo [run-codex-loop.bat] Provider: codex
call "%SCRIPT_DIR%run-ralph-loop.bat" %* -Agent codex
exit /b %ERRORLEVEL%
