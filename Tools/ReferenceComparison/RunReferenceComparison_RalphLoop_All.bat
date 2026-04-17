@echo off
setlocal
echo ================================================================
echo  ReferenceComparison RalphLoop — All Modules Sequential
echo ================================================================
echo.

echo [1/7] Hazelight ...
call "%~dp0RunReferenceComparison_RalphLoop_Hazelight.bat" %*
if errorlevel 1 echo   WARNING: Hazelight exited with error
echo.

echo [2/7] UnrealCSharp ...
call "%~dp0RunReferenceComparison_RalphLoop_UnrealCSharp.bat" %*
if errorlevel 1 echo   WARNING: UnrealCSharp exited with error
echo.

echo [3/7] UnLua ...
call "%~dp0RunReferenceComparison_RalphLoop_UnLua.bat" %*
if errorlevel 1 echo   WARNING: UnLua exited with error
echo.

echo [4/7] puerts ...
call "%~dp0RunReferenceComparison_RalphLoop_puerts.bat" %*
if errorlevel 1 echo   WARNING: puerts exited with error
echo.

echo [5/7] sluaunreal ...
call "%~dp0RunReferenceComparison_RalphLoop_sluaunreal.bat" %*
if errorlevel 1 echo   WARNING: sluaunreal exited with error
echo.

echo [6/7] CrossComparison ...
call "%~dp0RunReferenceComparison_RalphLoop_CrossComparison.bat" %*
if errorlevel 1 echo   WARNING: CrossComparison exited with error
echo.

echo [7/7] GapAnalysis ...
call "%~dp0RunReferenceComparison_RalphLoop_GapAnalysis.bat" %*
if errorlevel 1 echo   WARNING: GapAnalysis exited with error
echo.

echo ================================================================
echo  All modules complete.
echo ================================================================
exit /b 0
