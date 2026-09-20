---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "2.2": ["2.1"]
    "3.1": ["2.1"]
    "3.2": ["3.1"]
    "3.3": ["3.2"]
    "4.1": ["2.2", "3.3"]
---

# Shared Source and Builder Compilation Entry

## Goal

Compile prepared shared Source versions through a stable Builder entry without redundant source-body storage, with reliable declarations, hooks, and result lifetimes.

## Architecture

The host prepares one common Source; Builder retains references and internal indexes, stages compilation, and publishes declarations once. Final callbacks precede terminal ownership transfer. See [design.md](design.md) and the [accepted interface vocabulary](attachments/drafts/glossary.md).

## Global constraints

- This turn creates and plans only; no product task is executed without subsequent implementation authorization.
- Product changes belong to Plugins/Angelscript; do not activate legacy runtime/tests, move unrelated F types, or absorb VFS/streaming/LSP/full diagnostics tooling.
- New tests use WITH_ANGELSCRIPT_TESTS and NativeEngine CQTest identities; each named case below is its future TEST_METHOD name.
- Dependencies on other Changes are absent; overlapping diagnostic-tooling edits require inspection, not mutation of its plan.
- Case source text is UTF-8; `\\r\\n` denotes CRLF where explicitly stated. Test class/file names follow the inspected NativeEngine CQTest convention.
- Execution conventions: [.agents/skills/harness/references/execution-conventions.md](../../../../.agents/skills/harness/references/execution-conventions.md).

## Requirement coverage

| Requirement / acceptance condition | Tasks |
|---|---|
| Common source retains host fields, preparation/move semantics, exact paths, distinct versions | 1.1 |
| Builder input shape, no caller snapshot/diagnostics, body pointer identity, validation, stage sequencing | 2.1 |
| Input-local UTF-8 ranges, cross-input rejection, lazy lines, stable anchors, provenance, AST retention | 2.1 |
| Default no full text/JSON copies; explicit deterministic observations | 2.2 |
| Once-only per-file declarations, empty modules, atomic failure, rich metadata, recursive read-only access, stable association | 3.1 |
| Caller-thread hook ordering/visibility, short circuit, failure stage, final all-object notification, pause/re-entry boundaries | 3.2 |
| Terminal Take, both products, failed output retention, dependency lifetime, no stale session borrow | 3.3 |
| Default bytecode completion and no Engine publication | 2.1, 3.3 |
| Both affected capability deltas synchronized with bounded baseline formatting repairs | 4.1 |

Self-review 2026-09-13: coverage complete; placeholders absent; symbols match the glossary or cited existing conventions. Record: [attachments/data/planning-validation.md](attachments/data/planning-validation.md).

## [x] 1.1 Unify the common movable UTF-8 Source

Make the shared record usable by both SDK and host while keeping existing provenance fields and host acquisition policy.

**Outcome**

FAngelscriptSource has one moved UTF-8 body, ready and preparation constructors, exact path access, and noncopyable value semantics. Adapt active host consumers for encoding/move/include compatibility; do not read files from the SDK or activate dormant paths.

**Interfaces**

Consumes:

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSource.h:55
FAngelscriptSource; // Existing fields and FromGameFile/FromPluginFile/FromMemorySource factories.
// Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSourceProvider.h:51
IAngelscriptSourceProvider; // Existing enumeration/loading/query contract; not a Builder input.
```

Produces:

```cpp
// Names: attachments/drafts/glossary.md; the sole common definition.
FAngelscriptSource();
FAngelscriptSource(FString InPath, FUtf8String&& InSourceText);
FStringView FAngelscriptSource::GetPath() const;
const FUtf8String& FAngelscriptSource::GetSourceText() const;
// Files: angelscript/unreal/AngelscriptSource.h and .cpp.
// Test convention: NativeEngine CQTest TestDir + unprefixed class + method.
SourceInput; // Future class: Angelscript.UnitTest.NativeEngine.SourceInput.<CaseName>
```

**Cases**

1. **MoveRetainsBodyAddress** — new RED
   Given an allocated UTF-8 body `class Unit {}` and path `memory/Unit.as`, When moved into Source, Then GetSourceText's data pointer equals the pre-move allocation, Len equals the original byte count, GetPath equals the exact path, and bHasSourceText is true.

2. **PreparationRetainsHostFields** — new RED
   Given a default Source, Then bHasSourceText is false; When the host populates AbsoluteFilename=`C:/Scripts/Unit.as`, RelativeFilename=`Unit.as`, ModuleName and SourceKind using the existing host factory convention and prepares the body, Then the fields remain queryable and only one UTF-8 SourceText owns its body.

3. **SourceCannotCopy** — new RED
   Given the common header and old forwarding header in the same test translation unit, When compile-time type traits inspect FAngelscriptSource, Then copy construction/assignment are disabled, move construction is enabled, and both headers identify the same type; assert these traits from the SourceInput case.

4. **GenericPathDoesNotRequireMount** — new RED
   Given ready paths `A.as`, `a.as`, and `scratch/../A.as`, When constructed directly, Then each GetPath returns its exact spelling without a mount-prefix admission check.

5. **PreparedEmptyBody** — boundary
   Given an explicitly ready empty FUtf8String, When moved into Source, Then bHasSourceText is true and Len is zero; this record does not encode deletion.

6. **IndependentPublishedVersions** — new RED
   Given old/new Sources at `A.as` containing `class Old {}` and `class New {}`, When caller preparation references are released while shared-const references remain, Then each reference still observes its own text and neither update mutates the other.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/unreal/AngelscriptSource.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/unreal/AngelscriptSource.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSource.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSource.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSourceProvider.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSourceProvider.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSnippet.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheSourceDiscovery.cpp
 Plugins/Angelscript/Source/AngelscriptEditor/HotReload/AngelscriptDirectoryWatcherInternal.cpp
 Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITSourceAuthority.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/SourceInputTests.cpp
```

**Verification**

Run from the selected workspace root with the Harness context initialized and the affected C++ editor build successful as required by execution conventions.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine.SourceInput'
    Fast = $true
    TimeoutMs = 600000
}
```

All six SourceInput cases execute and pass after the affected plugin/editor host build. Inspect active Source consumers for remaining copy-by-value call sites; adjust only those required by the changed record. The old host factory path behavior remains evidenced by storage findings.

**Notes**

The listed Preprocessor paths were confirmed during preflight. Minimal pure path/data helpers may remain in the common Source files; do not move unrelated F-prefixed descriptors. Use the inspected storage evidence for host compatibility, not a blanket claim about legacy zero-copy.

**Evidence**

- Build `ue.build` run `34b213a41af34336b3c9ea0d002dab1e` Succeeded after UBT rejected duplicate `AngelscriptSource.cpp` basenames (run `ce808fe9cc334f72a000705c5b2d3047`).
- Proving command `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.SourceInput` Fast run `06645ff996e84672abd7ec0ef0fcf5f9` Succeeded; report `Saved/Harness/Unreal/Runs/06645ff996e84672abd7ec0ef0fcf5f9/AutomationReport/index.json`; 6/6 discovered and executed.
- Cases: MoveRetainsBodyAddress, PreparationRetainsHostFields, SourceCannotCopy, GenericPathDoesNotRequireMount, PreparedEmptyBody, IndependentPublishedVersions — all Success.
- Copy-by-value host sites adapted: preprocessor `RawCode` conversion, provider `LoadSourceBytes` UTF-8 view, JIT frozen inventory field copy. Engine/directory-watcher factory returns already moved.
- Observed preimplementation RED is absent as a behavioral Automation run: the new ready constructor/`GetPath`/`GetSourceText` API could not compile against the previous FString/copyable record, so the first executable selector is this GREEN snapshot.
- Naming assumed: none. File disposition: `Core/AngelscriptSource.cpp` deleted rather than left as a second `AngelscriptSource.cpp` because UBT forbids duplicate input filenames in one module; `Core/AngelscriptSource.h` still forwards `unreal/AngelscriptSource.h`.
- Omitted: Quick, Performance, Integration, full NativeEngine, legacy tests — this card owns only the common Source record.

## [x] 2.1 Compile shared Source input with retained internal coordinates

Replace the maintained snapshot/diagnostics entry end-to-end, including the coordinate consumers and fixtures that would otherwise require the removed input construction pipeline.

**Outcome**

Builder accepts the three-argument shared input and owns internal coordinate/diagnostic association. No second source body or caller-built snapshot is required. Existing byte ranges, stable anchors, lazy lines, provenance, stage sequencing, and engine independence continue to work. Hook dispatch is owned by 3.2; terminal product transfer is owned by 3.3.

**Interfaces**

Consumes:

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h:24; existing RunStage/RunThrough and query surface.
asCBuilder; asEBuilderStage; asSBuilderOptions;
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_manager.h:15-39
asCSourceManager; // MakeRange, TryGetBytes, TryGetLineColumn, stable-anchor and origin queries.
// Task 1.1 produces FAngelscriptSource and its accessors.
```

Produces:

```cpp
// Names/signatures: attachments/drafts/glossary.md.
asCBuilder(TConstArrayView<TSharedRef<const FAngelscriptSource, ESPMode::ThreadSafe>> Sources,
    const asSBuilderOptions& Options, TConstArrayView<asIBuilderCallbacks*> Callbacks = {});
bool RunThrough(asEBuilderStage Target = asEBuilderStage::ByteCodeEmitted);
bool RunStage(asEBuilderStage Stage);
// Declare the agreed interface/header now; dispatch is produced by 3.2.
asIBuilderCallbacks; // angelscript/as_builder_callbacks.h.
// Existing SourceManager query names retained; shared-reference ingestion is internal.
BuilderSourceEntry; // CQTest convention: Angelscript.UnitTest.NativeEngine.BuilderSourceEntry.<CaseName>
```

**Cases**

1. **SharedBodyThroughFrontend** — new RED
   Given `A.as` containing `class Unit {}` as one shared Source, When caller arrays are destroyed after construction and Builder reaches DeclarationsResolved, Then token/source-manager range views still point inside that exact FUtf8String allocation; an independently computed byte slice equals `Unit`.

2. **SeparateInputIdentitySameSource** — new RED
   Given two Builders retaining the same Source, When querying each input's range and then mixing their endpoints, Then each valid query returns the original allocation and the mixed range is rejected even when local FileID values match.

3. **RawCoordinatesAndDiagnostics** — new RED
   Given exact bytes `EF BB BF 61 0D 0A C3 A9 00 FF`, When queried by byte range and scanned, Then [6,8) selects `C3 A9`, [8,9) selects NUL, the body remains byte-identical, and NUL/invalid UTF-8 produce located errors rather than truncation or replacement.

4. **InputAdmission** — new RED
   Given independently tested batches: empty, one default unprepared Source with a physical filename, one empty logical path, and two `A.as` entries, When RunThrough executes, Then each fails at SourceReady with nonempty Error and no file read. Given `A.as` and `a.as` ready empty files, Then input admission succeeds.

5. **OptionsAndLengthAdmission** — new RED
   Given otherwise valid input, When StableScope is empty or WorkerCount is zero, Then SourceReady fails explicitly. Given a synthetic byte-count admission boundary above the supported offset maximum without allocating that body, Then the checked length conversion rejects it rather than wrapping.

6. **StageProgression** — new RED
   Given `class Unit {}` and no Engine/callbacks, When RunThrough stops at DeclarationsResolved, repeats that target, then RunStage advances to BodiesAnalyzed and RunThrough finishes, Then identity stays unchanged and all transitions succeed; skipping/backtracking RunStage is rejected without a successful later result.

7. **RetainedAstAndLazyLines** — new RED
   Given an escaped AST/root for `class Unit {}\r\n`, When Builder and caller arrays are released, Then retained ranges and stable anchors still resolve; no line map exists before presentation and repeated presentation requests agree. Use a root-owned lease, not per-node Source pointers.

8. **InternalProvenanceStillQueries** — boundary
   Given a direct source range and an internally recorded transformed origin whose parent is that range, When queried from an AST range, Then the ordered chain terminates at the same original source bytes and a foreign input origin is rejected; the caller supplies no Origins array.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder_callbacks.h
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_snapshot.h
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_snapshot.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_manager.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_manager.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_location.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_provenance.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_projection.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_binding_declaration.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_preprocessor.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_preprocessor.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_lifetime.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**/*.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**/*.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderSourceEntryTests.cpp
```

**Verification**

Run from the selected workspace root with the Harness context initialized and the affected C++ editor build successful as required by execution conventions.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine'
    Fast = $true
    TimeoutMs = 600000
}
```

All eight new BuilderSourceEntry cases execute and pass; the complete replacement NativeEngine selection also passes because shared source/index ownership and fixture construction affect AST, diagnostics, compiler, and VM consumers. Record exact old-to-new fixture adaptations, not a legacy suite revival.

**Notes**

The test globs allow only input-construction/query-lifetime migration of existing NativeEngine fixtures and cases; no unrelated behavior edits. Remove snapshot headers only after their actual active consumers migrate. Reuse internal SourceManager state for reference/index retention; do not replace the removed type with another public source collection. Deterministic stage dumps remain enabled as before until 2.2.

**Evidence**

- Build `ue.build` runs including `c146dad91d46445c84388d9f1fd12017` Succeeded for the proving binary.
- Proving command `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine` Fast run `14ff26d1e7c347a2b6e660eda966136a` Succeeded; report `Saved/Harness/Unreal/Runs/14ff26d1e7c347a2b6e660eda966136a/AutomationReport/index.json`; 1147/1147 discovered and executed.
- BuilderSourceEntry cases: SharedBodyThroughFrontend, SeparateInputIdentitySameSource, RawCoordinatesAndDiagnostics, InputAdmission, OptionsAndLengthAdmission, StageProgression, RetainedAstAndLazyLines, InternalProvenanceStillQueries — all Success on that run.
- Shared-source identity made `RunThrough()` emit real bodies. Fixtures that also `EmitFromSession` + link now `TakeEmittedByteCode()` (Register default `bPublishAdoptedByteCode=false`; `EmitAndEncode`/`EmitImage` discard adopted images). Callers capture `asCScriptFunction*` or Host sets before `Take`/`Register`. Admission uses case-sensitive path compare, not `TSet<FString>`.
- Product gaps exposed by real emit: list-init host/generic lookup; `AcquireVmObjectLease` no longer dereferences a stale TLD context on the ordinary allocate path; `DetachEngine` clears a matching TLD pointer; caller-held snapshot destructor Releases declarations only while a publisher is attached. Record: `attachments/implementation/issue-20260913-105100-shared-source-makes-emit-real.md`.
- Observed preimplementation RED is absent as a behavioral Automation run: the new shared-source Builder constructor could not compile against `asCSourceSnapshot`, so the first executable selector is this GREEN snapshot.
- Naming assumed: `asTryConvertSourceByteLength` — checked length conversion at the admission boundary; `asCSourceManager` remains the public query/index type holding `TSharedRef<const FAngelscriptSource>`; `GetSourceManager`/`GetSources()` replace `GetSourceSnapshot()`; `AddGlobalRequirement` — emit-frame global DeclRef; `RegisterCompiledDefinitions(..., bool bPublishAdoptedByteCode = false)` — test helper so EmitFromSession+Link cases do not `BodyConflict`.
- Omitted: Quick, Performance, Integration, legacy tests — this card's proving selector is the replacement NativeEngine suite.

## [ ] 2.2 Make complete stage observations opt-in

Separate inspectable stage state from optional full text/JSON serialization.

**Outcome**

Default compilation avoids TokenText/complete stage-JSON materialization while explicit observation retains deterministic content. Language semantics and typed products do not change.

**Interfaces**

Consumes:

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_builder_stages.h:17-36
asSBuilderOptions; asSBuilderStageResult; // Existing Text, Json, Error, Succeeded fields.
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp:50 and Lexed/Preprocessed branches
TokenText; // Existing internal dump construction to gate.
// Task 2.1 produces the shared-source Builder entry.
```

Produces:

```cpp
bool asSBuilderOptions::bGenerateDebugObservations = false;
// Name derives from existing option-field conventions; accepted behavior in design.md.
BuilderObservations; // NativeEngine CQTest convention: ...BuilderObservations.<CaseName>
```

**Cases**

1. **DefaultDoesNotMaterializeDumps** — new RED
   Given `class Unit { int32 Value; }` and default options, When Builder reaches Lexed, Preprocessed, and full completion, Then Text/Json remain unmaterialized while stage success and typed Unit/Value products are available. An internal test observation of the dump-producing path remains zero; checking only an empty string after discarded work is insufficient.

2. **ExplicitObservationsAreDeterministic** — new RED
   Given the same source with bGenerateDebugObservations=true, When stages execute separately and together with WorkerCount 1 and 2, Then requested Text/Json are populated and equal for equivalent stages, and disabling observation yields the same stable semantic identities.

3. **ErrorsRemainAvailableWithoutDumps** — boundary
   Given the malformed input `class {`, When default compilation fails, Then Error and located diagnostics remain available although complete Text/Json dumps are not generated.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_builder_stages.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**/*.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderObservationTests.cpp
```

**Verification**

Run from the selected workspace root with the Harness context initialized and the affected C++ editor build successful as required by execution conventions.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine.BuilderObservations'
    Fast = $true
    TimeoutMs = 600000
}
```

All three BuilderObservations cases execute and pass. Existing tests that explicitly inspect dumps opt in; the test glob is limited to those observation call sites. The focused selector includes paired opted-in/default semantic controls.

**Notes**

Debug allocation counters, if required for the oracle, are internal test instrumentation, not another public tracing framework.

## [ ] 3.1 Publish stable deep-read-only per-module declarations

Make resolved typed projection the single outward declaration source and remove the later simplified overwrite.

**Outcome**

Publish one validated batch with individual file-module identities, empty modules, rich metadata/source anchors, and recursively read-only access. Later stages cannot mutate or republish it. No runtime pointer backfill or second descriptor family.

**Interfaces**

Consumes:

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_compile_output.h:8-19
asCDefinitionCompileOutput; // Current GetModules/ReplaceModules expose mutable descendants.
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_descriptor_consumer.h:25
FAngelscriptDescriptorConsumer; // Existing typed per-fragment projection; Project implementation at .cpp:299-343.
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.h:130-133
asCModuleDefinitionSet::FindType; asCModuleDefinitionSet::FindFunction; // asSStableKey lookup.
// Task 2.1 produces shared-source input and stage execution.
```

Produces:

```cpp
// Existing output and descriptor names retained (glossary).
const asCDefinitionCompileOutput& asCCompileOutput::GetDefinitionOutput() const;
// Published traversal must not expose mutable descendants; private construction stays separate.
BuilderDeclarations; // NativeEngine CQTest convention: ...BuilderDeclarations.<CaseName>
```

**Cases**

1. **DistinctModulesKeepRichDeclarations** — new RED
   Given `B.as: class Beta {}` and `A.as: UCLASS() class Alpha { UPROPERTY() int32 Value; UFUNCTION() void Set(int32 V) { Value = V; } }`, When declarations resolve, Then two module paths own their respective classes, Alpha retains Value/Set and reflection metadata, and stable keys/source anchors refer to A.as. Input sorting does not merge ownership.

2. **PublicationDoesNotDowngrade** — new RED
   Given the preceding batch, When it advances from DeclarationsResolved through DefinitionsBuilt and ByteCodeEmitted, Then module count, owning paths, property/method metadata, anchors, and stable keys remain identical to their first publication, and the projection/publish count is exactly one.

3. **ReadOnlyDescendantsCannotEscape** — new RED
   Given the public output traversal, When compile-time type probes examine every exposed module/class/member container and accessor, Then no returned reference or smart pointer permits descriptor/descendant mutation. The probe set covers nested class, property, function, enum, and delegate data; constness only on the outer output fails the case.

4. **EmptyModuleAndAtomicProjection** — new RED
   Given `Empty.as` with zero bytes and `A.as: class Alpha {}`, When projection succeeds, Then both module identities exist and Empty has no declarations. Given `A.as` and `B.as` each declaring `class Duplicate {}`, When declaration admission fails, Then no partial successful batch is published.

5. **StableKeyAssociationWithoutBackfill** — new RED
   Given `A.as: class Alpha { void Set() {} }` and a completed definition set, When looking up class/function stable declaration keys, Then the matching Alpha/Set definitions are found while ScriptType and ScriptFunction in published descriptions remain null.

6. **LateBodyFailureKeepsDeclarations** — new RED
   Given `A.as: class Alpha { void Bad() { Missing(); } }`, When declarations resolve successfully and body analysis then fails, Then the previously published Alpha/Bad declaration facts and anchors remain unchanged and final compilation is unsuccessful.

7. **NamespacedDeclarationOwnership** — new RED
   Given `A.as: namespace N { class Alpha {} }` and `B.as: class Beta {}`, When full compilation completes, Then Alpha remains associated with A.as and namespace N rather than disappearing from the outward result.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_compile_output.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_descriptor_consumer.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_descriptor_consumer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDescriptors.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderDeclarationTests.cpp
```

**Verification**

Run from the selected workspace root with the Harness context initialized and the affected C++ editor build successful as required by execution conventions.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine.BuilderDeclarations'
    Fast = $true
    TimeoutMs = 600000
}
```

All seven BuilderDeclarations cases execute and pass. Compile-time probes are exercised by the built test translation unit and reported by ReadOnlyDescendantsCannotEscape. The rich fixture oracle checks fields individually, not output serialized by the implementation under test.

**Notes**

Fine-grained read-only access follows existing Get-style naming and the accepted result-iteration allowance. Do not achieve read-only delivery by duplicating the descriptor semantic model or by globally forbidding host preparation. Callback timing is wired by 3.2.

## [ ] 3.2 Dispatch ordered hooks and exactly-once final notification

Wire the agreed callback interface into the single stage dispatcher without changing compiler/host ownership.

**Outcome**

Ordinary hooks run serially on the caller thread with well-defined state visibility, stop on false, and trigger one all-object final broadcast on failure. Full success notifies once; pauses and abandonment do not. No context, semantic feedback, or UObject rollback.

**Interfaces**

Consumes:

```cpp
// Task 2.1 produces angelscript/as_builder_callbacks.h and the constructor registration list.
// Task 3.1 produces stable asCDefinitionCompileOutput publication.
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h:27-35 existing stage/output query names.
asCBuilder::RunStage; asCBuilder::RunThrough; asCBuilder::GetStage; asCBuilder::GetCompileOutput;
```

Produces:

```cpp
// Names/signatures: attachments/drafts/glossary.md.
virtual bool asIBuilderCallbacks::OnBeforeStage(asEBuilderStage Stage);
virtual bool asIBuilderCallbacks::OnAfterStage(asEBuilderStage Stage);
virtual bool asIBuilderCallbacks::OnDeclarationsReady(const asCDefinitionCompileOutput& Definitions);
virtual void asIBuilderCallbacks::OnBuildFinished(bool bSucceeded, asEBuilderStage Stage,
    FStringView Error, const asCCompileOutput& Output);
BuilderCallbacks; // NativeEngine CQTest convention: ...BuilderCallbacks.<CaseName>
```

**Cases**

1. **SerialStageVisibility** — new RED
   Given A/B/C registrations and `A.as: class Alpha {}`, When DeclarationsResolved executes with two workers, Then the trace is A.Before,B.Before,C.Before,stage,publication,A.Declarations,B.Declarations,C.Declarations,A.After,B.After,C.After; all hook thread IDs equal the caller's, Before sees previous completed state, and declaration/After queries see the new publication.

2. **OrdinaryFailureBroadcastsToAll** — new RED
   Given A/B/C, When B independently rejects a Before, declaration, or After hook in three executions, Then C does not receive that ordinary hook, no subsequent stage runs, and the terminal suffix is A.Finished,B.Finished,C.Finished exactly once with failure, attempted stage, and nonempty Error.

3. **CompilerFailureOmitsAfter** — new RED
   Given malformed input `class {` and A/B callbacks, When the failing stage executes, Then no After is sent for that stage, both receive final failure, and Output exposes diagnostics without requiring paired cleanup.

4. **PauseResumeAndTerminalNoOp** — new RED
   Given valid Alpha source, When execution pauses at DeclarationsResolved and later resumes through ByteCodeEmitted, Then the pause produces zero Finished calls and final success produces one per object with empty Error. Repeated RunThrough does not redeliver declarations or completion.

5. **ConstructorAndAbandonmentAreSilent** — new RED
   Given one unprepared Source and valid callbacks, When Builder is constructed, Then no callback runs; the first explicit execution sends one SourceReady failure. Given instead a valid Builder destroyed after an intermediate pause, Then destruction sends no Finished notification.

6. **InvalidRegistrationNeverInvoked** — boundary
   Given a null callback or duplicate A pointer registration, When input is explicitly executed, Then it fails deterministically without invoking invalid entries or invoking A twice; an empty callback list remains valid.

7. **ReentryAndConcurrencyRejected** — new RED
   Given a hook executing on the caller thread, When it attempts nested RunStage/RunThrough and a coordinated second thread attempts advancement before the hook releases, Then both attempts are rejected, no nested stage trace occurs, and the outer operation retains its single terminal outcome.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder_callbacks.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderCallbackTests.cpp
```

**Verification**

Run from the selected workspace root with the Harness context initialized and the affected C++ editor build successful as required by execution conventions.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine.BuilderCallbacks'
    Fast = $true
    TimeoutMs = 600000
}
```

All seven BuilderCallbacks cases execute and pass, including each of the three rejection sites in OrdinaryFailureBroadcastsToAll. Match the manually authored trace and counts; do not infer order from the implementation's stage logger.

**Notes**

Callbacks are borrowed objects. Completion is void, not a second veto channel. Terminal transfer guards are finalized in 3.3; this task does not grant callback-time Take.

## [ ] 3.3 Transfer terminal products with safe retained lifetimes

Gate both existing Take paths and invalidate session borrows without combining the two product owners.

**Outcome**

CompileOutput is takeable after successful/failed terminal execution returns; ModuleDefinitionSet only after final success. No Take in callbacks or at pauses. Taken products retain required source/index lifetimes; dependencies and definition pointers remain explicitly borrowed.

**Interfaces**

Consumes:

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h:35-39
asCBuilder::GetModuleDefinitionSet; asCBuilder::TakeModuleDefinitionSet;
asCBuilder::GetCompileOutput; asCBuilder::TakeCompileOutput;
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session.h:101
asCCompilationSession; // Existing FrozenDefinitionSet raw borrow to clear/guard on transfer.
// Tasks 3.1 and 3.2 produce immutable publication and terminal callbacks.
```

Produces:

```cpp
// Existing signatures retained; stronger transfer timing (glossary).
TUniquePtr<asCCompileOutput> asCBuilder::TakeCompileOutput();
TUniquePtr<asCModuleDefinitionSet> asCBuilder::TakeModuleDefinitionSet();
BuilderResults; // NativeEngine CQTest convention: ...BuilderResults.<CaseName>
```

**Cases**

1. **NoTakeDuringPauseOrCallbacks** — new RED
   Given `class Unit { void Set() {} }`, When both Take methods are attempted at DeclarationsResolved, DefinitionsFrozen, inside ordinary hooks, and inside successful OnBuildFinished, Then each returns null without consuming ownership; after final execution returns both products can be taken.

2. **SuccessTransferClearsBorrows** — new RED
   Given successful Unit compilation, When the definition set is taken, Then repeated Take returns null and session query paths cannot dereference a stale moved definition owner. Destroy the taken set before Builder, then destroy Builder without double destruction or use-after-free.

3. **FailedOutputCanEscape** — new RED
   Given `A.as: class Alpha { void Bad() { Missing(); } }`, When final failure returns and CompileOutput is taken, Then definitions cannot be taken, diagnostics and Alpha/Bad declaration facts remain available, and source anchor resolution still works after Builder/caller-array destruction.

4. **OutputAndDefinitionsAreIndependent** — new RED
   Given successful `class Unit { int32 Value; void Set(int32 V) { Value = V; } }`, When CompileOutput and ModuleDefinitionSet are taken and destroyed in either order, Then each obeys its own ownership, descriptor runtime pointers stay null, Unit TypeInfo has null Engine/TypeId -1, and method bytecode remains owned only by the definition set.

5. **BorrowedDependencyLifetime** — new RED
   Given a successfully taken set for `class First { int32 Value; }`, When a second Builder compiles `class Second { First@ Ref; }` while the first owner remains alive, Then Second resolves First without Engine registration and owns only Second. Reject an unfinished/failed dependency; do not extend the first owner's lifetime merely by retaining Source.

6. **SharedOldVersionSurvivesNewCompile** — new RED
   Given two Builders share an old Source at `A.as`, When one result is taken, both Builders and caller arrays are destroyed, and a new Source at A.as is compiled, Then the old result still resolves the old bytes and the new result resolves the new bytes; repeated Take/RunThrough does not regenerate output or renotify.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_compile_output.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_lifetime.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**/*.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderResultTests.cpp
```

**Verification**

Run from the selected workspace root with the Harness context initialized and the affected C++ editor build successful as required by execution conventions.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine.BuilderResults'
    Fast = $true
    TimeoutMs = 600000
}
```

All six BuilderResults cases execute and pass. Existing NativeEngine transfer consumers in the glob receive only the necessary terminal-stop/ownership adaptation; run them additionally if their assertions change beyond mechanical timing. Capture owner destruction and retained-byte oracles rather than relying on absence of a crash.

**Notes**

CompileOutput remains diagnostic/description-only. Clear or guard FrozenDefinitionSet before its owner can die. Invalidating output queries after transfer must not regenerate the product or send completion again.

## [ ] 4.1 Synchronize the two affected frontend contracts

Promote the verified behavior deltas into their existing capability owners without rewriting unrelated scenarios.

**Outcome**

The builder and source-diagnostics current specs incorporate this Change's accepted input, publication, callback, and lifetime contracts. Repair only their pre-existing clause-detail indentation, preserving unchanged text and ownership. No other specs, archive, or Git actions belong to this task.

**Files**

```diff
 openspec/specs/angelscript/language/frontend/builder/spec.md
 openspec/specs/angelscript/language/frontend/source-diagnostics/spec.md
```

**Verification**

Run from the selected workspace root with the Harness context initialized. Use openspec-sync-specs for the semantic merge; compare preserved scenario text/parentage against the recorded baseline before validation.

```powershell
foreach ($capability in @(
    'angelscript/language/frontend/builder',
    'angelscript/language/frontend/source-diagnostics'
)) {
    $result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @(
        $capability, '--type', 'spec', '--strict', '--json'
    )
    $report = ($result.data.Output -join "`n") | ConvertFrom-Json
    if ($report.summary.totals.failed -ne 0) { throw "Spec validation failed: $capability" }
}
```

Both exact targets pass strict validation; each intended scenario appears once under its owning requirement, delta operation headers are absent from current specs, and unrelated clauses retain their text and parentage. Record the semantic merge comparison with the exact command result.

**Notes**

The baseline indentation failures and their bounded disposition are documented in attachments/data/planning-validation.md. This is future work after all product tasks pass, not permission to synchronize during planning.
