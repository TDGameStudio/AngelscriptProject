@echo off
setlocal
echo ================================================================
echo  ImprovementPlanner RalphLoop — All Modules Sequential
echo ================================================================
echo.

echo [1/8] RuntimeCore ...
call "%~dp0RunImprovementPlanner_RalphLoop_RuntimeCore.bat" %*
if errorlevel 1 echo   WARNING: RuntimeCore exited with error
echo.

echo [2/8] ClassGenerator ...
call "%~dp0RunImprovementPlanner_RalphLoop_ClassGenerator.bat" %*
if errorlevel 1 echo   WARNING: ClassGenerator exited with error
echo.

echo [3/8] BindSystem ...
call "%~dp0RunImprovementPlanner_RalphLoop_BindSystem.bat" %*
if errorlevel 1 echo   WARNING: BindSystem exited with error
echo.

echo [4/8] Preprocessor ...
call "%~dp0RunImprovementPlanner_RalphLoop_Preprocessor.bat" %*
if errorlevel 1 echo   WARNING: Preprocessor exited with error
echo.

echo [5/8] DebuggingAndJIT ...
call "%~dp0RunImprovementPlanner_RalphLoop_DebuggingAndJIT.bat" %*
if errorlevel 1 echo   WARNING: DebuggingAndJIT exited with error
echo.

echo [6/8] FunctionLibraries ...
call "%~dp0RunImprovementPlanner_RalphLoop_FunctionLibraries.bat" %*
if errorlevel 1 echo   WARNING: FunctionLibraries exited with error
echo.

echo [7/8] Architecture ...
call "%~dp0RunImprovementPlanner_RalphLoop_Architecture.bat" %*
if errorlevel 1 echo   WARNING: Architecture exited with error
echo.

echo [8/8] TestInfrastructure ...
call "%~dp0RunImprovementPlanner_RalphLoop_TestInfrastructure.bat" %*
if errorlevel 1 echo   WARNING: TestInfrastructure exited with error
echo.

echo ================================================================
echo  All modules complete.
echo ================================================================
exit /b 0
