@echo off
setlocal
chcp 65001 >nul 2>&1
for %%M in (RuntimeCore ClassGenerator BindSystem TestInfrastructure Preprocessor DebuggingAndJIT FunctionLibraries UHTTool) do (
    echo == %%M ==
    call "%~dp0RunIterationAnalysis_RalphLoop_%%M.bat" %*
    if errorlevel 1 echo [WARN] %%M exit=%ERRORLEVEL%
)
