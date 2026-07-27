## ADDED Requirements

### Requirement: Raw context callbacks SHALL have direct regression coverage
The suite SHALL directly test exception, instruction, fork line, fork loop-detection, and fork stack-pop callbacks through case-owned raw contexts, including installation, invocation, replacement, clearing, invalid/reentrant operations, and context reuse.

#### Scenario: A callback is installed and cleared
- **WHEN** a representative straight-line, branch, loop, nested-call, or exception script executes
- **THEN** the callback SHALL record its exact expected event sequence and user data
- **AND** replacement SHALL route events only to the new recorder
- **AND** no events SHALL occur after clearing

#### Scenario: A stack-pop callback observes frame cleanup
- **WHEN** a frame exits normally, through return, exception, or documented context cleanup
- **THEN** callback order and old-frame pointer range SHALL be valid for each frame
- **AND** the test SHALL NOT read outside the exposed frame range

### Requirement: Call-stack and source-location queries SHALL be complete across valid and invalid frames
`GetCallstackSize`, `GetFunction`, `GetBlueprintCallstackFrame`, and `GetLineNumber` SHALL be tested across global, method, virtual, imported, recursive, exception, nested-state, and invalid-frame conditions.

#### Scenario: A deep call stack is inspected
- **WHEN** execution is stopped at a callback or exception with multiple frames
- **THEN** every valid frame SHALL report the expected function identity, declaration, section, line, column, and ordering
- **AND** out-of-range indexes SHALL return the current documented invalid result without crashing

#### Scenario: Source layout changes
- **WHEN** LF, CRLF, blank/comment lines, multiple sections, or line-cue configuration changes source layout
- **THEN** live context locations and `FindNextLineWithCode` SHALL match the exact expected executable lines

### Requirement: Local-variable inspection SHALL cover type, scope, address, and frame products
`GetVarCount`, `GetVarName`, `GetVarDeclaration`, `GetVarTypeId`, `GetAddressOfVar`, and `IsVarInScope` SHALL cover primitive, value-object, automatic-reference, parameter, local, nested, loop, shadowed, caller-frame, and invalid-index cases.

#### Scenario: Locals are inspected inside nested scopes
- **WHEN** outer, inner-shadowed, and loop locals move into and out of scope
- **THEN** names, declarations, type IDs, addresses, values, and `IsVarInScope` SHALL identify the correct variable at every stop

#### Scenario: A caller frame is inspected
- **WHEN** a nested callee stops execution
- **THEN** every required query SHALL return caller parameters/locals from the requested frame
- **AND** invalid variable/frame combinations SHALL return the exact current-fork result

#### Scenario: Optimization changes debug availability
- **WHEN** equivalent functions are built with optimization and line-cue variants
- **THEN** the suite SHALL record and assert the fork's supported local metadata/address/scope behavior rather than assuming full debug retention

### Requirement: Receiver inspection SHALL distinguish global, base, derived, and invalid contexts
`GetThisTypeId` and `GetThisPointer` SHALL be tested for member, base/derived view, virtual dispatch, nested call, global, null/exception, finished, and invalid-frame states.

#### Scenario: A derived receiver is inspected through multiple views
- **WHEN** base and derived methods participate in one stack
- **THEN** each frame SHALL expose the expected declared receiver type and object pointer identity
- **AND** global/invalid frames SHALL expose the exact null/zero behavior

### Requirement: Nested context state SHALL preserve and restore the outer execution state
`PushState`, `PopState`, and `IsNested` SHALL cover nesting counts, same/different inner signatures, callbacks, exceptions, abort/suspend results, invalid pops, and restoration of the outer function, arguments, returns, exception state, stack, locals, and receiver.

#### Scenario: An inner function completes
- **WHEN** a prepared outer context pushes state and executes an inner function with a different signature
- **THEN** nesting count and inner result SHALL be correct
- **AND** pop SHALL restore every recorded outer state field before the outer function resumes

#### Scenario: An inner function fails
- **WHEN** the inner execution raises an exception or another non-finished result
- **THEN** the documented cleanup/pop sequence SHALL restore or terminate the outer state exactly
- **AND** an invalid pop at nesting zero SHALL have a deterministic error result

### Requirement: Script-function debug metadata SHALL correlate with live execution and bytecode
`asIScriptFunction` local metadata, variable declarations, next executable lines, section identity, and bytecode pointer/length SHALL be tested across function shapes, namespaces, rebuilds, optimization, and save/load.

#### Scenario: Static metadata is compared with a live frame
- **WHEN** a function with parameters, locals, shadowing, branches, and comments executes
- **THEN** static variable/line/section metadata SHALL correlate with the live context at each required stop

#### Scenario: A module is rebuilt or loaded
- **WHEN** function source or bytecode is rebuilt/saved/loaded
- **THEN** stale function identity SHALL not be used
- **AND** the new function's metadata, bytecode length/pointer contract, stack identity, and runtime result SHALL be asserted

### Requirement: Native debug tests SHALL remain inside the raw SDK boundary
Native debug coverage SHALL use raw engine/module/context APIs and fork context internals intentionally exported to the runtime module. It SHALL NOT initialize UE DebugServer, DAP, editor debugging, source navigation, or a VS Code client.

#### Scenario: Debug integration behavior is requested
- **WHEN** a scenario requires protocol messages, breakpoints managed by DebugServer, editor UI, or client transport
- **THEN** it SHALL be assigned to the existing non-SDK Debugger test layer
- **AND** it SHALL NOT be counted as raw SDK debug coverage
