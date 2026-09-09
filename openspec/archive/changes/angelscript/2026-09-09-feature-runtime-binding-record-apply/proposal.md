## Why

Runtime providers still target the dormant immediate-registration API. The reconstructed native engine installs frozen metadata images instead, so an explicitly owned `FAngelscriptEngine` cannot yet expose the existing UE binding surface. The earlier `refactor-as-subsystem-typeinfo-bind-cache` workspace demonstrates engine-independent recording and staged application, but its application backend and experimental parallel preparation do not fit the current runtime.

## What Changes

- Manually adapt recording, sealing and staged application to all current Runtime providers, preserving UE adapters, reflection precedence, native callers, template behavior and target conditions.
- Build complete per-engine metadata images and native bindings serially. Reuse immutable recorded descriptions between engines, never engine-bound metadata objects or mutable adapter state.
- Add explicit `FAngelscriptEngine::CreateForBindings` entry points for a fresh Runtime snapshot and an existing sealed store, with failure diagnostics and deterministic ownership.
- Port the behavioral intent of dormant value, container, UE interop and engine-isolation tests into replacement CQTests. Prove full installation coverage and representative native calls through the current VM.
- Export the intended AS surface before Engine creation as versioned JSON and readable tables of types, inheritance, members, globals and exclusions. Add standalone Python validation/diff and reconcile the manifest with full Runtime installation.
- Keep production recording serial. Preserve default dormant startup and legacy test isolation. Full script compilation, scanning, hot reload, debugger/cache services, JIT execution, dynamic module-load updates and separate GAS/GameplayTags plugins are outside this change.

## Capabilities

### New Capabilities

- `angelscript/bindings/runtime`: detached Runtime binding descriptions, serial application, complete provider accounting, template instances and native calls.
- `angelscript/runtime/binding-engine`: explicit binding-engine creation, snapshot reuse, failures and isolation.

### Modified Capabilities

- `angelscript/testing/baseline`: explicitly owned replacement RuntimeBindings fixtures and public identities, preserving dormant defaults and legacy exclusions.

## Impact

Product code and replacement tests belong to the `Plugins/Angelscript` submodule. OpenSpec records and the focused testing guide belong to the parent repository. The host project remains minimal. Current work is performed in the selected primary workspace, with no branch integration, publication, workspace removal or unrelated edits.

The accepted planning conversation is the pre-creation decision-complete handoff. Task outcomes progress from recording through type application and ownership to every Runtime provider; representative initial tests do not reduce the full migration commitment.
