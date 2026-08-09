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
set "REPO_COMMIT="

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

if /I "%REFERENCE_KEY%"=="aura" (
    set "REPO_NAME=GameplayAbilitySystem_Aura_Initial"
    set "REPO_SSH=git@github.com:DruidMech/GameplayAbilitySystem_Aura.git"
    set "REPO_HTTPS=https://github.com/DruidMech/GameplayAbilitySystem_Aura.git"
    set "REPO_COMMIT=f778ff39e873a756d5a3f97f263d6f24662fdde9"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\GameplayAbilitySystem_Aura_Initial"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="auracpp" (
    set "REPO_NAME=GameplayAbilitySystem_Aura_Cpp"
    set "REPO_SSH=git@github.com:DruidMech/GameplayAbilitySystem_Aura.git"
    set "REPO_HTTPS=https://github.com/DruidMech/GameplayAbilitySystem_Aura.git"
    set "REPO_BRANCH=main"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\GameplayAbilitySystem_Aura_Cpp"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="auraas" (
    set "REPO_NAME=AngelscriptAura"
    set "REPO_SSH=git@github.com:najoast/AngelscriptAura.git"
    set "REPO_HTTPS=https://github.com/najoast/AngelscriptAura.git"
    set "REPO_BRANCH=main"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\AngelscriptAura"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="blendermcp" (
    set "REPO_NAME=blender_mcp"
    set "REPO_SSH="
    set "REPO_HTTPS=https://projects.blender.org/lab/blender_mcp.git"
    set "REPO_BRANCH=main"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\blender_mcp"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="itonnote-theme" (
    set "REPO_NAME=tiddlywiki-itonnote-theme"
    set "REPO_SSH=git@github.com:tiddly-gittly/itonnote-theme.git"
    set "REPO_HTTPS=https://github.com/tiddly-gittly/itonnote-theme.git"
    set "REPO_COMMIT=f7e29d2f00c4d24a2eefee9b4b4f27dcf0e918e1"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\tiddlywiki-itonnote-theme"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="itonnote-plugin" (
    set "REPO_NAME=tiddlywiki-itonnote-plugin"
    set "REPO_SSH=git@github.com:tiddly-gittly/itonnote-plugin.git"
    set "REPO_HTTPS=https://github.com/tiddly-gittly/itonnote-plugin.git"
    set "REPO_COMMIT=726a0f00b9fe46890fbdebfb33a38768a5515959"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\tiddlywiki-itonnote-plugin"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="tiddlyseq" (
    set "REPO_NAME=tiddlywiki-seq"
    set "REPO_SSH=git@github.com:Gk0Wk/TiddlySeq.git"
    set "REPO_HTTPS=https://github.com/Gk0Wk/TiddlySeq.git"
    set "REPO_COMMIT=96e48da076b86b475948a930ab5f60abe5961d77"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\tiddlywiki-seq"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="tw-command-palette" (
    set "REPO_NAME=tiddlywiki-command-palette"
    set "REPO_SSH=git@github.com:tiddly-gittly/tw-command-palette.git"
    set "REPO_HTTPS=https://github.com/tiddly-gittly/tw-command-palette.git"
    set "REPO_COMMIT=b3d0535fd499e9fbe00312d0d51e7e5d9b7961df"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\tiddlywiki-command-palette"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="tiddlywiki-plugins" (
    set "REPO_NAME=tiddlywiki-plugins"
    set "REPO_SSH=git@github.com:tiddly-gittly/tiddlywiki-plugins.git"
    set "REPO_HTTPS=https://github.com/tiddly-gittly/tiddlywiki-plugins.git"
    set "REPO_COMMIT=d1ae085fbea63ff39f5474f5d165b3cb4af6704a"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\tiddlywiki-plugins"
    goto :ValidateGit
)

if /I "%REFERENCE_KEY%"=="tiddlywiki-codemirror-6" (
    set "REPO_NAME=tiddlywiki-codemirror-6"
    set "REPO_SSH=git@github.com:oeyoews/tiddlywiki-codemirror-6.git"
    set "REPO_HTTPS=https://github.com/oeyoews/tiddlywiki-codemirror-6.git"
    set "REPO_COMMIT=3854131afe31fa225936808526e9c0cd29524661"
    if "%TARGET_DIR%"=="" set "TARGET_DIR=%PROJECT_ROOT%\Reference\tiddlywiki-codemirror-6"
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
echo   aura              - Pull Aura GAS course initial project into Reference\GameplayAbilitySystem_Aura_Initial
echo   auracpp           - Pull Aura GAS course C++ project into Reference\GameplayAbilitySystem_Aura_Cpp
echo   auraas            - Pull Aura GAS Angelscript rewrite into Reference\AngelscriptAura
echo   blendermcp        - Pull Blender MCP into Reference\blender_mcp
echo   itonnote-theme    - Pull itonnote theme source at the reviewed commit
echo   itonnote-plugin   - Pull itonnote-plugin source at the reviewed commit
echo   tiddlyseq         - Pull TiddlySeq source at the reviewed commit
echo   tw-command-palette - Pull command palette source at the reviewed commit
echo   tiddlywiki-plugins - Pull preview-glass source at the reviewed commit
echo   tiddlywiki-codemirror-6 - Pull CodeMirror 6 source at the reviewed commit
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
echo   Tools\PullReference\PullReference.bat aura
echo   Tools\PullReference\PullReference.bat auracpp
echo   Tools\PullReference\PullReference.bat auraas
echo   Tools\PullReference\PullReference.bat blendermcp
echo   Tools\PullReference\PullReference.bat itonnote-theme
echo   Tools\PullReference\PullReference.bat itonnote-plugin
echo   Tools\PullReference\PullReference.bat tiddlyseq
echo   Tools\PullReference\PullReference.bat tw-command-palette
echo   Tools\PullReference\PullReference.bat tiddlywiki-plugins
echo   Tools\PullReference\PullReference.bat tiddlywiki-codemirror-6
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

set "CLONE_URL=%REPO_SSH%"
set "CLONE_LABEL=SSH"
if not defined REPO_SSH (
    set "CLONE_URL=%REPO_HTTPS%"
    set "CLONE_LABEL=HTTPS"
)

set "SYNC_URL=%REPO_SSH%"
if not defined REPO_SSH set "SYNC_URL=%REPO_HTTPS%"

if not exist "%TARGET_DIR%\.git" (
    if exist "%TARGET_DIR%" (
        echo Target directory exists but is not a git repository:
        echo   "%TARGET_DIR%"
        echo Remove it manually or provide a different target path.
        exit /b 1
    )

    echo Cloning %REPO_NAME% from %CLONE_LABEL% remote...
    if defined REPO_COMMIT (
        mkdir "%TARGET_DIR%"
        if errorlevel 1 (
            echo Failed to create target directory:
            echo   "%TARGET_DIR%"
            exit /b 1
        )
        git -C "%TARGET_DIR%" init
        if errorlevel 1 (
            echo Failed to initialize git repository:
            echo   "%TARGET_DIR%"
            exit /b 1
        )
        git -C "%TARGET_DIR%" remote add origin "%CLONE_URL%"
        if errorlevel 1 (
            echo Failed to add %CLONE_LABEL% remote URL.
            exit /b 1
        )
        git -C "%TARGET_DIR%" fetch --depth 1 origin "%REPO_COMMIT%"
        if errorlevel 1 (
            echo %CLONE_LABEL% fetch failed.
            echo Repository:
            echo   %REPO_HTTPS%
            exit /b 1
        )
        git -C "%TARGET_DIR%" checkout --force FETCH_HEAD
        if errorlevel 1 (
            echo Failed to checkout commit %REPO_COMMIT%.
            exit /b 1
        )
    ) else if defined REPO_TAG (
        git clone --branch "%REPO_TAG%" --depth 1 "%CLONE_URL%" "%TARGET_DIR%"
    ) else (
        git clone --branch "%REPO_BRANCH%" --depth 1 "%CLONE_URL%" "%TARGET_DIR%"
    )
    if errorlevel 1 (
        echo %CLONE_LABEL% clone failed.
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

git remote set-url origin "%SYNC_URL%"
if errorlevel 1 (
    echo Failed to set remote URL.
    popd >nul
    exit /b 1
)

if defined REPO_TAG goto :SyncTag
if defined REPO_COMMIT goto :SyncCommit
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

:SyncCommit
echo Fetching commit %REPO_COMMIT% from SSH remote...
git fetch origin "%REPO_COMMIT%" --depth 1
if errorlevel 1 (
    echo Failed to fetch commit %REPO_COMMIT% from SSH remote.
    popd >nul
    exit /b 1
)

git checkout --force FETCH_HEAD
if errorlevel 1 (
    echo Failed to checkout commit %REPO_COMMIT%.
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

if defined REPO_COMMIT (
    echo Synced %REPO_NAME% to %REPO_COMMIT% ^(%HEAD_SHA%^)
) else if defined REPO_TAG (
    echo Synced %REPO_NAME% to %REPO_TAG% ^(%HEAD_SHA%^)
) else (
    echo Synced %REPO_NAME% to %REPO_BRANCH% ^(%HEAD_SHA%^)
)
echo   "%TARGET_DIR%"

popd >nul
exit /b 0
