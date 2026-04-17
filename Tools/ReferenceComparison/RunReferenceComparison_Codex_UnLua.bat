@echo off
setlocal
echo [RunReferenceComparison_Codex] UnLua (all dimensions)
echo.
call "%~dp0RunReferenceComparison_Codex.bat" -Repos unlua %*
exit /b %ERRORLEVEL%
