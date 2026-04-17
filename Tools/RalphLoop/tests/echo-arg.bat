@echo off
setlocal
set "ARG=%~1"
echo BAT_ARG=%ARG%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0echo-arg.ps1" "%ARG%"
