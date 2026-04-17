@echo off
setlocal
chcp 65001 >nul 2>&1
for %%M in (RuntimeCore ClassGenerator BindSystem Preprocessor DebuggingAndJIT FunctionLibraries LanguageFeatures EditorAndTools) do (
    echo == %%M ==
    call "%~dp0RunTestCoverageGap_RalphLoop_%%M.bat" %*
    if errorlevel 1 echo [WARN] %%M exit=%ERRORLEVEL%
)
