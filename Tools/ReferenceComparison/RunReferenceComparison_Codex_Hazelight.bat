@echo off
setlocal
echo [RunReferenceComparison_Codex] Hazelight-Angelscript (all dimensions)
echo.
call "%~dp0RunReferenceComparison_Codex.bat" -Repos hazelight %*
exit /b %ERRORLEVEL%
