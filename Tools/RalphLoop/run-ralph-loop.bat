@echo off
setlocal
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "PS_EXE=powershell"
set "PROMPT="
set "MAX_ITERATIONS=5"
set "AGENT_HOME="
set "CODEX_HOME_OPTION="
set "PROMPT_FILE="
set "TIMEOUT_SECONDS="
set "MAX_CONSECUTIVE_FAILURES="
set "WORKFLOW="
set "PRD_FILE="
set "PROGRESS_FILE="
set "AGENT="
set "AGENT_COMMAND="
set "VERIFY_COMMAND="
set "RUNS_ROOT="
set "TRUST_AGENT=0"
set "STREAM_AGENT_OUTPUT=0"

where pwsh >nul 2>nul
if not errorlevel 1 set "PS_EXE=pwsh"
if "%PS_EXE%"=="powershell" if exist "C:\Program Files\PowerShell\7\pwsh.exe" set "PS_EXE=C:\Program Files\PowerShell\7\pwsh.exe"

:parse_args
if "%~1"=="" goto :validate_args
if /I "%~1"=="-Help" goto :usage
if /I "%~1"=="--Help" goto :usage

if /I "%~1"=="-Prompt" goto :argprompttext
if /I "%~1"=="-Task" goto :argprompttext
if /I "%~1"=="-MaxIterations" goto :argmax
if /I "%~1"=="-AgentHome" goto :arghome
if /I "%~1"=="-CodexHome" goto :argcodexhome
if /I "%~1"=="-PromptFile" goto :argprompt
if /I "%~1"=="-TimeoutSeconds" goto :argto
if /I "%~1"=="-CommandTimeoutSeconds" goto :argto
if /I "%~1"=="-MaxConsecutiveFailures" goto :argfailmax
if /I "%~1"=="-Workflow" goto :argworkflow
if /I "%~1"=="-PrdFile" goto :argprd
if /I "%~1"=="-ProgressFile" goto :argprogress
if /I "%~1"=="-Agent" goto :argagent
if /I "%~1"=="-AgentCommand" goto :argcmd
if /I "%~1"=="-VerifyCommand" goto :argverify
if /I "%~1"=="-RunsRoot" goto :argruns
if /I "%~1"=="-TrustAgent" goto :argtrust
if /I "%~1"=="-StreamAgentOutput" goto :argstream

echo Unknown argument: %~1
goto :usage_error

:argprompttext
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "PROMPT=%~2"
shift /1
shift /1
goto :parse_args

:argmax
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "MAX_ITERATIONS=%~2"
shift /1
shift /1
goto :parse_args

:arghome
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "AGENT_HOME=%~2"
shift /1
shift /1
goto :parse_args

:argcodexhome
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "CODEX_HOME_OPTION=%~2"
shift /1
shift /1
goto :parse_args

:argprompt
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "PROMPT_FILE=%~2"
shift /1
shift /1
goto :parse_args

:argto
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "TIMEOUT_SECONDS=%~2"
shift /1
shift /1
goto :parse_args

:argfailmax
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "MAX_CONSECUTIVE_FAILURES=%~2"
shift /1
shift /1
goto :parse_args

:argworkflow
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "WORKFLOW=%~2"
shift /1
shift /1
goto :parse_args

:argprd
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "PRD_FILE=%~2"
shift /1
shift /1
goto :parse_args

:argprogress
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "PROGRESS_FILE=%~2"
shift /1
shift /1
goto :parse_args

:argagent
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "AGENT=%~2"
shift /1
shift /1
goto :parse_args

:argcmd
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "AGENT_COMMAND=%~2"
shift /1
shift /1
goto :parse_args

:argverify
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "VERIFY_COMMAND=%~2"
shift /1
shift /1
goto :parse_args

:argruns
if "%~2"=="" (
    echo Missing value for %~1
    goto :usage_error
)
set "RUNS_ROOT=%~2"
shift /1
shift /1
goto :parse_args

:argtrust
set "TRUST_AGENT=1"
shift /1
goto :parse_args

:argstream
set "STREAM_AGENT_OUTPUT=1"
shift /1
goto :parse_args

:validate_args
if "%PROMPT%"=="" (
    echo Missing required argument: -Prompt
    goto :usage_error
)

if not "%TIMEOUT_SECONDS%"=="" (
    echo(%TIMEOUT_SECONDS%| findstr /r "^[0-9][0-9]*$" >nul
    if errorlevel 1 (
        echo Invalid value for -TimeoutSeconds: %TIMEOUT_SECONDS%
        exit /b 1
    )
)

if not "%MAX_CONSECUTIVE_FAILURES%"=="" (
    echo(%MAX_CONSECUTIVE_FAILURES%| findstr /r "^[0-9][0-9]*$" >nul
    if errorlevel 1 (
        echo Invalid value for -MaxConsecutiveFailures: %MAX_CONSECUTIVE_FAILURES%
        exit /b 1
    )
)

set "PS_ARGS=-NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%ralph-loop.ps1" -Prompt "%PROMPT%" -MaxIterations %MAX_ITERATIONS%"

if not "%AGENT_HOME%"=="" set "PS_ARGS=%PS_ARGS% -AgentHome "%AGENT_HOME%""
if not "%CODEX_HOME_OPTION%"=="" set "PS_ARGS=%PS_ARGS% -CodexHome "%CODEX_HOME_OPTION%""
if not "%PROMPT_FILE%"=="" set "PS_ARGS=%PS_ARGS% -PromptFile "%PROMPT_FILE%""
if not "%TIMEOUT_SECONDS%"=="" set "PS_ARGS=%PS_ARGS% -CommandTimeoutSeconds %TIMEOUT_SECONDS%"
if not "%MAX_CONSECUTIVE_FAILURES%"=="" set "PS_ARGS=%PS_ARGS% -MaxConsecutiveFailures %MAX_CONSECUTIVE_FAILURES%"
if not "%WORKFLOW%"=="" set "PS_ARGS=%PS_ARGS% -Workflow "%WORKFLOW%""
if not "%PRD_FILE%"=="" set "PS_ARGS=%PS_ARGS% -PrdFile "%PRD_FILE%""
if not "%PROGRESS_FILE%"=="" set "PS_ARGS=%PS_ARGS% -ProgressFile "%PROGRESS_FILE%""
if not "%AGENT%"=="" set "PS_ARGS=%PS_ARGS% -Agent "%AGENT%""
if not "%AGENT_COMMAND%"=="" set "PS_ARGS=%PS_ARGS% -AgentCommand "%AGENT_COMMAND%""
if not "%VERIFY_COMMAND%"=="" set "PS_ARGS=%PS_ARGS% -VerifyCommand "%VERIFY_COMMAND%""
if not "%RUNS_ROOT%"=="" set "PS_ARGS=%PS_ARGS% -RunsRoot "%RUNS_ROOT%""
if "%TRUST_AGENT%"=="1" set "PS_ARGS=%PS_ARGS% -TrustAgent"
if "%STREAM_AGENT_OUTPUT%"=="1" set "PS_ARGS=%PS_ARGS% -StreamAgentOutput"

call "%PS_EXE%" %PS_ARGS%
exit /b %ERRORLEVEL%

:usage
echo Usage: run-ralph-loop.bat -Prompt "prompt text" [-MaxIterations N] [-MaxConsecutiveFailures N] [-Workflow Basic^|Prd] [-PrdFile PATH] [-ProgressFile PATH] [-Agent codex^|opencode^|claude] [-AgentHome PATH] [-CodexHome PATH] [-PromptFile PATH] [-TimeoutSeconds N] [-AgentCommand CMD] [-VerifyCommand CMD] [-RunsRoot PATH] [-TrustAgent] [-StreamAgentOutput]
exit /b 0

:usage_error
echo Usage: run-ralph-loop.bat -Prompt "prompt text" [-MaxIterations N] [-MaxConsecutiveFailures N] [-Workflow Basic^|Prd] [-PrdFile PATH] [-ProgressFile PATH] [-Agent codex^|opencode^|claude] [-AgentHome PATH] [-CodexHome PATH] [-PromptFile PATH] [-TimeoutSeconds N] [-AgentCommand CMD] [-VerifyCommand CMD] [-RunsRoot PATH] [-TrustAgent] [-StreamAgentOutput]
exit /b 1
