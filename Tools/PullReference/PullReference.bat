@echo off
setlocal

for %%I in ("%~dp0..\..") do set "PROJECT_ROOT=%%~fI"

set "REFERENCE_KEY=%~1"
set "TARGET_DIR=%~2"
set "REPO_NAME="
set "REPO_SSH="
set "REPO_HTTPS="
set "REPO_BRANCH="
set "REPO_TAG="

if "%REFERENCE_KEY%"=="" goto :Usage
if /I "%REFERENCE_KEY%"=="list" goto :List

if /I "%REFERENCE_KEY%"=="angelscript" (
    set "REPO_NAME=angelscript-v2.38.0"
    set "REPO_SSH=git@github.com:anjo76/angelscript.git"
    set "REPO_HTTPS=https://github.com/anjo76/angelscript.git"
    set "REPO_TAG=v2.38.0"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\angelscript-v2.38.0"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="unrealcsharp" (
    set "REPO_NAME=UnrealCSharp"
    set "REPO_SSH=git@github.com:crazytuzi/UnrealCSharp.git"
    set "REPO_HTTPS=https://github.com/crazytuzi/UnrealCSharp.git"
    set "REPO_BRANCH=main"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\UnrealCSharp"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="unlua" (
    set "REPO_NAME=UnLua"
    set "REPO_SSH=git@github.com:Tencent/UnLua.git"
    set "REPO_HTTPS=https://github.com/Tencent/UnLua.git"
    set "REPO_BRANCH=master"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\UnLua"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="puerts" (
    set "REPO_NAME=puerts"
    set "REPO_SSH=git@github.com:Tencent/puerts.git"
    set "REPO_HTTPS=https://github.com/Tencent/puerts.git"
    set "REPO_BRANCH=master"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\puerts"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="sluaunreal" (
    set "REPO_NAME=sluaunreal"
    set "REPO_SSH=git@github.com:Tencent/sluaunreal.git"
    set "REPO_HTTPS=https://github.com/Tencent/sluaunreal.git"
    set "REPO_BRANCH=master"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\sluaunreal"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="hazelightdocs" (
    set "REPO_NAME=Docs-UnrealEngine-Angelscript"
    set "REPO_SSH=git@github.com:Hazelight/Docs-UnrealEngine-Angelscript.git"
    set "REPO_HTTPS=https://github.com/Hazelight/Docs-UnrealEngine-Angelscript.git"
    set "REPO_BRANCH=master"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\Docs-UnrealEngine-Angelscript"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="hazelightvscode" (
    set "REPO_NAME=vscode-unreal-angelscript"
    set "REPO_SSH=git@github.com:Hazelight/vscode-unreal-angelscript.git"
    set "REPO_HTTPS=https://github.com/Hazelight/vscode-unreal-angelscript.git"
    set "REPO_BRANCH=master"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\vscode-unreal-angelscript"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="hazelight" goto :Hazelight

echo Unknown reference key: %REFERENCE_KEY%
echo.
goto :Usage

:List
echo Supported reference keys:
echo   angelscript       - Pull AngelScript upstream v2.38.0 into Reference\angelscript-v2.38.0
echo   unrealcsharp      - Pull UnrealCSharp into Reference\UnrealCSharp
echo   unlua             - Pull Tencent UnLua into Reference\UnLua
echo   puerts            - Pull Tencent puerts into Reference\puerts
echo   sluaunreal        - Pull Tencent sluaunreal into Reference\sluaunreal
echo   hazelightdocs     - Pull Hazelight public docs into Reference\Docs-UnrealEngine-Angelscript
echo   hazelightvscode   - Pull Hazelight VS Code extension into Reference\vscode-unreal-angelscript
echo   hazelight         - Local config only, read AgentConfig.ini
exit /b 0

:Hazelight
echo Reference key 'hazelight' is not pullable by this tool.
echo Read the local path from AgentConfig.ini:
echo   [References] HazelightAngelscriptEngineRoot
echo Use 'hazelightdocs' to pull the public documentation repository.
exit /b 1

:Usage
echo Usage:
echo   Tools\PullReference\PullReference.bat ^<reference-key^> [target-dir]
echo.
echo Examples:
echo   Tools\PullReference\PullReference.bat angelscript
echo   Tools\PullReference\PullReference.bat unrealcsharp
echo   Tools\PullReference\PullReference.bat unlua
echo   Tools\PullReference\PullReference.bat puerts
echo   Tools\PullReference\PullReference.bat sluaunreal
echo   Tools\PullReference\PullReference.bat hazelightdocs
echo   Tools\PullReference\PullReference.bat hazelightvscode
echo   Tools\PullReference\PullReference.bat angelscript "J:\UnrealEngine\AngelscriptProject\Reference\angelscript-v2.38.0"
echo   Tools\PullReference\PullReference.bat list
exit /b 1

:ValidateGit
where git >nul 2>nul
if errorlevel 1 (
    echo Git was not found in PATH.
    exit /b 1
)

for %%I in ("%TARGET_DIR%\..") do set "TARGET_PARENT=%%~fI"

if not exist "%TARGET_PARENT%" (
    mkdir "%TARGET_PARENT%"
    if errorlevel 1 (
        echo Failed to create target parent directory:
        echo   "%TARGET_PARENT%"
        exit /b 1
    )
)

if not exist "%TARGET_DIR%\.git" (
    if exist "%TARGET_DIR%" (
        echo Target directory exists but is not a git repository:
        echo   "%TARGET_DIR%"
        echo Remove it manually or provide a different target path.
        exit /b 1
    )

    echo Cloning %REPO_NAME% from SSH remote...
    if defined REPO_TAG (
        git clone --branch "%REPO_TAG%" --depth 1 "%REPO_SSH%" "%TARGET_DIR%"
    ) else (
        git clone --branch "%REPO_BRANCH%" --depth 1 "%REPO_SSH%" "%TARGET_DIR%"
    )
    if errorlevel 1 (
        echo SSH clone failed.
        echo Verify your GitHub SSH key is configured correctly.
        echo Repository:
        echo   %REPO_HTTPS%
        exit /b 1
    )

    echo Synced:
    echo   "%TARGET_DIR%"
    exit /b 0
)

pushd "%TARGET_DIR%" >nul 2>nul
if errorlevel 1 (
    echo Failed to enter target directory:
    echo   "%TARGET_DIR%"
    exit /b 1
)

set "HAS_CHANGES="
for /f "delims=" %%I in ('git status --porcelain') do (
    set "HAS_CHANGES=1"
    goto :StatusChecked
)
:StatusChecked

if defined HAS_CHANGES (
    echo Repository has local changes and will not be updated automatically:
    echo   "%TARGET_DIR%"
    popd >nul
    exit /b 1
)

git remote set-url origin "%REPO_SSH%"
if errorlevel 1 (
    echo Failed to set SSH remote URL.
    popd >nul
    exit /b 1
)

if defined REPO_TAG goto :SyncTag
goto :SyncBranch

:SyncTag
echo Fetching tag %REPO_TAG% from SSH remote...
git fetch origin "refs/tags/%REPO_TAG%:refs/tags/%REPO_TAG%" --force
if errorlevel 1 (
    echo Failed to fetch tag %REPO_TAG% from SSH remote.
    popd >nul
    exit /b 1
)

git checkout --force "tags/%REPO_TAG%"
if errorlevel 1 (
    echo Failed to checkout tag %REPO_TAG%.
    popd >nul
    exit /b 1
)

goto :PrintHead

:SyncBranch
echo Fetching branch %REPO_BRANCH% from SSH remote...
git fetch origin "%REPO_BRANCH%" --depth 1
if errorlevel 1 (
    echo Failed to fetch branch %REPO_BRANCH% from SSH remote.
    popd >nul
    exit /b 1
)

git checkout --force "%REPO_BRANCH%"
if errorlevel 1 (
    echo Failed to checkout branch %REPO_BRANCH%.
    popd >nul
    exit /b 1
)

git reset --hard "origin/%REPO_BRANCH%"
if errorlevel 1 (
    echo Failed to reset to origin/%REPO_BRANCH%.
    popd >nul
    exit /b 1
)

:PrintHead
for /f "delims=" %%I in ('git rev-parse --short HEAD') do set "HEAD_SHA=%%I"

if defined REPO_TAG (
    echo Synced %REPO_NAME% to %REPO_TAG% ^(%HEAD_SHA%^)
) else (
    echo Synced %REPO_NAME% to %REPO_BRANCH% ^(%HEAD_SHA%^)
)
echo   "%TARGET_DIR%"

popd >nul
exit /b 0
