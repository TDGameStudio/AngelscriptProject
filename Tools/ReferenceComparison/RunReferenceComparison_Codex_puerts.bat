@echo off
setlocal
echo [RunReferenceComparison_Codex] puerts (all dimensions)
echo.
call "%~dp0RunReferenceComparison_Codex.bat" -Repos puerts %*
exit /b %ERRORLEVEL%
