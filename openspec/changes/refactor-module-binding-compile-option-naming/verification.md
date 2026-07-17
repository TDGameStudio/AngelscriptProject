# Verification

Date: 2026-07-18

## Build

Command:

```powershell
Tools\RunBuild.ps1 -Label module-binding-compile-option-final -NoXGE
```

Result: succeeded with exit code `0`. The default configuration remains disabled. The focused compile-gate and generated-output tests below verify `WITH_ANGELSCRIPT_MODULE_BINDINGS=0` behavior and suppression of ModuleBinding shards when the option is disabled.

## Focused tests

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver"
```

Result: `15/15` passed, `0` failed, `0` skipped.

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionTable"
```

Result: `11/11` passed, `0` failed, `0` skipped.

The two test runners were ultimately executed serially because the first parallel attempt correctly rejected the second process with the workspace execution lock. The serial rerun passed without code changes.

## Naming scan

The active source, configuration, tests, README, and maintained documentation use only `bCompileAngelscriptModuleBindings` and `WITH_ANGELSCRIPT_MODULE_BINDINGS`. Historical OpenSpec records retain the legacy names where they describe the prior implementation.
