## 1. Descriptor Baseline

- [x] 1.1 <!-- Non-TDD --> Remove `GMPEditor`, `MessageTags`, and `MessageTagsEditor` from `Plugins/UnrealEvent/UnrealEvent.uplugin`; verify with JSON parsing and `Tools\RunBuild.ps1`.
- [x] 1.2 <!-- Non-TDD --> Commit the descriptor-only change inside `Plugins/UnrealEvent` so the disabled modules are no longer part of the active plugin metadata.

## 2. Reference Audit

- [ ] 2.1 <!-- Non-TDD --> Search `Plugins/UnrealEvent` for `GMPEditor`, `MessageTags`, `MessageTagsEditor`, and editor-only plugin dependencies; record any runtime references that must be retained or replaced.
- [ ] 2.2 <!-- Non-TDD --> Decide whether the three disabled module directories should be deleted entirely or copied to a named external reference location before deletion.

## 3. Physical Cleanup

- [ ] 3.1 <!-- Non-TDD --> Remove or archive `Plugins/UnrealEvent/Source/GMPEditor/GMPEditor`, `Plugins/UnrealEvent/Source/GMPEditor/MessageTags`, and `Plugins/UnrealEvent/Source/GMPEditor/MessageTagsEditor` according to the audit decision.
- [ ] 3.2 <!-- Non-TDD --> Remove stale module build files, include paths, config references, and descriptor plugin dependencies that existed only for the disabled editor/tag modules.
- [ ] 3.3 <!-- Non-TDD --> Keep runtime `GMP` source, required `ThirdParty` code, `StructUtils` dependency, and GMP license attribution intact unless a separate OpenSpec change supersedes that scope.

## 4. Verification

- [ ] 4.1 <!-- Non-TDD --> Validate descriptor JSON with `Get-Content -Raw Plugins\UnrealEvent\UnrealEvent.uplugin | ConvertFrom-Json`.
- [ ] 4.2 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label unrealevent-prune-gmp-editor-modules -TimeoutMs 180000 -NoXGE`.
- [ ] 4.3 <!-- Non-TDD --> Run `openspec validate "refactor-unrealevent-prune-gmp-editor-modules" --strict --json` and update this task list before committing the cleanup.
