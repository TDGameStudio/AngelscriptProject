## ADDED Requirements

### Requirement: Tool execution uses caller-owned bounded runners
The Runtime SHALL expose a reflected transient AngelScript tool runner that is created and retained explicitly by the caller, SHALL cap each runner at 256 live sessions, and SHALL NOT create a global runner, tool subsystem, registry or directory scan.

#### Scenario: Caller creates and retains a runner
- **WHEN** a C++, AngelScript or Blueprint caller creates a runner with a valid owner and retains it through a reflected strong reference
- **THEN** the runner SHALL remain available for repeated tool execution until the caller releases it
- **AND** the plugin SHALL NOT register the runner in a global collection

#### Scenario: Invalid owner is rejected
- **WHEN** a caller requests a runner without a valid owner
- **THEN** creation SHALL fail without falling back to an engine-wide owner or singleton

#### Scenario: Releasing a runner ends its sessions
- **WHEN** no strong reference to a runner or its tool instances remains
- **THEN** the runner and its transient session instances SHALL be eligible for normal UObject garbage collection
- **AND** release SHALL NOT promise synchronous destruction or a script cleanup callback

#### Scenario: Runner session limit is reached
- **WHEN** a runner already owns 256 sessions and a call would create a different session
- **THEN** the runner SHALL reject the call as `InvalidRequest` without constructing another tool object
- **AND** resetting an existing session SHALL make capacity available again

#### Scenario: User tools are not discovered
- **WHEN** project or plugin script roots contain classes derived from the tool base
- **THEN** the runner SHALL NOT scan, list, register or automatically instantiate those classes

### Requirement: Tool classes expose a bounded synchronous reflected contract
The Runtime SHALL expose an abstract reflected tool UObject whose `Run` event receives a session key, optional ContextObject and empty-or-object JSON arguments and returns a success flag, message and empty-or-object JSON payload.

#### Scenario: C++ AS and Blueprint share one invocation shape
- **WHEN** a native, generated AngelScript or Blueprint class derives from the tool base
- **THEN** it SHALL implement or inherit the same synchronous reflected `Run` event
- **AND** callers SHALL invoke it through the same runner result contract

#### Scenario: Valid structured response succeeds
- **WHEN** a tool returns success with an optional message and an empty or valid JSON-object payload
- **THEN** the runner SHALL return `Succeeded` with that message and payload
- **AND** include the stable session identifier used for the dispatch

#### Scenario: Tool reports failure
- **WHEN** a tool completes normally but returns a false success flag
- **THEN** the runner SHALL return `ToolFailed`
- **AND** preserve the tool's message and valid payload

#### Scenario: Invalid arguments are rejected before dispatch
- **WHEN** non-empty invocation arguments are not a valid JSON object or exceed 1 MiB of UTF-8
- **THEN** the runner SHALL return `InvalidRequest`
- **AND** SHALL NOT create or invoke the tool instance

#### Scenario: Invalid response is rejected
- **WHEN** the tool returns a non-empty payload that is not a valid JSON object, a payload over 1 MiB of UTF-8, or a message over 64 KiB of UTF-8
- **THEN** the runner SHALL return `InvalidResponse`

#### Scenario: Script exception is distinguished from tool failure
- **WHEN** AngelScript execution throws while dispatching the tool event
- **THEN** the runner SHALL return `ExecutionException`
- **AND** SHALL NOT report a default or partial return value as success
- **AND** SHALL detect the reflected execution result directly rather than infer failure by scraping logs

### Requirement: Tool sessions use stable runner-scoped identities
Each runner SHALL reuse one logical session for the same stable tool-class path and normalized session key, SHALL return that identity as `FAngelscriptToolSessionId`, and SHALL isolate sessions across different runners, classes and keys.

#### Scenario: Repeated run reuses the instance
- **WHEN** the same runner executes the same tool class and session key more than once without structural reload or reset
- **THEN** each execution SHALL use the same physical tool UObject
- **AND** state written by an earlier execution SHALL be observable by a later execution

#### Scenario: Empty key selects the default session
- **WHEN** the caller supplies `NAME_None` as the session key
- **THEN** the runner SHALL normalize it to the stable `Default` session
- **AND** return the normalized key in the SessionId

#### Scenario: Runners and keys remain isolated
- **WHEN** calls differ by runner, exact tool-class path or normalized session key
- **THEN** they SHALL NOT share a tool instance
- **AND** this reuse contract SHALL NOT be described as a process singleton

#### Scenario: Exact session reset creates fresh state
- **WHEN** the caller resets a returned SessionId and then runs the same class and key again
- **THEN** the old instance SHALL NOT be reused
- **AND** a fresh transient instance SHALL execute

#### Scenario: Renamed class session remains resettable
- **WHEN** a tool class is renamed or removed after its SessionId was returned
- **THEN** the caller SHALL be able to reset the old entry by that exact SessionId without resolving the old UClass

#### Scenario: Reset all clears only the caller's runner
- **WHEN** the caller resets all sessions on one runner
- **THEN** every session owned by that runner SHALL be removed
- **AND** sessions on other runners SHALL remain unchanged

#### Scenario: Same-session recursive execution is busy
- **WHEN** a tool synchronously invokes the same runner and SessionId while that session is already running
- **THEN** the nested call SHALL return `Busy`
- **AND** the outer execution and retained instance SHALL remain valid

#### Scenario: Off-thread execution is rejected
- **WHEN** a caller invokes the runner outside the Game Thread
- **THEN** the request SHALL return `InvalidRequest` without dispatching script code

### Requirement: Invocation ContextObject scopes AngelScript world resolution
The Runtime runner SHALL enter the current AngelScript engine scope with the invocation's valid non-null ContextObject for the complete reflected dispatch and SHALL restore the previous engine/world context on every exit path.

#### Scenario: Explicit ContextObject becomes ambient WorldContext
- **WHEN** a tool runs with a valid ContextObject that resolves to a World
- **THEN** existing AngelScript bindings that query the current WorldContext SHALL observe that context during `Run`
- **AND** `UAngelscriptTool::GetWorld()` SHALL return that same resolved World during `Run`
- **AND** generated instance-method dispatch setting the receiver as ambient context SHALL bridge through the tool's call-scoped ContextObject rather than recurse through itself
- **AND** the previous context SHALL be restored after the call

#### Scenario: Null ContextObject does not guess a World
- **WHEN** an invocation has no ContextObject
- **THEN** the runner SHALL NOT derive one from its Owner, `GEditor`, PIE, GameInstance or another implicit global
- **AND** `UAngelscriptTool::GetWorld()` SHALL return null during that dispatch
- **AND** `UAngelscriptTool::GetWorld()` SHALL NOT implement an independent Editor/PIE fallback search

#### Scenario: Context does not define session identity
- **WHEN** the same runner, class and SessionKey are executed with different ContextObjects
- **THEN** the logical tool session SHALL be reused
- **AND** each individual dispatch SHALL observe its own explicit ContextObject

#### Scenario: Invalid ContextObject is rejected
- **WHEN** an invocation supplies a pending-kill or otherwise invalid ContextObject
- **THEN** the runner SHALL return `InvalidRequest` without invoking the tool

### Requirement: Editor compilation and execution are separate explicit operations
The Editor module SHALL expose stateless compile-only, run-compiled and compile-and-run operations for caller-supplied full AngelScript source while Runtime execution of normal already-loaded classes remains available directly through the runner.

#### Scenario: Compile-only does not create a session
- **WHEN** `CompileToolSource` successfully compiles and resolves a valid tool class
- **THEN** it SHALL return the resolved and active class metadata
- **AND** SHALL NOT create a runner, create a tool instance or dispatch `Run`

#### Scenario: Compiled tool runs repeatedly without recompiling
- **WHEN** `RunCompiledTool` is called repeatedly with a runner, stable SourceId, exact ToolClassName and invocations
- **THEN** it SHALL resolve the currently active exact class from that Tool module and dispatch it through the supplied runner
- **AND** it SHALL NOT preprocess or compile source as part of those calls

#### Scenario: Compile-and-run composes successful operations
- **WHEN** `CompileAndRunSource` successfully compiles and resolves the attempted source
- **THEN** it SHALL run that successful attempted class through the supplied runner
- **AND** return both compile and run results

#### Scenario: Compile-and-run stops after attempted compile failure
- **WHEN** the submitted source fails preprocessing, compilation or attempted class validation
- **THEN** `CompileAndRunSource` SHALL NOT dispatch the attempted source or the previous active class
- **AND** the caller MAY explicitly use `RunCompiledTool` to run a reported last-known-good class

#### Scenario: Runtime already-loaded class requires no Editor adapter
- **WHEN** a Debug, DebugGame or Development Runtime caller has an already-loaded concrete tool class
- **THEN** it SHALL be able to call the Runtime runner directly
- **AND** no Editor source or history API SHALL be required

### Requirement: Editor tool source uses stable bounded memory identity
The Editor source operations SHALL validate a bounded SourceId and full source before compiling under a stable Tool memory virtual path.

#### Scenario: Stable SourceId compiles
- **WHEN** a caller supplies SourceId `MyPlugin/FixMaterials`, valid full source and the exact tool class name
- **THEN** the source SHALL compile as `/Angelscript/Memory/Tools/MyPlugin/FixMaterials.as`
- **AND** its module name SHALL be `Angelscript.Memory.Tools.MyPlugin.FixMaterials`

#### Scenario: SourceId is validated before access
- **WHEN** SourceId is empty, exceeds 160 characters, contains a segment over 64 characters, an empty segment, extension, dot segment, backslash, leading/trailing slash or a character outside ASCII letters, digits, `_` and `-`
- **THEN** the Editor entry SHALL return `InvalidRequest`
- **AND** SHALL NOT preprocess, compile, run or access Tool History

#### Scenario: Oversized source is rejected
- **WHEN** submitted source exceeds 1 MiB of UTF-8
- **THEN** the Editor entry SHALL return `InvalidRequest` before preprocessing or persistence

#### Scenario: Tool class name and source body are validated
- **WHEN** ToolClassName is empty, exceeds 128 characters, is qualified, is not an ASCII identifier, or SourceText is empty after trimming
- **THEN** the Editor entry SHALL return `InvalidRequest` before preprocessing, compilation, execution or history access

#### Scenario: Compile diagnostics are bounded
- **WHEN** preprocessing or compilation emits more than 512 scoped diagnostics or a diagnostic message exceeds 64 KiB of UTF-8
- **THEN** the result SHALL return the bounded diagnostic prefix and set `bDiagnosticsTruncated=true`
- **AND** Tool History SHALL persist only that same bounded view

#### Scenario: Compile is rejected during active execution
- **WHEN** any Runtime tool session is executing on the Game Thread call stack
- **THEN** every Editor compile operation SHALL return `Busy`
- **AND** SHALL NOT begin a Full Reload inside the active dispatch stack

#### Scenario: Repeated SourceId updates one module
- **WHEN** a caller repeatedly submits source with the same canonical SourceId
- **THEN** every compile SHALL address the same virtual path and module identity
- **AND** the plugin SHALL NOT create a runnable tool registration or module-history entry

#### Scenario: Source modules are not automatically unloaded
- **WHEN** a caller stops using a SourceId, resets its runner session or forgets its Saved history
- **THEN** v1 SHALL NOT promise to unload the generated source module or class
- **AND** caller documentation SHALL require a bounded reusable set of SourceIds

### Requirement: Editor class resolution is exact and reports last-known-good state
Editor source operations SHALL resolve tool classes only inside the exact Tool module and SHALL separately report the attempted compile outcome and any previous active class that remains published.

#### Scenario: Class resolution is limited to the Tool module
- **WHEN** the requested ToolClassName is not present in the module for the supplied SourceId
- **THEN** the result SHALL be `ToolClassNotFound`
- **AND** a global class with the same name SHALL NOT be used as fallback

#### Scenario: Wrong class kind is rejected
- **WHEN** the exact class is abstract, deprecated or not derived from the tool base
- **THEN** the result SHALL be `InvalidToolClass`
- **AND** a compile-and-run call SHALL NOT create a session

#### Scenario: Compile failure returns scoped diagnostics
- **WHEN** preprocessing or compilation fails
- **THEN** the result SHALL be `CompileFailed`
- **AND** include diagnostics with virtual path, severity, message, row and column
- **AND** SHALL NOT invoke or reset any runner session

#### Scenario: Failed update reports active last-known-good class
- **WHEN** updated source fails and an exact previously published valid class remains active for the same SourceId and ToolClassName
- **THEN** the result SHALL report that ActiveToolClass and `bHasLastKnownGood=true`
- **AND** report its revision identifier when that successful revision is known to Tool History

#### Scenario: First failure has no last-known-good class
- **WHEN** a SourceId has no previously published exact valid class and its attempted source fails
- **THEN** the result SHALL report no ActiveToolClass and `bHasLastKnownGood=false`

#### Scenario: Run-compiled revalidates the active class
- **WHEN** `RunCompiledTool` is called after any reload or historical revision load
- **THEN** it SHALL resolve and validate the current exact class from the active Tool module rather than trust a persisted or stale UClass pointer

### Requirement: Tool state follows existing reload boundaries
The tool runner SHALL preserve logical sessions according to existing Editor and packaged Runtime reload contracts rather than implementing an independent UObject-state migration mechanism.

#### Scenario: Editor code-only update preserves the physical object
- **WHEN** Editor recompiles the same tool class with body-only changes
- **THEN** a retained session SHALL continue using its existing physical tool UObject
- **AND** subsequent execution SHALL run updated code with existing state

#### Scenario: Editor compatible structural update preserves the logical session
- **WHEN** Editor Full Reload reinstantiates the same tool class after a compatible structural change
- **THEN** the same SessionId SHALL continue to identify the logical session
- **AND** references held in the runner's reflected session storage SHALL be fixed up to the replacement object
- **AND** compatible reflected `UPROPERTY` state SHALL migrate through the existing reinstancing path

#### Scenario: Non-reflected state is not promised across structural reload
- **WHEN** a structural reload replaces a tool UObject
- **THEN** raw fields, non-reflected caches, delegate registrations and external resources SHALL NOT be claimed as migrated

#### Scenario: Incompatible identity does not imply migration
- **WHEN** the tool class is renamed, removed or changed incompatibly
- **THEN** the runner SHALL NOT claim that the old session migrated to the new identity
- **AND** the caller SHALL be able to reset the old SessionId or release the owning runner

#### Scenario: Failed Editor compile keeps the previous logical session
- **WHEN** updated memory source fails to compile
- **THEN** the failed version SHALL NOT run
- **AND** the runner SHALL NOT automatically delete the previous successful session

#### Scenario: Development structural reload requires restart
- **WHEN** packaged Development reload detects a structural tool-class change
- **THEN** the existing Runtime reload API SHALL report `RequiresRestart`
- **AND** the tool runner SHALL NOT bypass that result or attempt Editor-style reinstancing

### Requirement: Tool execution is disabled in restricted builds
The reflected Runtime tool types SHALL remain build-compatible in all target configurations, while runner execution SHALL fail closed in Test and Shipping builds.

#### Scenario: Development executes an already-loaded class
- **WHEN** Debug, DebugGame or Development Runtime supplies an already-loaded concrete tool class
- **THEN** the runner SHALL execute it according to the normal session contract
- **AND** SHALL NOT dynamically compile source as part of that call

#### Scenario: Test and Shipping reject execution
- **WHEN** Test or Shipping code calls the runner
- **THEN** it SHALL return `DisabledByBuild` before constructing or invoking a tool
- **AND** the reflected tool, session, invocation and result types SHALL remain available for compilation and reflection

#### Scenario: Non-Editor source compilation is unavailable
- **WHEN** a non-Editor caller has source text rather than an already-loaded tool class
- **THEN** this capability SHALL expose no Runtime memory-source compile or Tool History entry point

### Requirement: Stateful tool execution remains an unmanaged trusted-code surface
The capability SHALL execute with the permissions of existing AngelScript bindings and SHALL NOT claim sandboxing, deterministic cleanup, automatic transactions, remote authorization or project-tool lifecycle governance.

#### Scenario: Caller selects tool location and trigger
- **WHEN** a user authors tools in project scripts or supplies Editor memory source
- **THEN** the plugin SHALL NOT require a `Script/Tools` directory, product tool asset or fixed trigger surface

#### Scenario: No remote surface is registered
- **WHEN** the runner capability initializes or a runner is created
- **THEN** it SHALL NOT register named-pipe, network, MCP, ToolsetRegistry or DebugServer commands

#### Scenario: Tool mutations use existing permissions
- **WHEN** a trusted tool calls bound Runtime or Editor APIs
- **THEN** those calls SHALL use the existing binding and engine permission behavior
- **AND** the runner SHALL NOT advertise rollback or isolation it does not provide

#### Scenario: Reset does not guarantee external cleanup
- **WHEN** a caller resets or releases a tool session
- **THEN** the runner SHALL only release its retained UObject reference
- **AND** tools requiring deterministic delegate, latent-job or external-resource cleanup SHALL use a user-owned lifecycle service outside this synchronous contract
