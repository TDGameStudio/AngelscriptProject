## ADDED Requirements

### Requirement: Template instance intern is linearizable

`asCScriptEngine::GetTemplateInstanceType` SHALL look up `templateInstanceBuckets` under shared `engineRWLock` (or the documented intern lock). On miss it SHALL acquire exclusive ownership, re-check the bucket, create and insert the instance, and allocate any cloned script functions through `AllocateFunction` before releasing. Two threads requesting the same template-and-subtype key SHALL receive the same `asCObjectType*` and SHALL NOT insert two bucket entries.

#### Scenario: Distinct subtypes intern from two threads

- **WHEN** a template object type is already registered
- **AND** thread A requests instance subtype `int` and thread B requests instance subtype `float`
- **THEN** both calls return non-null types
- **AND** the two instances are distinct
- **AND** each subsequent lookup returns the same pointer as the first intern

#### Scenario: Same subtype intern from two threads

- **WHEN** two threads concurrently request the same template-and-subtype key
- **THEN** both receive the same `asCObjectType*`
- **AND** the bucket contains one instance for that key

### Requirement: Function slot allocation is a single locked operation

`GetNextScriptFunctionId` peek plus later `AddScriptFunction` SHALL be replaced or wrapped by one `AllocateFunction` that, under the intern lock, either reuses a `freeScriptFunctionIds` hole or appends to `scriptFunctions` and returns the reserved id. Concurrent callers SHALL never receive the same id. Hole reuse MAY remain, but only inside that lock.

#### Scenario: Two intern paths allocate functions without colliding ids

- **WHEN** two threads each intern a template instance that clones at least one method
- **THEN** the cloned functions have distinct ids
- **AND** `scriptFunctions[id]` for each id is the corresponding function after intern returns

### Requirement: Host stage3 bytecode ParallelFor is opt-in

`FAngelscriptEngine` MAY `ParallelFor` `asCBuilder::BuildCompileCode` across modules only after template intern and `AllocateFunction` are linearizable. The ParallelFor SHALL be gated by console variable `as.Compile.ParallelBytecode` defaulting to `0`. `ResetGlobalVars` / stage4 SHALL remain single-thread. Overlapping full `RequestBuild` on one engine SHALL remain forbidden. Default-off SHALL keep existing serial stage3 behavior.

#### Scenario: Cvar off preserves serial stage3

- **WHEN** `as.Compile.ParallelBytecode` is `0`
- **AND** a multi-module compile runs stage3
- **THEN** `BuildCompileCode` runs on one thread at a time
- **AND** compile results match the pre-change serial pipeline for the same sources

#### Scenario: Cvar on compiles independent modules concurrently

- **WHEN** `as.Compile.ParallelBytecode` is `1`
- **AND** two modules each compile functions that intern distinct template instances
- **THEN** both modules finish `BuildCompileCode` without duplicate template instances or colliding function ids
- **AND** `JITCompile` does not data-race module tables (serial after bytecode, or under the existing per-function JIT mutex)

### Requirement: Compile diagnostics do not data-race under parallel bytecode

When parallel bytecode is enabled, `WriteMessage` and host `bHadCompileErrors` SHALL be free of data races. `engine->preMessage` SHALL NOT be written from two bytecode workers without a lock. Per-builder `numErrors` MAY stay unsynchronized if each builder is owned by one worker.

#### Scenario: Parallel bytecode with an error in one module

- **WHEN** parallel bytecode is enabled
- **AND** one module fails to compile and another succeeds
- **THEN** the host observes a compile error
- **AND** the successful module's bytecode is not discarded because of a torn error flag
