# Global and Thread-Local State

Native core coverage runs inside the Unreal Editor automation process, where `AngelscriptRuntime` may already have installed production hooks. A raw SDK test must not interpret “global API exists” as permission to replace process state. This inventory defines the safe test mode for each state owner.

| State/API | Scope/current condition | Test mode | Restoration/guard |
| --- | --- | --- | --- |
| message callback | engine instance | set/get/clear and compile delivery on case-owned engine | `FNativeTestEngine` owns collector and engine shutdown |
| engine properties/default namespace/access mask/JIT/string factory | engine instance | full contract/behavior on case-owned engine | engine destruction |
| modules/registrations/config groups/GC | engine instance | full contract/behavior on case-owned engine | scoped module cleanup then engine destruction |
| contexts/active context/function | thread-local + engine | full execution on case-owned context | unprepare/release; assert prior active context is restored |
| shared/exclusive locks | process-global synchronization | acquire/release pairing only; no intentionally blocking cross-test lock | narrow RAII scope on the same thread |
| atomic helpers/`asCAtomic` | caller-owned value | full behavior/concurrency test | join every worker before method exit |
| `asCThreadManager` TLS access | process/thread | direct TLS identity/cleanup behavior that does not replace the manager | worker join and thread cleanup; main production manager remains installed |
| `asPrepareMultithread` / `asUnprepareMultithread` | process-global manager, potentially already prepared by runtime | non-mutating current-manager contract only in the editor batch process | do not unprepare/replace production manager; isolated-process coverage would require a separate approved harness |
| `asSetAllocScriptObjectFunction` | process-global hooks installed by `FAngelscriptEngine` for `UASClass` | static declaration/implementation ownership plus existing wrapper integration evidence | SDK tests must not replace or clear it; there is no getter/safe restore API |
| `asSetResolveObjectPtrFunction` | process-global hook installed by `FAngelscriptEngine` | static declaration/implementation ownership plus existing wrapper integration evidence | SDK tests must not replace or clear it; there is no getter/safe restore API |
| `asSetGlobalMemoryFunctions` / `asResetGlobalMemoryFunctions` | declared in core header but no fork definition; FMemory is structural backend | `Fork N/A` source audit; do not create a link-time call | document deliberate fork boundary; active allocation tests use `asAllocMem`/`asFreeMem` and `asCMemoryMgr` |
| `asAllocMem` / `asFreeMem` | FMemory-backed process allocator gateway | allocate/write/read/free and zero/boundary-size behavior | every successful allocation freed in same scope |
| default native message collector | current global fallback helper | remove from new support path | every test owns a collector; audit forbids fallback use |

## Rules

- Process-global setters with no getter/restore surface are not called by in-process SDK automation.
- A `Fork N/A` disposition is explicit coverage accounting, not a passing runtime claim.
- An isolated child-process harness is out of scope unless later evidence proves it is required and the OpenSpec is updated first.
- Tests that create worker threads must join them and clean worker TLS before the assertion scope exits.
- Tests must not rely on execution order, suite order, or another test restoring state.
- The complete static audit rejects calls to the prohibited global setters/unprepare path inside `AngelScriptSDK` tests.
