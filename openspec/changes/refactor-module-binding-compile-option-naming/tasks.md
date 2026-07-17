## 1. Record and test first

- [x] 1.1 Record the canonical setting/macro names and affected active paths in the change artifacts.
- [x] 1.2 Update compile-gate tests to assert `bCompileAngelscriptModuleBindings` and `WITH_ANGELSCRIPT_MODULE_BINDINGS`, then run the focused test/build to observe the expected red state.

## 2. Rename active implementation identifiers

- [x] 2.1 Rename the config property and default ini key.
- [x] 2.2 Rename the Runtime Build.cs local/setting key, public definition, bridge guard, and Editor validation identifiers/messages.
- [x] 2.3 Rename the UHT setting constant, reader helper, and source-engine diagnostics.

## 3. Update active references

- [x] 3.1 Update plugin README and maintained build/UHT documentation while preserving historical OpenSpec records.
- [x] 3.2 Confirm no active production/test/config path retains the legacy gate names.

## 4. Verify

- [x] 4.1 Run `Tools\\RunBuild.ps1` with the default option and verify the macro is `0` and no ModuleBinding shards are emitted.
- [x] 4.2 Run `Tools\\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver"`.
- [x] 4.3 Run `Tools\\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionTable"`.
- [x] 4.4 Record results in `verification.md` and mark the change complete.
