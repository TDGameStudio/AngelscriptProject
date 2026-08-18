## ADDED Requirements

### Requirement: Typed semantic IR capture is explicit and function-owned

The maintained AngelScript compiler SHALL optionally attach one compiler-owned typed semantic HIR to each successfully source-compiled script function, and SHALL keep capture disabled unless a host explicitly requests it before compilation.

#### Scenario: Ordinary compilation does not retain HIR

- **WHEN** an engine compiles source without enabling typed semantic IR capture
- **THEN** script compilation and bytecode generation proceed through the existing path
- **AND** compiled functions do not retain typed semantic HIR

#### Scenario: TypedASTJIT generation retains HIR

- **WHEN** a generation-only Engine is created for Static BackendId `"typed-ast"` before compiling source
- **THEN** the compiler captures a typed semantic HIR for each successfully compiled script function
- **AND** the HIR is available before the module invokes final StaticJIT output generation

#### Scenario: Late TypedASTJIT selection cannot reconstruct HIR

- **WHEN** a target function was source-compiled with typed HIR capture disabled and a later output-generation request selects `"typed-ast"`
- **THEN** the complete generation fails with `CaptureProfileMismatch`
- **AND** it does not reconstruct typed HIR from parser nodes, semantic-observer events, or bytecode
- **AND** neither the backend nor low-level output generation triggers a hidden recompile or silently emits BytecodeJIT output

#### Scenario: Failed compilation does not publish partial HIR

- **WHEN** a function has a script compilation error or its provisional HIR fails internal verification
- **THEN** the function does not expose a consumable partial HIR
- **AND** the normal compiler diagnostic and bytecode failure behavior remain authoritative

#### Scenario: Function destruction releases HIR

- **WHEN** a script function or module is destroyed or replaced
- **THEN** its typed semantic HIR is destroyed with the function-owned script data
- **AND** consumers cannot retain HIR node or symbol references across that replacement

#### Scenario: Raw parser AST is never retained

- **WHEN** the local parser finishes compiling a function statement block
- **THEN** parser-owned `asCScriptNode` and parser-memory-stack lifetime remain unchanged
- **AND** only the independently allocated verified typed HIR may be attached to function-owned script data

### Requirement: Typed semantic IR preserves resolved structured semantics

The typed semantic HIR SHALL represent function-local symbols, exact resolved types, expression evaluation order, structured statements, source spans, and resolved call targets without requiring a consumer to inspect VM bytecode.

#### Scenario: Supported scalar function has a complete structured body

- **WHEN** a captured function uses parameters, scalar or enum locals, literals, assignments, conversions, unary or binary operations, short-circuit logical operators, supported calls, if/else, for, while, do-while, switch, break, continue, and return
- **THEN** the HIR contains an ordered structured representation of those statements and expressions
- **AND** every value-producing expression records its exact compiler-resolved `asCDataType`
- **AND** every local or parameter reference resolves to a stable function-local symbol identity
- **AND** each loop retains its ordered phases and every break/continue retains its verified lexical target statement

#### Scenario: Resolved call retains frontend decision

- **WHEN** overload resolution selects a script function, constructor, or registered system function for a call expression
- **THEN** the HIR call node records that exact resolved target kind/coordinate, source argument roles, formal bindings, authoritative evaluation sequence, argument/result types, and source provenance
- **AND** an AOT consumer does not repeat overload resolution from declaration text

#### Scenario: Expression identity survives compiler context rewrites

- **WHEN** the compiler clears, copies, merges, converts, assigns, calls, or short-circuit-composes `asCExprContext` values while HIR capture is enabled
- **THEN** each live final value carries the HIR expression identity corresponding to its resolved semantics
- **AND** cleared or discarded values carry no reusable expression identity
- **AND** the resulting HIR preserves nested evaluation order without influencing bytecode compilation

#### Scenario: Compiler-synthesized function follows the same publication rule

- **WHEN** the compiler creates a default constructor, destructor, factory, accessor, lambda, or another synthesized script function
- **THEN** capture either publishes one complete verified function HIR or records a deterministic unsupported disposition
- **AND** no synthesized function exposes a partially captured HIR

#### Scenario: Deferred syntax remains explicit

- **WHEN** a captured valid function contains a form outside the initial HIR contract, including ternary expressions, object/property access, references, handles, containers, lambdas, managed cleanup, or actual resumable suspend state exposed by the maintained compiler/context
- **THEN** the HIR contains a typed unsupported marker with category and source span
- **AND** the compiler still produces normal bytecode when the source is otherwise valid
- **AND** ordinary `asBC_SUSPEND` line/loop polling instructions are represented as source/safe-point roles rather than resumable state while the maintained `Suspend()` API returns `asERROR`

### Requirement: Typed semantic IR makes transfer, mutation, and safe-point semantics explicit

The typed semantic HIR SHALL retain enough compiler-resolved information to lower structured transfers and scalar mutations exactly once without reconstructing bytecode labels or relying on C++ expression-order rules, and SHALL preserve source/safe-point roles needed to classify execution instrumentation.

#### Scenario: Break and continue name the nearest legal target

- **WHEN** capture observes a `break` or `continue` in nested loops and switches
- **THEN** the transfer node records the stable target statement ID selected by the compiler's lexical control stack
- **AND** `continue` may target only the nearest enclosing for/while/do-while, while `break` may also target the nearest enclosing switch
- **AND** a dangling, non-ancestor, wrong-kind, or skipped-nearer target fails verification with `InvalidControlTarget`

#### Scenario: Continue preserves loop phase

- **WHEN** HIR captures for, while, and do-while bodies containing continue
- **THEN** each loop records its ordered initializer, condition, body, and applicable increment phases
- **AND** lowering can prove that for-continue runs increment then condition, while-continue reevaluates condition, and do-while-continue reaches the trailing condition

#### Scenario: Transfer records exited scopes

- **WHEN** a break, continue, or return exits one or more lexical scopes
- **THEN** the HIR/control plan identifies the exited scopes and cleanup requirements before lowering
- **AND** absence of managed cleanup is represented explicitly rather than inferred from emitted C++ braces

#### Scenario: Switch preserves maintained semantic edges

- **WHEN** capture observes a supported integral or enum switch
- **THEN** HIR records the compiler-selected 32-bit selector normalization, ordered constant cases, case scopes, fallthrough/default disposition, and enum exhaustiveness
- **AND** an exhaustive enum switch without default records the invalid-value script-exception edge
- **AND** case value/type/duplicate/default-last decisions remain compiler authority rather than emitter inference

#### Scenario: Compound assignment evaluates storage once

- **WHEN** the compiler resolves primitive assignment or compound assignment
- **THEN** the HIR records target/address identity, old-value read when required, RHS, exact operator/conversions, authoritative evaluation sequence, result, and one final store
- **AND** the target and RHS each occur exactly once
- **AND** assignment and compound order are not replaced by the ordinary eager-binary order

#### Scenario: Prefix and postfix retain distinct results

- **WHEN** the compiler resolves primitive prefix or postfix increment/decrement
- **THEN** HIR records one mutable target evaluation and one mutation
- **AND** prefix exposes the updated result while postfix exposes a copied old value
- **AND** verifier failure prevents emission when old/result/store identities are inconsistent

#### Scenario: Power retains selected conversion shape

- **WHEN** the compiler accepts float/double power and converts an integral exponent to its selected 32-bit form
- **THEN** HIR records the converted exponent and final operand/result types
- **AND** an emitter cannot call a host power overload using the unconverted source type
- **AND** compiler-rejected integer power is not represented as an eligible executable expression

#### Scenario: Source point and safe-point roles are preserved

- **WHEN** capture observes function entry, effectful/throwing operations, calls, loop entry/backedges, continue paths, switch invalid-value edges, or returns
- **THEN** HIR retains the processed source point and semantic safe-point role independently of output instrumentation
- **AND** it does not assume every source span is a VM-equivalent line callback event

### Requirement: HIR makes failure and cleanup edges explicit

Typed semantic HIR SHALL identify every operation that may set script exception state, SHALL give it an explicit failure successor, and SHALL associate normal and exceptional scope exits with verified cleanup plans. Lifetime plans SHALL distinguish declared storage from successfully constructed live values and SHALL order destruction in reverse declaration order. The initial scalar slice SHALL require an explicitly verified empty cleanup plan rather than inferring safety from the absence of object syntax in emitted C++.

#### Scenario: Scalar failure edge has an explicit empty cleanup plan

- **WHEN** a scalar operation or call may set script exception state but no managed value is live
- **THEN** HIR records the failure successor and an empty cleanup plan
- **AND** the verifier does not treat an omitted plan as equivalent to an empty plan

#### Scenario: Lifetime slot records construction state

- **WHEN** a future HIR slice captures a local or temporary that requires destruction
- **THEN** the scope plan identifies its lifetime slot, declaration order, construction-state source and destructor disposition
- **AND** exceptional cleanup destroys only live slots, later declarations before earlier declarations, exactly once

#### Scenario: Partial construction does not destroy an unbuilt value

- **WHEN** construction of a later local or temporary fails after earlier values became live
- **THEN** the failure cleanup plan excludes the failed/unconstructed slot
- **AND** it retains reverse-order cleanup for every earlier live slot

#### Scenario: Current source-level handlers remain rejected

- **WHEN** source contains `try`, `catch`, `try` without `catch`, `catch` without `try`, or bare rethrow under the current language contract
- **THEN** normal compilation rejects the source as it does with HIR capture disabled
- **AND** HIR capture does not synthesize a handler region or turn the source into valid bytecode

#### Scenario: Dormant or future exception-region metadata fails closed

- **WHEN** compiler-internal exception-region metadata is encountered without a supported maintained source/lowering contract
- **THEN** HIR records a stable typed unsupported marker with processed source provenance
- **AND** TypedASTJIT eligibility remains false until region entry, handler, cleanup and rethrow semantics are separately specified and tested

### Requirement: Typed semantic IR normalizes function traits and effective receivers

The typed semantic HIR SHALL preserve a normalized function header derived from the authoritative compiled function shape, including known and unknown trait bits, invocation/body kind, declared parameters, effective receiver, hidden argument origins, compile-out disposition, concrete return ABI, and function/profile restrictions needed by later eligibility and entry planning. Consumers SHALL NOT infer these semantics independently from declaration text.

#### Scenario: Ordinary instance receiver is not a declared parameter

- **WHEN** the compiler captures an ordinary instance method with an `objectType`
- **THEN** the HIR represents its effective receiver as a synthetic native-object receiver symbol
- **AND** that symbol is not inserted into or counted as the method's declared parameter list
- **AND** the header preserves const, virtual/override, and invocation information required to classify later calls

#### Scenario: External implicit this aliases parameter zero

- **WHEN** a global function has `asTRAIT_EXTERNAL_IMPLICIT_THIS` and object-typed declared parameter zero
- **THEN** the HIR retains parameter zero as a normal declared parameter and records the effective receiver as an alias to that exact parameter symbol
- **AND** the parameter remains present in the VM/raw/parameter entry shape
- **AND** an HIR consumer does not reclassify the function as an instance method or synthesize a second receiver

#### Scenario: External receiver body uses explicit resolved operands

- **WHEN** an external-implicit-this body resolves explicit `this`, an unqualified field, a property accessor, or an unqualified method through parameter zero
- **THEN** the resulting HIR expression contains an explicit receiver expression referring to the aliased parameter symbol
- **AND** the resolved storage/property/function target, result type, access disposition, and source span are retained
- **AND** local, parameter, or normal-scope name shadowing selected by the compiler remains authoritative

#### Scenario: Malformed external receiver fails HIR verification safely

- **WHEN** an external receiver header has no parameter zero, a non-object parameter zero, a dangling receiver symbol, a mismatched parameter index, or a receiver type inconsistent with the parameter symbol
- **THEN** HIR verification reports a stable invalid-effective-receiver code
- **AND** no TypedASTJIT consumer can publish C++ from that HIR
- **AND** this validation does not silently change the normal frontend's source-compilation diagnostic policy

#### Scenario: Mixin receiver and external implicit this remain distinct

- **WHEN** the compiler resolves a method-syntax call to a global `mixin` function
- **THEN** the call HIR records the source receiver once, maps it to the target's real formal parameter zero, and records its independent position in the authoritative evaluation sequence
- **AND** the target function body does not acquire an external implicit `this` unless it independently has that validated trait

#### Scenario: Unknown future trait fails closed

- **WHEN** a captured function contains a trait bit unknown to the current normalized HIR implementation
- **THEN** the raw bit remains visible in the deterministic diagnostic snapshot
- **AND** the function receives a deterministic unsupported-function-trait disposition
- **AND** TypedASTJIT generation does not ignore the bit and assume ordinary global semantics

### Requirement: Resolved calls preserve compiler rewrites and argument origins

The typed semantic HIR SHALL record the compiler's final call/value semantics after overload selection, mixin receiver mapping, named/default/hidden argument handling, determines-output-type resolution, and compile-out rewrites. It SHALL represent source roles, effective formal bindings, and authoritative evaluation sequence separately and SHALL NOT assume that source order, formal order, receiver order, and execution order are identical.

#### Scenario: Ordinary call preserves reverse argument evaluation

- **WHEN** the maintained compiler resolves an ordinary three-argument call whose formal arguments are `0`, `1`, and `2`
- **THEN** the HIR formal-binding table maps each formal to its selected expression
- **AND** the HIR evaluation sequence records arguments `2`, `1`, and `0` in the maintained fork's execution order
- **AND** no consumer may replace that sequence with a generic left-to-right rule

#### Scenario: Method receiver position is explicit

- **WHEN** a method, constructor, index expression, call chain, or member/index chain has effectful receiver and argument expressions
- **THEN** the HIR evaluation sequence records the exact compiler-selected position of the receiver and every argument
- **AND** each effectful input occurs exactly once

#### Scenario: Default argument preserves declaration and call-site provenance

- **WHEN** `CompileDefaultAndNamedArgs()` instantiates a callee default expression while compiling a caller
- **THEN** its formal binding records `Default`, the callee declaration/parameter origin, and the resulting typed expression
- **AND** its diagnostic provenance also retains the caller processed-source span used by the compiler
- **AND** the expression occupies the compiler-selected position in the evaluation sequence

#### Scenario: Invalid call sequence fails verification

- **WHEN** a resolved call omits an effectful receiver/argument, evaluates one twice, contains a dangling expression, duplicates a formal index, or disagrees with its receiver/formal mapping
- **THEN** HIR verification reports `InvalidCallEvaluationSequence` or the more specific stable verifier code
- **AND** no TypedASTJIT consumer may emit the call

#### Scenario: Compile-out entirely produces no executable call

- **WHEN** a selected function has `CompileOutEntirely`
- **THEN** the HIR represents the final void/erased expression and optional diagnostic provenance
- **AND** it does not expose an executable resolved-call node that an emitter could invoke

#### Scenario: Replace with first parameter preserves one evaluation

- **WHEN** a selected function has `ReplaceWithFirstParam`
- **THEN** the HIR final value is the compiler-selected first source argument expression
- **AND** that expression appears once in evaluation order
- **AND** a TypedASTJIT emitter does not also call the replaced function

#### Scenario: Hidden WorldContext is not a receiver

- **WHEN** a function hides a formal through `hiddenArgumentIndex` and supplies a host/default WorldContext expression
- **THEN** the call HIR distinguishes the hidden argument origin from source-visible/default arguments and from the effective receiver
- **AND** the effective formal/ABI order still includes the hidden argument at its declared index

#### Scenario: Determines-output-type records the concrete result

- **WHEN** `determinesOutputTypeArgumentIndex` causes the compiler to specialize a call's result type
- **THEN** the HIR call expression records the final concrete `asCDataType`
- **AND** a consumer does not overwrite it with the target's unspecialized declaration return type

#### Scenario: Native ABI-only context remains explicit

- **WHEN** a registered native call requires a call-convention object, script-function-first value, generic-call context, user data, or another ABI-only input not written as an AS parameter
- **THEN** the resolved call plan records that requirement separately from source and declared parameters
- **AND** direct native emission is forbidden unless the external-call descriptor proves an equivalent ABI/linkage route

### Requirement: HIR preserves global, binding, dependency, and source provenance

The typed semantic HIR SHALL retain sufficient origin and target-kind information for the host to distinguish folded global constants, mutable global storage, global initializer bodies, concrete functions, imported binding slots, shared/external body ownership, and generated/preprocessed source. It SHALL NOT persist engine-local pointers or misrepresent processed source offsets as authored source offsets.

#### Scenario: Folded pure global constant retains origin

- **WHEN** the compiler folds a primitive or enum `isPureConstant` global into a scalar value
- **THEN** the resulting HIR value retains a `FoldedGlobalConstant` origin and engine-local global coordinate
- **AND** a consumer can reconcile that use with the compiler's hard-value dependency
- **AND** the value is not represented as an origin-free literal

#### Scenario: Mutable global remains an explicit storage use

- **WHEN** a captured function reads or writes a mutable global
- **THEN** the HIR records a global-storage use and the exact read/write expression semantics
- **AND** an unsupported backend can return `UnsupportedGlobalStorage` instead of guessing a C++ address

#### Scenario: Global initializer has a distinct body kind

- **WHEN** `CompileGlobalVariable()` compiles a global initializer into an anonymous script function
- **THEN** HIR capture identifies it as a global-initializer body rather than an ordinary global function or UFUNCTION root
- **AND** absence of a stable initializer invocation/lifecycle contract produces `UnsupportedGlobalInitializer` rather than provider publication

#### Scenario: Imported call retains binding-slot semantics

- **WHEN** a resolved call targets `asFUNC_IMPORTED`
- **THEN** HIR records imported source module, canonical signature, and the engine-local binding-slot coordinate
- **AND** it does not replace the slot with the current mutable `boundFunctionId` as a concrete callee body

#### Scenario: Shared or external declaration does not imply body ownership

- **WHEN** a function/type is reused through shared or external declaration semantics
- **THEN** HIR/header metadata keeps declaration identity, body availability/owner, and calling module distinct
- **AND** a consumer cannot emit a body merely because the current module can resolve the declaration

#### Scenario: TypedASTJIT semantic use is covered by compiler dependency

- **WHEN** a host derives a semantic-use manifest from verified HIR
- **THEN** every type, function, property, global storage, and folded hard-value use has a compatible entry in the same compilation's authoritative artifact dependencies
- **AND** extra authoritative compiler dependencies remain preserved
- **AND** missing or incompatible coverage produces `SemanticDependencyMismatch` without consulting bytecode

#### Scenario: Generated source uses honest provenance

- **WHEN** a HIR node comes from preprocessor-rewritten or generated source
- **THEN** it always retains the processed section/range consumed by the compiler
- **AND** it records authored or generated origin only when a reliable mapping/anchor is available
- **AND** diagnostics fall back to processed provenance rather than presenting it as an authored-file offset

### Requirement: HIR capture does not alter VM compilation or persistence

Enabling typed semantic HIR capture SHALL NOT change generated bytecode, bytecode debug/dependency metadata, script execution behavior, or the serialized AngelScript bytecode and current Cache V2 function-artifact schemas.

#### Scenario: Capture-on and capture-off bytecode are identical

- **WHEN** the same source and engine configuration are compiled once with HIR capture disabled and once with capture enabled
- **THEN** the resulting function bytecode and maintained compiler metadata are byte-for-byte equivalent
- **AND** VM execution produces the same observable result

#### Scenario: Current persisted artifacts do not serialize HIR

- **WHEN** a module containing captured HIR is saved through the current Cache V2 function-artifact writer or AngelScript `SaveByteCode`
- **THEN** no HIR nodes, source body, or HIR-specific references are written to the archive
- **AND** capture-on and capture-off archives for the same stable module identity are byte-for-byte equal
- **AND** the removed legacy `PrecompiledScript*.Cache` format remains without a production reader, writer, migration, or dual-write path

#### Scenario: Bytecode-only load has no HIR

- **WHEN** a runtime loads a function only from precompiled bytecode without compiling its source
- **THEN** that function has no typed semantic HIR
- **AND** a low-level TypedASTJIT request reports missing HIR, while orchestration that mismatched the whole capture profile fails with `CaptureProfileMismatch`

### Requirement: Typed semantic IR has deterministic read-only inspection

The compiler fork SHALL provide a deterministic, fork-private read-only traversal and text dump for typed semantic HIR without adding a stable public IR ABI to `angelscript.h`.

#### Scenario: Repeated compilation produces stable dump

- **WHEN** identical source is compiled twice with identical declarations and capture settings
- **THEN** the normalized HIR dump orders symbols and nodes deterministically
- **AND** the dumps are identical without using process pointer values as identity

#### Scenario: Diagnostics map nodes to source

- **WHEN** a consumer reports an HIR node, unsupported marker, or validation failure
- **THEN** the report includes the script section and source range needed to derive a human-readable row and column

#### Scenario: Public AngelScript ABI remains unchanged

- **WHEN** UE or Standalone consumes typed semantic HIR in this version
- **THEN** it includes the maintained private frontend model
- **AND** no `asITypedSemanticFunction` interface or equivalent public accessor is added to `angelscript.h`

### Requirement: HIR test snapshots are deterministic diagnostics and never compiler inputs

The maintained compiler SHALL expose fork-private test inspection that can normalize verified function HIR as text and JSON for tests and diagnostics. Snapshot output SHALL be non-authoritative, non-persistent, and MUST NOT be loaded as HIR, bytecode, TypedASTJIT input, or a substitute for source compilation.

#### Scenario: Compiler test helper owns an isolated source compilation

- **WHEN** a native compiler or Standalone test requests an HIR snapshot
- **THEN** a test-owned `asCScriptEngine` enables capture before compiling the fixture source
- **AND** the helper returns capture/verifier diagnostics plus normalized text and/or JSON without invoking StaticJIT, Provider packaging, or Unreal reflection

#### Scenario: Snapshot formats are deterministic

- **WHEN** the same source, declarations, concrete profile, and capture settings are inspected repeatedly
- **THEN** text and JSON outputs use stable symbol/node ordering, stable IDs, and normalized source provenance
- **AND** neither format contains process pointers, Engine-local numeric identity presented as stable identity, timestamps, or nondeterministic output paths

#### Scenario: Unsupported valid source remains inspectable

- **WHEN** valid source compiles to bytecode and its HIR contains a deterministic unsupported marker for the first TypedASTJIT slice
- **THEN** the test snapshot succeeds and includes the marker and source provenance
- **AND** it does not run BytecodeJIT fallback or claim a StaticJIT artifact

#### Scenario: Invalid HIR fails the snapshot

- **WHEN** normal source compilation succeeds but the provisional HIR fails verification
- **THEN** the test inspection reports the deterministic verifier failure and does not publish a normalized successful snapshot for that function
- **AND** the valid bytecode result remains unchanged

#### Scenario: Dump files are never read back

- **WHEN** `.hir.txt` or `.hir.json` files exist from an earlier test/developer dump
- **THEN** a later compiler or TypedASTJIT request ignores those files and obtains HIR only from its own source compilation
- **AND** deleting or modifying the dump files cannot affect generated bytecode, eligibility, C++ output, Provider identity, or runtime execution

### Requirement: Sparse semantic observations remain independent

The existing `asISemanticObserver` event contract SHALL continue to operate independently of typed semantic HIR capture and SHALL NOT be treated as the storage or reconstruction format for function HIR.

#### Scenario: Observer works without HIR capture

- **WHEN** a host installs `asISemanticObserver` while typed HIR capture is disabled
- **THEN** resolved-call, constructor, assignment, and constant-string observations continue to be delivered as before

#### Scenario: Observer and HIR coexist

- **WHEN** a host enables both semantic observations and typed HIR capture
- **THEN** both outputs reflect the same compiler-resolved targets and types for their overlapping events
- **AND** disabling either output does not alter the other output or generated bytecode
