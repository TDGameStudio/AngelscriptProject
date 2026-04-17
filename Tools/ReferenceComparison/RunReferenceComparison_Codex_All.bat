@echo off
setlocal
echo [RunReferenceComparison_Codex] All repos (all dimensions)
echo.
call "%~dp0RunReferenceComparison_Codex.bat" %*
exit /b %ERRORLEVEL%
