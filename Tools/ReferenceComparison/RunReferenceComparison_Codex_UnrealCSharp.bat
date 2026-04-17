@echo off
setlocal
echo [RunReferenceComparison_Codex] UnrealCSharp (all dimensions)
echo.
call "%~dp0RunReferenceComparison_Codex.bat" -Repos unrealcsharp %*
exit /b %ERRORLEVEL%
