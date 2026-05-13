## ADDED Requirements

### Requirement: Disabled GMP editor modules are not part of the active plugin descriptor

The `UnrealEvent` plugin SHALL keep GMP editor-side modules out of `UnrealEvent.uplugin` until a future change introduces UnrealEvent-specific editor functionality.

#### Scenario: Active module list is inspected

- **WHEN** `Plugins/UnrealEvent/UnrealEvent.uplugin` is inspected
- **THEN** the `Modules` list contains the runtime `GMP` module
- **AND** it does not contain `GMPEditor`, `MessageTags`, or `MessageTagsEditor`

### Requirement: Physical source pruning is deliberate

The `UnrealEvent` plugin SHALL remove or archive the disabled GMP editor-side module source only after references and replacement needs are audited.

#### Scenario: Cleanup change removes source directories

- **WHEN** the cleanup implementation is applied
- **THEN** `Source/GMPEditor/GMPEditor`, `Source/GMPEditor/MessageTags`, and `Source/GMPEditor/MessageTagsEditor` are either removed from the plugin source tree or explicitly archived outside the active plugin build tree
- **AND** the decision preserves access to needed reference history through git history, documentation, or a named external reference location

### Requirement: Runtime GMP remains build-discoverable

The `UnrealEvent` plugin SHALL continue to expose the runtime GMP-derived event core after editor-side module pruning.

#### Scenario: Host project build discovers UnrealEvent

- **WHEN** the host project build is run through the documented build runner
- **THEN** Unreal Build Tool discovers `UnrealEvent` without attempting to build the removed GMP editor-side modules
- **AND** the build completes without descriptor errors caused by stale module or plugin dependency declarations

## Testing Requirements

- Target test layer: build/config validation only; no new automation test layer is required unless later runtime behavior changes.
- Expected Automation prefix: none for this structural cleanup.
- Recommended helper/harness: `Tools\RunBuild.ps1` from the project unified build runner.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label unrealevent-prune-gmp-editor-modules -TimeoutMs 180000 -NoXGE`.
