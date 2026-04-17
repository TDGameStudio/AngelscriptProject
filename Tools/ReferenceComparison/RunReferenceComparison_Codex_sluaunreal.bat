@echo off
setlocal
echo [RunReferenceComparison_Codex] sluaunreal (all dimensions)
echo.
call "%~dp0RunReferenceComparison_Codex.bat" -Repos sluaunreal %*
exit /b %ERRORLEVEL%
