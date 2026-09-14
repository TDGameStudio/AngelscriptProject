# Exported scoped design

Source identity: angelscript/test-framework-completion, design code-database, accepted core decisions through 2026-09-13. The user explicitly authorized immediate new-Change creation after reviewing the design; unanswered forms remain unanswered. This English snapshot consolidates the selected design, with technical defaults identified as planning assumptions. No full transcript or unconfirmed talk/knowledge promotion is included.

# Code database design

## Context and authorization

This is the planning contract for `angelscript/feature-test-code-database`. The user directed immediate creation after the core architecture discussion. Public names explicitly settled in that discussion are preserved. Fine-grained choices below labelled **Planning assumption** are recommended defaults used to make this requested record concrete; empty question-tool responses are not recorded as approval. Replan a material contradiction before implementing the affected contract.

## Goals and non-goals

Provide independently owned immutable source materials to multiple UE test modules. Do not compile or execute source, interpret diagnostics expectations, schedule reloads, implement LSP/DAP behavior, or restore legacy runtime/test gates. Windows is the first resource carrier, not a public data-model dependency.

## Identity and authoring

One author root is `AngelscriptTestCode/`. `Language/Counter.as` derives `Language/Counter`; it is not a generated numeric resource ID or a movement-stable alias. File metadata has Version = v1, Tag, English Summary and Topics. Version metadata has Tag, optional Parent, English Summary and separate Topics. Topics never control parsing or execution and never inherit.

Every node contains full source, including the explicit root. Parent is a relation, not an execution sequence or reconstruction recipe.

**Planning assumption — v1 syntax:** use the complete form below. The first metadata block is the file header; later version headers use the same @version spelling in node context. A source begins after its header line ending and ends immediately before the standalone end marker. Normalize container line endings to LF; preserve other source whitespace. A single initial UTF-8 BOM is accepted and excluded from clean source.

```angelscript
/**
 * @version v1
 * @summary Counter source variants.
 * @topic Language
 */
/**
 * @version root
 * @summary Define the initial counter.
 */
class Counter
{
    int Value = 0;
}
/** @end */
/**
 * @version add-step
 * @parent root
 * @summary Add a configurable increment step.
 * @topic Fields
 */
class Counter
{
    int Value = 0;
    int Step = 1;
}
/** @end */
```

**Planning assumptions — strict boundaries:**

- Header directives occupy their own logical lines, with optional indentation and one decorative leading star. Values occupy the rest of that line; no multiline values or inline directives in prose. Summary is required and nonempty; English is an author convention, not language-detection validation. Topics may be absent.
- Tags are case-sensitive ordinal strings, slash-normalized for file paths; disallow absolute paths, empty segments, dot/dot-dot segments, and backslash aliases in explicit logical Tags. File extension discovery is case-insensitive, but derived identities are case-sensitive; reject physical path collisions on Windows.
- Version Tags are nonempty tokens without whitespace or slash; root has Tag root and no Parent, other nodes require one same-file Parent. Parents may be declared later. Exactly one root, no duplicate tags or cycles.
- Unknown directives are errors in v1 rather than silently discarded. New accepted directives require an intentional version-compatible parser extension or a new format version.
- Structural end markers are standalone logical lines, including inside deliberately malformed AS. Marker processing is not AS lexing. An author writes `/** @@end */` to retain literal `/** @end */` in source. Reserved inline position markers likewise use @@ to escape recognition; unescape once without recursively interpreting the result.
- Container metadata is valid UTF-8 text. Malformed source byte tests use owned exact-byte C++ sources; the container is not an arbitrary binary envelope.

## Source and annotations

FAngelscriptTestSource owns shared bytes, FAngelscriptTestAnnotations and origin mapping. Ordinary AS_TEST_SOURCE removes one opening/closing literal envelope and the exact common indentation prefix, not all intentional blank lines; normalization is deterministic and mapped to the C++ author anchor. AS_TEST_SOURCE_EXACT and FromBytes provide unchanged length-aware payloads, including NUL and invalid UTF-8. Macro construction has no global registration side effects.

**Planning assumption — position grammar:** recognize `/** @point name */`, `/** @breakpoint name */`, `/** @range-begin name */`, and `/** @range-end name */` by exact directive form. Remove only the marker bytes from clean source; offsets are zero-based UTF-8 byte offsets and ranges are half-open. Names are unique per marker kind and selected version; range endpoints match, nested ranges are allowed, crossings fail. Reserved marker text inside AS strings also requires @@ escaping; document this text-template rule rather than claiming full language lexing. Generic annotations carry no diagnostics or debugger execution policy.

Literal macro normalization and annotation parsing are separate explicit operations. `FAngelscriptTestAnnotations::Parse(Source)` returns a checked source result for inline annotated input. The container adapter invokes the same parser. C++ authors without annotations can pass macro-produced Source directly.

## Public shapes and ownership

All exported names live in `AngelscriptTest`; no Private namespace. Header/file names follow the type spelling. API sketches are contracts with constructors, includes and export details omitted where irrelevant.

```cpp
struct FAngelscriptTestFileMeta {
    FString Version;
    FString Tag;
    FString Summary;
    TArray<FString> Topics;
};
struct FAngelscriptTestVersionMeta {
    FString Tag;
    TOptional<FString> Parent;
    FString Summary;
    TArray<FString> Topics;
};

class FAngelscriptTestCodeBuilder {
public:
    explicit FAngelscriptTestCodeBuilder(const FAngelscriptTestFileMeta&);
    void AddRoot(FAngelscriptTestVersionMeta, FAngelscriptTestSource);
    void AddVersion(FAngelscriptTestVersionMeta, FAngelscriptTestSource);
    [[nodiscard]] FAngelscriptTestCodeBuildResult Build();
};

class FAngelscriptTestCodeRegistration {
public:
    using FCodeFactory = FAngelscriptTestCodeBuildResult (*)(
        const FAngelscriptTestFileMeta&);
    FAngelscriptTestCodeRegistration(
        FAngelscriptTestFileMeta, FCodeFactory,
        const ANSICHAR* OwnerModule = UE_MODULE_NAME,
        const ANSICHAR* SourceFile = __builtin_FILE(),
        int32 SourceLine = __builtin_LINE());
};
```

Factories are ordinary function pointers/no-capture lambdas. File metadata is copied into a registration-owned record. Static construction records metadata and callable identity only; it does not invoke factories or load resources.

**Planning assumption — builder error delivery:** Add operations accumulate structural errors; Build validates the whole graph and returns success content or an owned error list. Independent errors are collected; ambiguous dependent checks do not manufacture cascades. An earlier error is never cleared by a later valid Add. Build is single-use: subsequent Add/Build reports a consumed-builder error; rebuilding requires a new Builder. The factory returns BuildResult by value; no borrowed Builder storage survives it. One hand-written factory yields one file and its versions as one batch. Resource adapters can submit several built files as one batch without expanding the public Builder into a multi-file editor.

```text
FAngelscriptTestCode                        // One exported center, not an inline singleton per DLL.
└─ FilesByTag                              // Each admitted file owns shared metadata.
   └─ CasesByVersionTag                    // The map stores lightweight SourceCase values directly.
      └─ SourceCase::FData                 // One immutable shared payload binds metadata to source.
         ├─ FileMeta                       // File metadata is shared across versions.
         ├─ VersionMeta                    // Parent is a tag, not a strong parent pointer.
         └─ Source                         // Bytes, annotations and origin maps share owned storage.
```

Case copies do not copy source bytes or retain the entire database. Source copies outlive Case and Result. Thread-safe reference counts do not by themselves synchronize maps; publish on the coordinated game-thread phase, then expose const reads. No mutation or teardown may race active readers. Test-only isolated centers use the same implementation without global registration.

## Retrieval and state

```cpp
FAngelscriptTestCode& FAngelscriptTestCode::GetInstance();
FAngelscriptTestStatus FAngelscriptTestCode::ActivateRegistrations();
FAngelscriptTestSourceResult FAngelscriptTestCode::Get(
    FStringView FileTag, FStringView VersionTag) const;
FAngelscriptTestStatus FAngelscriptTestCode::FindCases(
    FStringView FileTag, TConstArrayView<FString> RequiredVersionTopics,
    TArray<FAngelscriptTestSourceCase>& OutCases) const;
FAngelscriptTestStatus FAngelscriptTestCode::FindFiles(
    TConstArrayView<FString> RequiredFileTopics,
    TArray<FAngelscriptTestFileMeta>& OutFiles) const;
bool FAngelscriptTestCode::IsActivated() const;
TArray<FAngelscriptTestError> FAngelscriptTestCode::GetRegistrationErrors() const;
```

The last two names and exact Add/query signatures are planning assumptions following existing naming. IsActivated means the activation attempt finished, not all batches succeeded.

SourceResult holds exactly Case or Error by value, with IsSuccess, GetCase and GetError. Borrow accessors are const-lvalue-only with deleted rvalue overloads. Case exposes const-lvalue GetFileMeta/GetVersionMeta and owning-value GetSource. Source exposes length-aware GetBytes, GetAnnotations and GetOriginMap; borrowed views cannot outlive Source. Status carries an owned error list and IsSuccess/GetErrors. BuildResult exposes IsSuccess and GetErrors plus an internal move-only admission payload; it is not a mutable public database.

**Planning assumptions — query details:** require explicit file and version Tags; no implicit latest/current version. Topic filters use AND; empty filters enumerate all within the declared scope. Results sort ordinally by Tag. Successful zero-match is an empty result; a test requiring material must assert nonempty. Unknown exact identities are errors. Failed enumeration leaves output unchanged, and callers must check Status before using it. Failed batches make global topic enumeration fail because their topics may be unknowable; precise retrieval and enumeration inside admitted files remain usable.

## Activation and admission

A single owner hooks OnAllModuleLoadingPhasesComplete, or immediately invokes the same handler when IsEngineStartupModuleLoadingComplete is already true. GetOnPostEngineInit occurs before PostEngineInit module loading and is not the barrier. Unsubscribe during owner shutdown. No consumer reads from fixture/static constructors; Get before activation fails explicitly.

No-argument ActivateRegistrations processes the global startup registration snapshot. UE_MODULE_NAME records provenance; it does not filter activation. Do not invoke user code or load modules under a registry lock. The provider DLL must remain loaded while its callback executes.

**Planning assumptions — determinism and repeats:** snapshot all providers, build detached batches, inspect all complete identities, then publish only nonconflicting valid batches. If two batches claim the same FileTag, reject both entire batches; do not choose by load order. Unknown identities from an unreadable batch remain global health errors without inventing identity claims. Repeated activation returns the retained status without re-running callbacks. Reentry fails explicitly. Registrations arriving after the snapshot are rejected with a retained late-registration error; no automatic retry, late load listener or hot-unload guarantee.

Malformed metadata rejects a batch, not the editor. Broken AS source remains valid material. Errors preserve known owner, input path, version Tag, author position and reason; unavailable metadata is not fabricated. Keep bad-input self-tests isolated from the healthy global database. Fixed integrity checks are normal CQTest methods independent of successful-source enumeration; this Change does not redesign Automation selection policy.

## Windows resource adapter and build boundary

Generate an index and RC entries; embed raw original files, not formatted C++ copies. A fixed string resource named AS_TEST_INDEX contains UTF-8 JSON:
```json
{"version":"v1","files":[{"path":"Language/Counter.as","id":1001}]}
```

The example ID is illustrative: real IDs are assigned deterministically from sorted paths within a reserved, collision-checked range; no public stability guarantee. Reader resolves IDs from the index using the correct owner HMODULE, copies bytes, parses common containers, and never falls back to loose disk files.

**Planning assumption — build layout:** use a plugin-owned C# helper beside AngelscriptTest.Build.cs to generate Intermediate/AngelscriptTestCode/<Target>/<Platform>/<Configuration>/<OwnerModule>/index.json and resources.rc. A generated module RC input must be discovered by UBT and its complete input set tracked; if installed-engine UBT requires a different exact staging hook, record the evidence and update this integration detail rather than patching engine source. RC must preserve UE version/icon resources. Build each fixture module independently; resources cannot be looked up against the executable handle by assumption.

Each embedded provider explicitly selects owned subdirectories from the one author root; this is build ownership, not a second query namespace. First fixtures assign Language/ to AngelscriptTest; the secondary module uses C++ factories. Adding/removing/renaming an input must invalidate inventory and linking, while unchanged input must not rewrite generated outputs. Prove these properties in an isolated fixture staging root through Harness-managed builds. ModuleRules.ExternalDependencies alone does not prove RC action dependency completeness.

## Verification and rollback

See tasks for grouped RED/GREEN. Required proof includes exact bytes and origin mapping, source lifetimes, graph validation, same-tag collisions under reversed registration order, once-only activation, both DLL entry paths, resource edit/add/delete/rename/no-op transitions and source-directory-independent runtime lookup. No UE build or runtime test was run during creation.

Rollback changes only this feature's replacement code/build wiring and authored fixtures; never restore legacy gates. Windows carrier failure does not justify a hidden disk fallback.

## Existing Change overlap

This new record owns the requested code-database implementation plan. The old unified-framework record is preserved unchanged and is not permission to execute a parallel implementation. Before any overlapping task is scheduled, coordinate its disposition through a separately authorized update of that old record. This planning-only delivery does not cancel, archive or edit it. See [overlap map](../data/scope-ownership.md).
