## 1. Runtime XConsole Removal

- [x] 1.1 <!-- Non-TDD --> Remove `XConsoleManager.cpp`, `XConsolePythonSupport.h`, and `XConsoleManager.h` from `Plugins/UnrealEvent/Source/UnrealEvent`; verify with `rg -n "XConsole|IXConsole|FXConsole" Plugins\UnrealEvent\Source\UnrealEvent`.
- [x] 1.2 <!-- Non-TDD --> Remove `ProcessXCommandFromCmdline` startup hooks from `GMPModule.cpp`; verify with `rg -n "ProcessXCommand|z\.Pipeline|z\.XCmdList" Plugins\UnrealEvent\Source\UnrealEvent`.
- [x] 1.3 <!-- Non-TDD --> Replace XConsole debug registrations in `GMPSignalsImpl.cpp` with standard Unreal console APIs while preserving `gmp.key.debug` and `gmp.msgkey.debug`; verify with `rg -n "XConsoleManager|FXConsole" Plugins\UnrealEvent\Source\UnrealEvent\Private\GMPSignalsImpl.cpp`.

## 2. Reference Editor Cleanup

- [x] 2.1 <!-- Non-TDD --> Remove XConsole includes and registrations from `Plugins/UnrealEvent/Source/GMPEditor`; verify with `rg -n "XConsole|IXConsole|FXConsole|ProcessXCommand" Plugins\UnrealEvent\Source\GMPEditor`.

## 3. Build Metadata Cleanup

- [x] 3.1 <!-- Non-TDD --> Remove XConsole-only `HTTPServer`, `GMP_HTTPSERVER`, and `PythonScriptPlugin` dependencies from `UnrealEvent.Build.cs`; verify with `rg -n "HTTPServer|GMP_HTTPSERVER|PythonScriptPlugin" Plugins\UnrealEvent\Source\UnrealEvent\UnrealEvent.Build.cs`.
- [x] 3.2 <!-- Non-TDD --> Remove the optional `PythonScriptPlugin` dependency from `UnrealEvent.uplugin`; verify with `Get-Content -Raw Plugins\UnrealEvent\UnrealEvent.uplugin | ConvertFrom-Json`.

## 4. Verification

- [x] 4.1 <!-- Non-TDD --> Run full removal search: `rg -n "XConsole|xconsole|ProcessXCommand|IXConsole|FXConsole|GMP_HTTPSERVER|HTTPServer|PythonScriptPlugin|IPythonScriptPlugin|z\.Pipeline|z\.XCmdList" Plugins\UnrealEvent`.
- [x] 4.2 <!-- Non-TDD --> Run build verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label unrealevent-remove-xconsole -TimeoutMs 180000 -NoXGE`.
- [x] 4.3 <!-- Non-TDD --> Run OpenSpec validation: `openspec validate "refactor-unrealevent-remove-xconsole" --strict --json`.
