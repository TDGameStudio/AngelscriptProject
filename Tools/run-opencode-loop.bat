@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
echo [run-opencode-loop.bat] Provider: opencode
call "%SCRIPT_DIR%run-ralph-loop.bat" %* -Agent opencode
exit /b %ERRORLEVEL%
