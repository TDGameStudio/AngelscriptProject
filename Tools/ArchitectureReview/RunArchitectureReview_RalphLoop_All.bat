@echo off
setlocal
chcp 65001 >nul 2>&1
for %%M in (ModuleStructure BindingPipeline TypeSystem HotReloadArch ScriptLifecycle DebugAndToolchain ExtensionPoints EditorArch) do (
    echo == %%M ==
    call "%~dp0RunArchitectureReview_RalphLoop_%%M.bat" %*
    if errorlevel 1 echo [WARN] %%M exit=%ERRORLEVEL%
)
