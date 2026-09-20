## Purpose

Define independently executable AngelScript frontend stages that create private ScriptEngine TypeInfo on asCDefinitions without an Engine, while frozen HostProcess graphs may be supplied as shared dependencies.

## Requirements

### Requirement: Independent typed compilation stages

The Builder SHALL compile through explicit typed stage results without requiring an AngelScript engine, and SHALL distinguish declaration readiness, body readiness, definition freeze, and bytecode emission.

#### Scenario: Stop after declarations and resume bodies

- **WHEN** a caller collects and resolves declarations before analyzing bodies
- **THEN** signatures are inspectable while body storage remains writable by the owning compilation session

    > Observables: Resuming body analysis preserves declaration identity and uses the retained active Token stream.

- **AND** running the same stages separately or together produces equivalent semantic results and deterministic text/JSON observations
- **BUT** an invalid stage transition or failed required stage cannot publish a successful later result

#### Scenario: Compile without a host consumer

- **WHEN** a caller supplies source, immutable options, explicit type context and diagnostics without an Engine or UE reflection consumer
- **THEN** syntax, semantic definitions and layout create actual ScriptEngine TypeInfo on asCDefinitions with null Engine and TypeId -1

    Script compilation does not create runtime objects or assign its private process TypeIds. ClassGen UClass materialization remains a later host step.

- **BUT** unavailable backends remain explicit unsupported operations rather than hidden legacy fallbacks

    Stopping at DefinitionsFrozen does not require stable bytecode. Default RunThrough continues through ByteCodeEmitted.

### Requirement: Maintained language semantics survive frontend replacement
The replacement frontend SHALL preserve the maintained language's declaration, expression and statement semantics except explicitly removed syntax.

#### Scenario: Analyze supported source through the replacement

- **WHEN** supported source exercises type lookup, inheritance, overloads, expressions or control flow
- **THEN** typed nodes and resolved semantic relationships express the language result
- **AND** invalid input emits structured source diagnostics with controlled recovery rather than silently discarding tokens

    > Verification: A migration matrix maps maintained syntax and old native SDK fixtures to positive, negative and boundary tests.

### Requirement: Builder yields two takeable products

The Builder SHALL expose asCCompileOutput and private asCDefinitions as parallel products and SHALL NOT place TypeInfo, functions or bytecode inside asCCompileOutput.

#### Scenario: Take the definition set off the Builder

- **GIVEN** successful compilation through DefinitionsFrozen of a Unit class with an int32 Value field and Set(int32) method
- **WHEN** the caller takes the Builder's definitions
- **THEN** the returned UniquePtr owns Unit and its methods with null GetEngine and TypeId -1

    A second take returns null; the Builder no longer owns that graph.

- **AND** destroying that unregistered owner deletes its private objects
- **BUT** failed compilation does not yield a usable taken graph

#### Scenario: Compile a later unit against a Taken set

- **GIVEN** frozen asCDefinitions containing First from an earlier compile
- **WHEN** a second Builder compiles class Second with a First handle field using Options.Dependencies
- **THEN** Second resolves First without Engine registration while owning only Second
- **BUT** unready dependencies and cross-unit cycles are rejected

    Mutually dependent types share one snapshot. Frozen HostProcess definitions may also be dependencies; their shared ownership and preassigned IDs do not assign an Engine or runtime IDs to private script objects.

#### Scenario: CompileOutput carries ClassGen descriptors without ScriptType

- **WHEN** a caller reads or takes CompileOutput after compiling Widget
- **THEN** asCDefinitionCompileOutput contains the Widget module/class descriptors with null ScriptType and ScriptFunction
- **AND** each module descriptor's ScriptModule remains null

    CompileOutput does not construct `asCModule`. Register later fills ScriptModule.

- **BUT** that descriptor output does not own TypeInfo/bytecode and cannot replace taking the private definitions

#### Scenario: CompileOutput keeps Projected descriptors after definitions exist

- **WHEN** a caller compiles a USTRUCT with a UPROPERTY through `DefinitionsFrozen` or the default `ByteCodeEmitted` stop

    The source is `USTRUCT() struct FPoint { UPROPERTY() int X; };`.
    DefinitionsBuilt has already created private TypeInfo on `asCDefinitions`.

- **THEN** CompileOutput modules still come from `DescriptorConsumer.Project`

    `FPoint.bIsStruct` is true and `Properties` contains one entry named `X`.
    A TypeInfo name-only scan is not the CompileOutput authority.

    > Verification: NativeEngine CompileLifecycle `ProjectedUStructSurvivesDefinitionsFrozen` and `ProjectedUStructSurvivesByteCodeEmitted`.

- **AND** `ScriptType`, `ScriptFunction`, and `ScriptModule` remain null

    CompileOutput still does not own TypeInfo, bytecode, or `asCModule`.

- **BUT** taking private definitions remains a separate product

    `TakeDefinitions()` still returns the unique TypeInfo graph.

### Requirement: Default RunThrough emits stable bytecode

The Builder SHALL emit stable bytecode onto each script `asCScriptFunction` when `RunThrough` uses the default stop `ByteCodeEmitted`, using the public `asCByteCodeEmitter`.

#### Scenario: Default RunThrough includes Emit

- **WHEN** a caller constructs snapshot `asCBuilder` and calls `RunThrough()` with the default stage
- **THEN** the run includes Emit and each script function on the Taken set reports a non-empty stable bytecode view
- **BUT** native `asFUNC_SYSTEM` functions keep an empty stable body

### Requirement: Builder preserves root diagnostics and explicit stage outcomes

The Builder SHALL expose one authoritative diagnostic result across its stages, preserve already-reported causes without text rewrapping, and distinguish analyzed coverage, language validity, policy failure and publication eligibility.

#### Scenario: Propagate a semantic stage failure

- **GIVEN** declaration or body analysis has already reported a concrete diagnostic group
- **WHEN** Builder records the failed stage and a consumer reads the complete result and its stage views
- **THEN** the same root group remains available once with its ranges, semantic arguments and attached notes intact

    > Observables: A stage view identifies groups in the authoritative collection; concatenating cumulative copies is not required.
- **BUT** the failed stage does not add a first-token generic diagnostic containing serialized earlier errors

#### Scenario: Fail before lexing produces tokens

- **WHEN** an admitted compilation fails an input or environment precondition before lexing
- **THEN** the stage fails with an explicit status and a visible nonlocated root diagnostic if no earlier group explains the failure

    > Boundaries: Low-level metadata/AST status codes retain their own meaning; the boundary adds context rather than inventing a source-language error.
- **AND** no later stage is reported successful solely because the diagnostic display was empty

#### Scenario: Inspect partial analysis without publishing it

- **WHEN** recovery or cancellation leaves only a subset of requested analysis complete
- **THEN** the result identifies completed stages and available fragments independently of diagnostic display policy

    > Observables: Callers distinguish language errors, internal failure, policy-only build failure, truncation and cancelled work.
- **BUT** diagnostic continuation or a read-only tooling result does not satisfy definition freeze, AST verification or Engine registration

#### Scenario: Preserve structured emission failure

- **GIVEN** bytecode emission returns a structured failure for the admitted compilation
- **WHEN** the caller reads the Builder stage result and retained CompileOutput diagnostics
- **THEN** the original emission status, function/node identity, source/fragment identity and reported causes remain available without parsing a summary string

    A resource-limit failure remains distinguishable from unsupported lowering and invalid input. A source range is supplied only when authenticated against the retained snapshot; source-less failures do not borrow an unrelated token location.
- **BUT** the bridge neither changes lowering support nor emits a duplicate wrapper for an existing root group

#### Scenario: Reject an illegal request without poisoning compilation

- **GIVEN** earlier Builder stages completed successfully
- **WHEN** a caller requests an out-of-order stage or a backwards RunThrough
- **THEN** the request reports rejection while the accepted stage, diagnostic snapshot and compilation failure facts remain unchanged

    The caller can resume the legal sequence. Request misuse is not reclassified as a source-language error, and preserving this behavior does not hide a real failure from an admitted compilation.

### Requirement: Queued early phases finish independently before deterministic join

The Builder SHALL execute file-local Lex followed by eligible same-thread PP using a bounded worker count and batch queue, finish all queued files after a local failure, and merge results deterministically by source identity.

#### Scenario: Worker and batch counts vary

- **GIVEN** the same immutable sources, flags and lexical options
- **WHEN** WorkerCount is one or four and LexBatchSize is one or four
- **THEN** canonical lexical, PP and diagnostic products have the same source membership and ordering

    LexBatchSize defaults to four and values below one normalize to one. WorkerCount below one likewise normalizes to one. A single worker executes on the calling thread. Batch scheduling changes work assignment, not source-language interpretation.

- **BUT** equal spelling identity or output order does not depend on arrival order

#### Scenario: One lexical failure does not suppress clean-file PP

- **GIVEN** A.as has a lexical Error or hard Lex failure and B.as is lexically valid
- **WHEN** the joined early-phase attempt completes
- **THEN** A has no eligible PP product while B retains its own PP product and the overall attempt fails

    Workers continue acquiring all remaining work. PP eligibility uses the file's lexical failure facts, not a global displayed Error list. A source-acquisition failure is also a failed work item and does not discard later files.

- **AND** every retained product remains associated with its real source key and snapshot ranges
- **BUT** useful partial products do not satisfy declaration completeness or definition publication

#### Scenario: Preprocessing fails in one eligible file

- **GIVEN** A.as is lexically valid but contains a malformed conditional directive and B.as is valid
- **WHEN** each lexical worker preprocesses its eligible file
- **THEN** A retains its invalid PP disposition, B retains valid PP, and the joined attempt fails

    Failed PP does not expose valid ActiveTokens for A. No later required stage is reported successful solely because B completed.

### Requirement: Early PP is consumed once by public stage advancement

The Builder SHALL preserve explicit typed stage advancement while retaining PP computed in the joined Lexed attempt and SHALL NOT repeat PP when advancing to Preprocessed.

#### Scenario: Run early stages separately or together

- **GIVEN** a valid two-file source set
- **WHEN** one Builder runs through Preprocessed and another runs Lexed then Preprocessed explicitly
- **THEN** both expose equivalent lexical/active-token products, diagnostic identities and successful stage observations

    Lexed executes the joined early-phase work and retains PP products; Preprocessed consumes them and constructs the active-token observation. It never invokes Process again.

- **AND** no PP diagnostic or work item is duplicated by the second stage transition

#### Scenario: Failed early work remains inspectable

- **WHEN** the joined Lexed attempt contains lexical or PP failure
- **THEN** Builder reports the failed attempt while retaining clean-file PP products and correctly keyed failed-file dispositions
- **BUT** a later stage cannot convert that partial availability into a successful prerequisite or publishable definition set
