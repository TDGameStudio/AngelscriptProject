## ADDED Requirements

### Requirement: Builder accepts prepared shared source input

The maintained Builder SHALL accept a group of shared-const FAngelscriptSource references, copied option values, and optional borrowed callback pointers without requiring callers to create a snapshot, source collection, source manager, or diagnostic engine. It MUST retain the source versions without copying their bodies or reading files.

#### Scenario: Construct without executing or borrowing array storage

- **GIVEN** prepared Source references, options, and callback objects
- **WHEN** a caller constructs Builder and releases the outer input and callback arrays
- **THEN** Builder retains its own reference and pointer lists and option values without compiling or invoking callbacks
- **AND** callback objects and borrowed definition dependencies remain the caller's lifetime responsibility

    Copying options does not acquire ownership of Dependencies. Dependency owners outlive compilation and products borrowing their definitions.

#### Scenario: Invalid input fails without file acquisition

- **WHEN** explicit execution receives a pending validation failure for an empty batch, unprepared body, empty path, duplicate exact path, unrepresentable length, or invalid basic option
- **THEN** it reports failure with SourceReady and a nonempty Error without reading a physical filename
- **AND** it sends final notification once during explicit execution, never during construction
- **BUT** a prepared empty body is valid and does not request module deletion

#### Scenario: Input paths define independent modules

- **GIVEN** ready inputs named `A.as`, `a.as`, and `memory/Empty.as`, the last with an empty body
- **WHEN** Builder accepts the batch
- **THEN** all three exact case-sensitive paths identify distinct modules
- **BUT** the SDK neither requires a mount prefix nor normalizes separators, case, or parent segments

    Host normalization precedes submission. AbsoluteFilename and compatibility ModuleName are not alternate SDK module identities.

### Requirement: Debug observations are explicitly requested

The Builder SHALL avoid full source-derived Text/Json dump materialization in ordinary compilation while retaining stage status, errors, diagnostics, and typed products. Explicit observation requests SHALL retain deterministic stage observations.

#### Scenario: Compile without full text observations

- **WHEN** a caller uses default options to compile `class Unit {}`
- **THEN** stages complete without building complete token-text or stage-JSON observations
- **AND** enabling observations yields equivalent semantic products and deterministic observations across equivalent stage scheduling

### Requirement: Resolved declarations publish once per module

The Builder SHALL publish complete, deep-read-only declaration descriptions once after successful DeclarationsResolved and batch-wide projection validation. Later stages MUST NOT replace or downgrade that publication.

#### Scenario: Publish two file modules

- **GIVEN** `B.as` declares class Beta and `A.as` declares class Alpha with a reflected property and method
- **WHEN** declarations resolve and projection succeeds
- **THEN** descriptions retain two owning paths, stable identities, source anchors, and Alpha's property, method, and metadata
- **AND** output queries see the complete batch before OnDeclarationsReady runs
- **BUT** no first-file-named merged module or mutable descendant escapes through the published interface

#### Scenario: Later failure leaves declaration facts stable

- **GIVEN** declarations were delivered successfully
- **WHEN** body analysis, layout, emission, or a later required hook fails
- **THEN** existing descriptions remain unchanged and final completion reports failure
- **BUT** those descriptions do not authorize a host module replacement

#### Scenario: Associate definitions without rewriting descriptions

- **WHEN** final compilation produces definitions corresponding to delivered declarations
- **THEN** stable declaration keys associate them through definition lookup
- **AND** descriptor ScriptType and ScriptFunction remain unmaterialized rather than being backfilled

#### Scenario: Projection is atomic and empty files remain modules

- **WHEN** a batch contains an empty prepared file and all declaration projections validate
- **THEN** the empty file retains its own logical module identity with empty declaration content
- **BUT** projection failure publishes no partial successful batch and sends no declaration-ready notification

### Requirement: Builder callbacks have ordered terminal semantics

The Builder SHALL call asIBuilderCallbacks synchronously in registration order on the initiating thread after workers join. It SHALL distinguish ordinary fallible hooks from once-only final notification.

#### Scenario: Successful stage hook order

- **WHEN** a stage runs with valid registered callbacks
- **THEN** all OnBeforeStage hooks precede the stage body, one OnDeclarationsReady delivery follows resolved declaration publication when applicable, and all OnAfterStage hooks follow successful work
- **AND** Before sees the previous completed state while declaration and After hooks see the newly visible successful result
- **BUT** failed stages do not call After and Before/After are not guaranteed pairs

#### Scenario: An ordinary callback rejects work

- **GIVEN** callbacks A, B, and C in that order
- **WHEN** B returns false from a Before, declaration-ready, or After hook
- **THEN** remaining ordinary callbacks and stages stop and all A, B, and C receive exactly one OnBuildFinished with failure, the attempted stage, and a nonempty Error
- **AND** final notification returns void and cannot veto or change the outcome

    Final notification includes objects skipped by short circuit. It performs no SDK-owned UObject rollback.

#### Scenario: Pauses and repeated calls do not finish twice

- **WHEN** a caller pauses at DeclarationsResolved and later resumes through ByteCodeEmitted
- **THEN** the pause sends no completion and full success sends one notification with ByteCodeEmitted and empty Error
- **BUT** repeated terminal calls, invalid transition attempts, construction, and destruction do not send another completion

#### Scenario: Callback and execution misuse is rejected

- **WHEN** a caller submits null or duplicate callback object registrations, or attempts concurrent or reentrant stage advancement
- **THEN** invalid registrations are never invoked and invalid advancement is rejected without running a nested stage or duplicating terminal notification
- **AND** the caller remains responsible for callback lifetime and cleanup of an abandoned unfinished Builder

## MODIFIED Requirements

### Requirement: Independent typed compilation stages

#### Scenario: Compile without a host consumer

- **WHEN** a caller supplies prepared shared sources, immutable language options, explicit type context, and no callbacks, Engine, or UE reflection consumer
- **THEN** syntax, semantic definitions, and layout validation complete and create actual TypeInfo owned by asCModuleDefinitionSet with null Engine and TypeId -1

    Builder creates its source-coordinate and diagnostic association internally. Script compilation creates no Engine-owned runtime objects and assigns no process TypeIds. UClass materialization remains a later host step.

- **BUT** unavailable execution backends remain explicit unsupported operations, not hidden legacy fallbacks

    Stopping at DefinitionsFrozen does not require stable bytecode or permit ownership transfer. Default RunThrough continues through ByteCodeEmitted.

#### Scenario: Stop after declarations and resume bodies

- **WHEN** a caller collects and resolves declarations before analyzing bodies
- **THEN** signatures are inspectable while body storage remains writable by the owning compilation session

    Resuming body analysis preserves declaration identity and uses the retained active Token stream.

- **AND** running stages separately or together yields equivalent semantic products and, when explicitly enabled, deterministic text/JSON observations
- **BUT** an invalid transition or failed required stage cannot publish a successful later result

    RunThrough is monotonic; repeating its completed target is a no-op. RunStage accepts only the immediate next stage. Failed builders do not resume, and new input requires a new Builder.

### Requirement: Builder yields two takeable products

The Builder SHALL expose asCCompileOutput and asCModuleDefinitionSet as parallel products, SHALL allow CompileOutput transfer after successful or failed terminal execution returns, and SHALL allow definition transfer only after final success. CompileOutput MUST NOT own TypeInfo, functions, or bytecode.

#### Scenario: Take the definition set off the Builder

- **GIVEN** a shared-source Builder has completed ByteCodeEmitted and all required callbacks successfully on `class Unit { int32 Value; void Set(int32 V) { Value = V; } }`
- **WHEN** all final notifications and the execution call return and the caller invokes TakeModuleDefinitionSet
- **THEN** the returned UniquePtr uniquely owns Unit TypeInfo and methods

    GetEngine is null and GetTypeId is -1. A second Take returns null; Builder no longer owns the graph and retains no usable stale session borrow.

- **AND** destroying that UniquePtr without Registration deletes those TypeInfo objects
- **BUT** failure, a stage pause, or an executing callback cannot yield a taken definition set

#### Scenario: Compile a later unit against a Taken set

- **GIVEN** a taken asCModuleDefinitionSet from a successful compile of `class First { int32 Value; }`
- **WHEN** a second shared-source Builder compiles `class Second { First@ Ref; }` with Options.Dependencies holding a non-owning pointer to that set
- **THEN** Second resolves First without Engine Registration

    The first set remains immutable; the second uniquely owns Second only. The dependency owner remains alive while used by compilation and dependent products.

- **BUT** depending on an unfinished or unsuccessful set is rejected

    Cross-unit cycles remain rejected. Mutually visible source files compile in one batch. Frozen-host native graphs use Frozen DefinitionSet pointers in Options.Dependencies. asSBuilderOptions has no Image host list.

#### Scenario: CompileOutput carries ClassGen descriptors without ScriptType

- **WHEN** a caller reads CompileOutput after declaration publication for class Widget, or takes it after terminal execution returns
- **THEN** asCDefinitionCompileOutput exposes the existing module/class descriptor information for Widget through deep-read-only access

    ScriptType and ScriptFunction remain null; the result does not own TypeInfo or bytecode.

- **BUT** CompileOutput is not a substitute for TakeModuleDefinitionSet

#### Scenario: Terminal output survives its Builder

- **GIVEN** a successful or failed build whose final callbacks and execution have returned
- **WHEN** the caller takes CompileOutput and destroys Builder and caller source arrays
- **THEN** the taken result retains required source versions and coordinate indexes for its diagnostics and declaration anchors
- **AND** repeated Take returns null without regeneration, stage advancement, or notification
- **BUT** Take during callbacks or intermediate pauses returns no product

### Requirement: Default RunThrough emits stable bytecode

#### Scenario: Default RunThrough includes Emit

- **WHEN** a caller constructs shared-source asCBuilder and calls RunThrough with the default stage
- **THEN** the run includes Emit and, after successful terminal execution returns, script functions on the taken set have nonempty stable bytecode views
- **BUT** native asFUNC_SYSTEM functions keep an empty stable body
