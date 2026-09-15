---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1", "2.3"]
    "2.3": []
    "2.4": ["2.1"]
    "3.1": ["2.1", "2.2", "2.4"]
    "3.2": ["3.1", "3.3"]
    "3.3": ["2.1"]
    "3.4": ["3.2"]
    "4.1": ["3.4", "5.1"]
    "4.2": ["4.4"]
    "4.3": ["4.1"]
    "4.4": ["4.1", "3.3"]
    "5.1": ["2.2", "2.4", "3.4"]
    "6.1": ["1.2", "4.2", "4.3", "5.1"]
    "7.1": ["4.1", "4.3"]
    "7.2": ["4.1", "4.4"]
    "7.3": ["4.2", "4.4"]
    "7.4": ["7.3", "3.3"]
    "7.5": ["7.3", "3.3"]
    "7.6": ["4.1"]
    "7.7": ["4.2", "4.4"]
    "8.1": ["6.1", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7"]
    "8.2": ["8.1"]
---

# Frontend diagnostics, parallel lexing and native tooling

## Goal

Provide uniform diagnostic production, deterministic parallel Lex/PP, rich source-accurate diagnostics, engine-independent semantic queries, and an in-process SDK facade so compilation failures can format Clang-style suggestions and inspect notes/fixes without a language-server process.

## Architecture

Phase Diag emits into explicit fragments; fixed workers run per-file Lex/PP and merge after join. Layer 1 produces `asSDiagnosticGroup` values from a concrete `as_diagnostic_catalog.def` during Builder compilation; Layer 2 renders those groups (Clang-style text, JSON, atomic edits) and runs cursor queries on `asCToolingSession` over an owned `asCAnalysisResult`; Layer 3 is the in-process `asCLanguageService` facade that attaches a compilation result, formats, inspects notes/fixes and applies one alternative in memory. A JSON-RPC/LSP adapter is later work over layers 2 and 3, and no Engine, LLVM dependency or legacy runtime activation is required. See `design.md`.

## Global constraints

- Current baseline: SDK root `Source/AngelscriptRuntime/angelscript`, with `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}`. DefinitionSet and CompileOutput replaced MetadataImage-era Builder ownership; neither compile output nor tooling is an Engine publication. Lambda/source-funcdef syntax stays removed. New planned helpers follow the owning phase, with no new public phase directory.

- Original sixteen completed nodes retain historical GREEN evidence. The user-requested review replan adds remaining acceptance work. This update changes planning only; old passing counts do not prove repairs.
- Read `attachments/INDEX.md`, `design.md` and the owning rows of `attachments/data/diagnostic-migration-inventory.md` before later implementation. The catalog/producer inventory is a coverage aid, not a second execution ledger. Names introduced in design are proposed interfaces, not preexisting APIs.
- Paths in Files are repository-relative. New implementation stays inside the maintained plugin; no `Legacy/**`, existing extension, host project, generated StaticJIT file, Skill or CLI source is included. Keep current canonical AS namespace and stable-key contracts. The separately planned testing framework is not an implementation prerequisite.
- Use current replacement CQTest under `WITH_ANGELSCRIPT_TESTS`, with no ambient AS Engine or legacy force include. New test files below Diagnostics/ and Tooling/ use `TestDir = Angelscript.UnitTest.NativeEngine` and the exact class names listed in each card. The physical subdirectory is not part of the public identity.
- New names use existing `asC/asS/asE` SDK conventions and CQTest area naming; proposed signatures below are future contracts, not claims of existing symbols. Record `Naming assumed` for convention-derived helper names during apply. All commands run from the selected workspace after Harness context setup and an impact-related incremental editor build; creation runs none of them.
- Compatible Ready groups may share a supported common-prefix proving selection. For example, a justified NativeEngine run can cover DiagnosticsPresentation plus DiagnosticsSyntax, and `Angelscript.UnitTest.NativeEngine.Tooling` can cover completion and navigation together.
- Closure follows verify/sync/archive after current-content proof and resolution of both user-requested Reviews. Completed nodes stay checked; added nodes own repairs. Commit/push/workspace actions remain separate.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement / acceptance boundary | Task owner |
|---|---|
| Fragment-bound Diag, move/argument ownership, explicit submission and lexical/PP migration | 1.1 |
| Queued Lex/PP, local error facts, same-spelling identity, all-work continuation and exactly-once stage transition | 1.2 |
| Catalog, owned groups, deterministic warning/limit/failure policy | 2.1 |
| Text/JSON fidelity and real caret suggestions | 2.2 |
| UTF-8/UTF-16, CRLF, malformed-byte and EOF positions | 2.3 |
| Revision/owner/expected-byte checks and atomic alternatives | 2.4 |
| Every current lexical/PP/parser/annotation cause | 3.1 |
| Declaration/type/body reasons, recovery and viable typo suggestions | 3.2 |
| Shared complete/incomplete candidate rules without commit side effects | 3.3 |
| Builder root forwarding, CompileOutput ownership, emission/status fidelity | 3.4 |
| Partial read freeze, input/dependency lifetime, handles/status/cancellation and selection | 4.1 |
| Real scope/member completion and active-formal signature help | 4.2 |
| Token-bound hover and authentic definition targets | 4.3 |
| Isolated incomplete-body cursor context and declaration barrier | 4.4 |
| Producer matrix closure, compile-fix-reanalysis, worker determinism and dormancy | 6.1 |
| Owned in-process format/note/fix facade and feature/owner boundaries | 5.1 |

| Bind navigation to source revision and semantic environment | 7.1 |
| Preserve query status and bounded cooperative cancellation | 7.2 |
| Collect completion from the active scope and grammar context | 7.3 |
| Use authoritative access and receiver rules for members | 7.4 |
| Return owned candidate signatures mappings and viability | 7.5 |
| Audit ownership before exposing readable analysis | 7.6 |
| Prepare declarations once per cursor request | 7.7 |
| Verify repaired acceptance on final content | 8.1 |
| Resolve both user-requested Reviews on the repaired snapshot | 8.2 |

Self-review 2026-09-14: all seven capability deltas and accepted boundaries mapped; placeholder scan clean; inspected consumed symbols and proposed outputs distinguished. Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Establish fragment-bound Diag and migrate lexical/preprocessor production

Producers gain one structured reporting expression while existing lexical/PP IDs, recovery and explicit submission remain observable.

**Outcome**

Implement move-only asCDiagnostic, temporary-friendly streaming and phase Diag wrappers. Migrate lexical and PP production, retaining their IDs, ranges and literal/directive rules. Record local lexical Error facts independently of the global engine for 1.2. Exclude catalogue/groups, Note streaming, Parser/Sema migration, scheduling changes and immediate listeners.

**Interfaces**

Consumes inspected source beneath Plugins/Angelscript/Source/AngelscriptRuntime/angelscript: frontend/Basic/as_diagnostics.h:103 Report, :126 CreateFragment, :127 Submit, :35 argument values, :50 FixIt; frontend/Lexer/as_tokenizer.h:41 Lex and :42 FlushDiagnostics; frontend/Lexer/as_preprocessor.h:89 Process.

Produces accepted N2/N1d/Q8 names and convention-derived helpers/test identity (attachments/drafts/glossary.md):

```cpp
asCDiagnostic asCDiagnosticFragment::Diag(const asCSourceRange& Range, asUINT ID);
asCDiagnostic(asCDiagnostic&& Other) noexcept;
asCDiagnostic(const asCDiagnostic&) = delete;
asCDiagnostic& operator=(const asCDiagnostic&) = delete;
// Member overloads support returned temporary expressions:
asCDiagnostic& asCDiagnostic::operator<<(FStringView Value);
asCDiagnostic& asCDiagnostic::operator<<(int64 Value);
asCDiagnostic& asCDiagnostic::operator<<(bool Value);
asCDiagnostic& asCDiagnostic::operator<<(const asSDiagnosticArgument& Value);
asCDiagnostic& asCDiagnostic::operator<<(const asSDiagnosticFixIt& Value);
asCDiagnostic& asCDiagnostic::operator<<(const asCSourceRange& RelatedRange);
bool asCTokenizer::HasErrors() const;
// Tokenizer::Diag and Process-local PP Diag bind the current fragment.
// Test: Angelscript.UnitTest.NativeEngine.DiagnosticProduction
```

The helper stays in as_diagnostics.h/.cpp. HasErrors is monotonic for that tokenizer and survives Flush. PP's per-call helper cannot place a mutable current-fragment slot on its shared const Process object. Move assignment may remain deleted; the owner reports exactly once.

**Cases**

1. **Temporary chain owns payload** — new RED

    On source `bad`, Diag([0,3), 1001) streams text `token`, int64(-7), bool(true), FromUnsigned(9), RelatedRange [1,2), and a fix replacing [0,3) with `good`. Destroy backing text/fix buffers before Submit. Expect ordered Text(token), Signed(-7), Boolean(true), Unsigned(9), exactly the authored related range and bytes 67 6F 6F 64 after Submit.

2. **Single report and explicit submission** — new RED

    Move a live diagnostic once, destroy the moved-from object, then end its owner's scope. Engine pending count stays zero before fragment Submit and becomes one after it. A no-stream expression also reports one record. Abandoning an unsubmitted fragment contributes none. Copying fails at compile time; flushed-target misuse never emits twice or dereferences released storage.

3. **Local Error survives Flush** — new RED

    Lex A.as bytes 22 61 62 63, an unterminated string. Expect ID 1005 and [0,4), an unterminated token then EOF [4,4), and HasErrors true before/after Flush. Clean B.as `int B;` has HasErrors false even after A submitted to the shared engine.

4. **PP and merge compatibility** — boundary

    Process `#include "X.as"` and assert unsupported-include ID 2014 with primary range [0,15), spanning the complete directive. Submit distinct A/B file fragments in both orders and compare independently expected record payload and SerializeStable. No consumer callback runs per Diag expression.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_preprocessor.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_preprocessor.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticProductionTests.cpp
```

Only reporting and payload lifetime change; dormant producers are excluded.

**Verification**

Run from the selected workspace with Harness context and a fresh impact-related editor build.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticProduction'; Fast = $true; TimeoutMs = 600000 }
```

Discover and pass all DiagnosticProduction cases with exact source/binary evidence. Real tokenizer/PP controls live in this fixture, making its prefix sufficient for this slice.

**Evidence**

RED run `a339bd3bebb14c5d833d9be7e25116d4` after skeleton-only Diag: 4 discovered, 0 succeeded, 4 failed. TemporaryChainOwnsPayload and SingleReportAndExplicitSubmission failed on pending count 0 after Submit; LocalErrorSurvivesFlush failed on HasErrors; PPAndMergeCompatibility failed on empty merged records. Report: `Saved/Harness/Unreal/Runs/a339bd3bebb14c5d833d9be7e25116d4/AutomationReport/index.json`.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticProduction'; Fast = $true; TimeoutMs = 600000 }
```

Run `c47b261491f74449a594cd8079a278e5` after editor build `b2b3350052dd4076b9e83f91205b16c0`: Succeeded, 4/4, 0 failed/skipped/not-run. Cases: TemporaryChainOwnsPayload, SingleReportAndExplicitSubmission, LocalErrorSurvivesFlush, PPAndMergeCompatibility. Report: `Saved/Harness/Unreal/Runs/c47b261491f74449a594cd8079a278e5/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration and adjacent NativeEngine suites: this slice only changes reporting lifetime and local Error facts.

Naming assumed: `asCDiagnostic()` — empty no-op return for flushed-target Diag.

## [x] 1.2 Execute queued Lex and same-thread PP with deterministic joined products

Builder gains fixed workers and batch acquisition while preserving spelling identity, file ownership and later publication gates.

**Outcome**

Use X=WorkerCount and K=LexBatchSize (default 4), each normalized to at least one. X=1 runs on the caller. Lock session Intern separately from work acquisition, run PP after eligible file Lex, finish all work after failure, merge keyed local results after join, and consume PP exactly once at public Preprocessed advancement. Exclude parallel declarations, another PP pool, per-file jobs, lock-free maps and performance guarantees.

**Interfaces**

Consumes inspected source beneath Plugins/Angelscript/Source/AngelscriptRuntime/angelscript: as_builder.cpp:421 RunStage, :432 lexical loop, :456 PP; as_builder.h:32 RunStage and :39 GetPreprocessedSources; frontend/Compile/as_builder_stages.h:21 options and :10 source input; frontend/Basic/as_identifier_table.h:50 Intern; frontend/Lexer/as_preprocessor.h:65 result and :89 Process.

Produces Q15's convention-derived option LexBatchSize and CQTest class ParallelLexPreprocess; retain existing APIs:

```cpp
// Addition to asSBuilderOptions, existing WorkerCount remains:
int32 LexBatchSize = 4;
const asCIdentifierInfo* asCIdentifierTable::Intern(TConstArrayView<uint8> Spelling);
bool asCBuilder::RunStage(asEBuilderStage Stage);
TConstArrayView<asSDirectiveProcessResult> asCBuilder::GetPreprocessedSources() const;
// Uses 1.1 asCTokenizer::HasErrors. Internal work outcomes retain source key,
// lexical/PP products, hard failure, lexical error and PP validity.
// Test: Angelscript.UnitTest.NativeEngine.ParallelLexPreprocess
```

Names follow attachments/drafts/glossary.md and existing PascalCase options/asC/CQTest conventions. No public failure-injection option. A test-local seam over the actual internal worker routine may inject Lex()==false. Table getters need synchronization or documented post-join access. Lexed executes the joined wave; Preprocessed consumes retained results without re-running PP.

**Cases**

1. **Queue and spelling identity** — new RED

    A.as `int Shared;`, B.as `int Shared;` and uneven C.as with 100 repetitions of `int Other;` run with X=1/4 and K=1/4, including reversed registration. Each file appears exactly once in A/B/C order. A/B Shared identifier pointers match within the session. Compare authored token kinds/spellings/ranges including EOF and single-worker projections. Observe at most X workers and no per-file tasks; X=1 runs on the caller.

2. **Local gate and clean product identity** — new RED

    A.as bytes 22 61 62 63 produces 1005; B.as `int B;` is clean. For every X/K setting, B retains valid PP ranges identifying B, A has no eligible PP product, and the joined attempt fails. A compact PP array cannot be zipped with full inputs to associate B with A. No later declaration/definition stage succeeds.

3. **Hard failure drains work** — new RED

    Inject Lex()==false for the first file through the bounded worker seam and queue clean B/C with K=1. Both reach EOF and PP; the failed outcome remains keyed and the attempt fails only after join. Repeat with source acquisition failure. Observe processed keys to prove exactly-once membership rather than infer work from diagnostic counts.

4. **PP failure and exactly-once advancement** — new RED

    A.as `#if defined(\n#endif\n` is lexically valid but fails PP; B.as `int B;` stays valid. Require the real malformed-condition cause and B's retained PP after joined failure. Separately compare clean A/B via RunThrough(Preprocessed) and explicit Lexed then Preprocessed: identical active-token projections, no repeated Process invocation, no duplicate diagnostics. Illegal/repeated transitions do not mutate completed products.

5. **Bounds and retained owners** — boundary

    K=0 normalizes to 1, X=0 normalizes to 1, and empty input does no worker work. After local arrays/queue are destroyed, token spelling remains readable through session/PP owners. Unique-spelling allocation counts agree with X=1, independent of worker arrival. Cross-session pointer values are never compared.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_builder_stages.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_identifier_table.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_identifier_table.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/ParallelLexPreprocessTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp
```

Files are bounded to early phases, identifier synchronization and affected Builder observations; body scheduling and dormant code are excluded.

**Verification**

Run from the selected workspace with Harness context and a fresh impact-related editor build.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

NativeEngine is warranted by shared Builder stage products and identifier ownership. Require all ParallelLexPreprocess cases and affected BuilderStage controls with exact source/binary evidence; aggregate counts do not prove concurrency.

**Notes**

No speedup is promised. Keep FCriticalSection until measurements justify changing the synchronization strategy.

**Evidence**

RED run `1494e61627834976a290783d6aea4d67` after LexBatchSize/debug-seam skeleton: 5 discovered, 0 succeeded, 5 failed. QueueAndSpellingIdentity failed on caller-thread occupancy; LocalGateAndCleanProductIdentity failed because B had no retained PP after A's unterminated string; HardFailureDrainsWork failed because the unused seam still lexed A; PPFailureAndExactlyOnceAdvancement failed on Process count 0 and missing B PP after joined failure; BoundsAndRetainedOwners failed because WorkerCount=0 still failed admission. Report: `Saved/Harness/Unreal/Runs/1494e61627834976a290783d6aea4d67/AutomationReport/index.json`.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Shared NativeEngine run `7b7361eba9804f00826c68c1d042227b` after editor build `9bd5c17c50b943789aabd9decc78fb6a` (codec follow-up build `f74f50f6c3b64081b48fcd265a57aa37` on the same source snapshot before this run): Succeeded, 1116/1116, 0 failed. ParallelLexPreprocess cases: QueueAndSpellingIdentity, LocalGateAndCleanProductIdentity, HardFailureDrainsWork, PPFailureAndExactlyOnceAdvancement, BoundsAndRetainedOwners. Adjacent BuilderStage and BuilderSourceEntry WorkerCount=0 admission now succeed as X=0/K=0 normalize to 1. Report: `Saved/Harness/Unreal/Runs/7b7361eba9804f00826c68c1d042227b/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this slice changes Lex/PP scheduling and identifier locking only.

Naming assumed: `asCBuilder::DebugForceLexFalse` / `DebugForceAcquisitionFailure` — test-local worker seams, not public options. `asCBuilderState::PreprocessedKeys` — keyed compact PP pairing so CollectSource does not zip against full Inputs.

## [x] 2.1 Implement the catalog, owned diagnostic groups and independent policy/failure facts

Flat records currently cannot retain complete root/note/fix groups or independent policy facts.

**Outcome**

The package-wide `.cpp` ownership is **only mechanical consumer adaptation** to the new diagnostic collection/view API; exclude semantic producer migration, parsing/call/type rules, AST/metadata algorithms and all Legacy files. Reserve concrete catalog entries for every inventory reason without claiming that the producer uses them yet. Keep old generic meanings reserved. Move presentation implementation behind `as_diagnostic_renderer.*` so 2.2 can work without editing collection semantics.

Consumes the Diag protocol and local lexical failure facts from 1.1/1.2; preserve both when evolving payloads and policy. Produces `asSDiagnosticGroup`, `asCDiagnosticResult`, immutable `asSDiagnosticOptions`, concrete catalog descriptors, optional source validation and an adapter for existing observation consumers. New class: `DiagnosticsCore`.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.h:59,95,117`. Produces the proposed interface shape below and public test class `DiagnosticsCore` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
// Proposed immutable value authority; each returned snapshot owns its source leases.
TSharedRef<const asCDiagnosticResult, ESPMode::ThreadSafe> asCDiagnosticsEngine::CaptureResult() const;
TConstArrayView<asSDiagnosticGroup> asCDiagnosticResult::GetGroups() const;
// asSDiagnosticOptions and failure/coverage summary are values owned by this result.
```

**Cases**

1. **Owned nonlocated group** — new RED

    Input error before tokenization; capture a result, release source/engine references, then inspect it. Expect one nonlocated primary with complete notes/fixes; a provided foreign range is rejected.

2. **Deterministic policy** — new RED

    Submit error groups B then A versus A then B, with limit 1. Expect the same complete A group, truncation=true and language failure even if its display is suppressed. Disabled warning + Werror remains disabled.

3. **Hidden lexical failure still gates only its own file** — new RED

    Under display suppression, A.as containing bytes 0xC0,0xAF still has a local lexical failure and no eligible PP product; clean B.as containing `int B;` completes PP. Overall compilation fails even if the visible list is empty. With disabled warning plus Werror, the disabled warning does not create a lexical failure.

4. **Additional accepted boundaries** — boundary

    Cases: primary in `A.as` with a note in `B.as` stays one group under reversed fragment submission and 1/4 workers; an explicit nonlocated input error is retained; a provided foreign-snapshot range is rejected; disabled warnings, per-ID/group/global precedence and Werror preserve warning identity; a hidden error still fails validity; limit 1 retains a whole primary/notes/fixes group and marks truncation; retained diagnostic rendering data survives release of caller source references. Existing SourceDiagnostics byte-range/provenance tests remain regression controls.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostic_catalog.def
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostic_renderer.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostic_renderer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_compile_output.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_builder_stages.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticCoreTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/SourceDiagnosticsTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/*/*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/*/*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/data/diagnostic-migration-inventory.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsCore`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Evidence**

DiagnosticsCore tests and catalog/group/policy implementation were introduced together; no separate pre-implementation Automation RED run is recorded for this node.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run `62a878a172d4468d9794f6aa6015963f` after editor build `e367eff3e28f497d990e6f221a7b66a4`: Succeeded, 1120/1120. DiagnosticsCore cases: OwnedNonlocatedGroup, DeterministicPolicy, HiddenLexicalFailureStillGatesOwnFile, AcceptedBoundaries. SourceDiagnostics byte-range/provenance controls remained green. Report: `Saved/Harness/Unreal/Runs/62a878a172d4468d9794f6aa6015963f/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this node changes diagnostic collection/view and catalog reservation.

Naming assumed: `asCDiagnosticFragment::DiagUnlocated` — explicit nonlocated primary; `asCDiagnosticFragment::ReportGroup` — complete group admission; `asCBuilder::CaptureDiagnosticResult` — snapshot export used by later facade tasks.

## [x] 2.2 Render complete diagnostic groups as Clang-style text and versioned JSON

Diagnostic consumers need faithful group presentation from the retained source revision.

**Outcome**

Render the 2.1 immutable result using 2.3 positions. Typed arguments, notes, highlights and fix alternatives survive text/JSON observation. Excludes source edit application and the SDK facade.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.h:59; prerequisite 2.1 and 2.3 outputs`. Produces the proposed interface shape below and public test class `DiagnosticsPresentation` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
FString asCDiagnosticRenderer::Format(const asCDiagnosticResult& Result, int32 GroupIndex) const;
FString asCDiagnosticRenderer::SerializeJson(const asCDiagnosticResult& Result) const;
```

**Cases**

1. **Independent presentation oracle** — new RED

    Construct a Cout primary and Count note on `A.as` bytes `int Count=1; Cout;`. Compare against this independently authored text (primary at byte 13, note at byte 4), and individually assert JSON fields including two alternatives and revision `9007199254740993` as a string:

    ```text
    A.as:1:14: error: unresolved reference 'Cout'
    int Count=1; Cout;
                 ^~~~
    A.as:1:5: note: did you mean 'Count'?
    int Count=1; Cout;
        ^~~~~
    ```

2. **Additional accepted boundaries** — boundary

    Presentation acceptance: exact JSON preservation of semantic arguments, notes, highlights, two alternatives and replacement bytes; a 64-bit revision beyond JavaScript's exact integer range remains a string; source-less text has no fake line; tab/multiline carets and malformed-byte display remain deterministic. For the decoded Unicode sequence `A\u4E2D\U0001F600\r\nZ` encoded as UTF-8, byte offset 8 maps to UTF-8 `(0,8)` and UTF-16 `(0,4)`, offset 10 maps to `(1,0)`, EOF 11 maps to `(1,1)`; offset 9 and an interior UTF-16 surrogate position are rejected. Preserve native one-based byte presentation APIs.

    Constructed unresolved-name fixture: primary range on `Cout`, note and unique fix naming `Count`. Independently authored expected text must include the invalid identifier, a caret under that use, a note naming `Count` and a caret or range on the suggestion. Do not assert by formatting twice and comparing the formatter to itself.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostic_renderer.*
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticPresentationTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticsPresentation'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsPresentation`; retain exact case results and source/binary identity. This focused prefix proves the independently acceptable output; it does not stand in for sibling product cases.

**Evidence**

Presentation tests and renderer Format/SerializeJson landed together before the first Automation run; no separate pre-implementation RED run is recorded for this node.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticsPresentation'; Fast = $true; TimeoutMs = 600000 }
```

Run `0eb80b235ab949c4a9977416640eda8d` after editor build `0c5ad32f3ed44ab6be2ab8f1c8f4cacd`: Succeeded, DiagnosticsPresentation.IndependentPresentationOracle and DiagnosticsPresentation.AcceptedPresentationBoundaries. Report: `Saved/Harness/Unreal/Runs/0eb80b235ab949c4a9977416640eda8d/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration and the full NativeEngine suite: this node only adds presentation adapters over the 2.1 result.

Naming assumed: none beyond the card Interfaces. File-local renderer helpers remain unnamed public API.

## [x] 2.3 Provide exact UTF-8 and UTF-16 position conversion

Native byte offsets need an explicit, checked editor-coordinate boundary.

**Outcome**

Add snapshot-bound conversion with explicit failure and native byte authority. Excludes rendering and edit application.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_snapshot.h; existing byte-range source authority`. Produces the proposed interface shape below and public test class `DiagnosticsPosition` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
// Proposed zero-based positions; Out is unchanged on failure.
bool asCSourcePositionCodec::ByteToPosition(asCSourceLocation Byte, bool bUtf16, int32& Line, int32& Column) const;
bool asCSourcePositionCodec::PositionToByte(asCSourceFileID File, int32 Line, int32 Column, bool bUtf16, asCSourceLocation& Out) const;
```

**Cases**

1. **Unicode and CRLF** — new RED

    UTF-8 bytes for `A\u4E2D\U0001F600\r\nZ`: byte 8 -> UTF-16 (0,4), byte 10 -> (1,0), EOF 11 -> (1,1). Byte 9, byte 2 and UTF-16 (0,3) are rejected; output parameters stay unchanged.

2. **Malformed native source** — new RED

    Bytes C0 AF remain addressable as native byte ranges, but Unicode conversion fails explicitly; no clamping or fabricated character count.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_position_codec.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_position_codec.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticPositionTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticsPosition'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsPosition`; retain exact case results and source/binary identity. This focused prefix proves the independently acceptable output; it does not stand in for sibling product cases.

**Evidence**

RED run `beef1b266e844855a0f513bd501c91d1` after always-false codec skeleton: UnicodeAndCRLF failed on ByteToPosition; MalformedNativeSource already passed because conversion failed closed. Report: `Saved/Harness/Unreal/Runs/beef1b266e844855a0f513bd501c91d1/AutomationReport/index.json`.

GREEN shared NativeEngine run `7b7361eba9804f00826c68c1d042227b` after editor build `f74f50f6c3b64081b48fcd265a57aa37`: DiagnosticsPosition.UnicodeAndCRLF and DiagnosticsPosition.MalformedNativeSource both Success. Report: `Saved/Harness/Unreal/Runs/7b7361eba9804f00826c68c1d042227b/AutomationReport/index.json`. Card prefix `Angelscript.UnitTest.NativeEngine.DiagnosticsPosition` is covered by this shared selection on the same source/binary snapshot. Intentionally omitted Quick/Performance/Integration: codec is snapshot-local conversion only.

Naming assumed: `asCSourcePositionCodec(const asCSourceManager&)` — binds the existing source manager as the snapshot authority until 2.4 introduces `asCSourceSnapshot`.

## [x] 2.4 Apply revision-bound fix alternatives atomically in memory

Fix alternatives need complete precondition checking before a new snapshot is exposed.

**Outcome**

Validate the whole alternative, including owner, bytes and revision, before creating any output. Excludes producer suggestion ranking and filesystem writes.

**Interfaces**

Consumes: `prerequisite 2.1 fix values and snapshot-bound byte ranges`. Produces the proposed interface shape below and public test class `DiagnosticsEdit` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
// Proposed atomic operation; false returns no output and mutates no input.
bool asCSourceEditApplier::Apply(const asCDiagnosticResult& Owner, const asSDiagnosticFixAlternative& Fix,
    TSharedPtr<const asCSourceSnapshot, ESPMode::ThreadSafe>& OutSnapshot) const;
```

**Cases**

1. **Atomic correction** — new RED

    For `int Cout=1` apply `Cout` -> `Count` plus EOF `;` as one alternative. Expect exactly `int Count=1;` in a new snapshot and original bytes/revision unchanged.

2. **All-or-nothing preconditions** — new RED

    Use two-file edits where the second has stale revision or wrong original bytes. Expect no new snapshot and no partial first-file edit. Also reject overlap, conflicting same-point inserts and foreign owner.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_edit.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_source_edit.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticEditTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticsEdit'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsEdit`; retain exact case results and source/binary identity. This focused prefix proves the independently acceptable output; it does not stand in for sibling product cases.

**Evidence**

Edit tests and `asCSourceEditApplier` landed together before the first Automation run; no separate pre-implementation RED run is recorded for this node.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticsEdit'; Fast = $true; TimeoutMs = 600000 }
```

Run `2fb17b4e15ab4cbfb37bc4e7481e90fa` after the same editor build `0c5ad32f3ed44ab6be2ab8f1c8f4cacd`: Succeeded, DiagnosticsEdit.AtomicCorrection and DiagnosticsEdit.AllOrNothingPreconditions. Report: `Saved/Harness/Unreal/Runs/2fb17b4e15ab4cbfb37bc4e7481e90fa/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this node only applies in-memory snapshot edits.

Naming assumed: `asCSourceSnapshot` — immutable wrapper around `asCSourceManager` so Apply can return a new owner without exposing a raw manager.

## [x] 3.1 Migrate every lexical, preprocessing, parser and annotation-collection cause with precise recovery and safe delimiter proposals

Syntax producers must explain the real cause and continue at grammar-owned recovery boundaries.

**Outcome**

Lexical/PP call sites already use 1.1 Diag; enrich their catalogue payloads without reverting to hand-filled records. Add Parser::Diag forwarding to Sema::Diag and retain one fragment per owning phase. Sema ownership here is limited to parser reporting/recovery and annotation collection; do not implement the remaining semantic causes owned by 2.2. Existing test-folder changes are diagnostic assertion/fixture migrations, not unrelated language expansion. New class: `DiagnosticsSyntax`.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h:57; frontend/Lexer/as_tokenizer.h; frontend/Parser/as_parser.h`. Produces the proposed interface shape below and public test class `DiagnosticsSyntax` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asCRecoveryDecl* asCSema::ActOnRecovery(asCSourceRange Range, FString Message, asUINT DiagnosticID = 3001);
// Existing adapter above becomes catalog/group reporting from 2.1; every source branch
// produces its own catalog cause and typed arguments, never serialized diagnostics.
```

**Cases**

1. **Real delimiter recovery** — new RED

    Compile `int F(){ return 1 } int G(){ return 2; }`. Expect one specific missing-semicolon cause, insertion immediately after 1, and retained independent G; applying is task 1.4.

2. **Silent annotation and malformed bytes** — new RED

    Feed invalid parameter annotations through real collection and C0 AF through the lexer. Require actual structured cause/range per independent root and bounded token progress, not only invalid flags.

3. **Additional accepted boundaries** — boundary

    Concrete cases: byte sequence `0xC0,0xAF` advances and diagnoses malformed UTF-8 without a second semantic literal error; unclosed string/comment selects the original bytes; `#if defined(\n#endif` reports its malformed condition while an unknown flag in an unevaluated operand retains current short-circuit behavior; unexpected/duplicate/missing conditional directives have distinct causes and paired locations where available. `int F(){ return 1 } int G(){ return 2; }` proposes a semicolon immediately after `1`, preserves `G`, and does not claim `F` valid. Invalid parameter annotation must produce a real structured diagnostic instead of only an invalid bit. Removed syntax remains rejected, while comments/strings/skipped branches retain their current meaning.

    The inventory's complete declaration/expression/statement reason lists are mandatory additional cases, including generic helper `false` returns and every `MalformedCondition` branch. Existing valid lexer/token-boundary, annotation/delegate/event and control-flow cases are regression controls, not new RED claims.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_preprocessor.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostic_catalog.def
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticSyntaxTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/*.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/**
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/data/diagnostic-migration-inventory.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsSyntax`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Evidence**

Implementation and `DiagnosticsSyntax` landed together; no separate pre-implementation RED run is recorded for the inventory table expansion. An earlier NativeEngine run `22727648a44a4eb9b5129b9c2c02d03f` failed SilentAnnotationAndMalformedBytes and AcceptedSyntaxBoundaries when lexer/PP IDs were asserted through Builder `CaptureDiagnosticResult()`; those fixtures now use tokenizer/preprocessor collection and session groups.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run `eedc121fa6b34e7c8a4bc3a11c3e9961` after editor build `c8d3a3acfee94c8a894d32def3cbd298`: Succeeded, 1129/1129. DiagnosticsSyntax.RealDelimiterRecovery, DiagnosticsSyntax.SilentAnnotationAndMalformedBytes, and DiagnosticsSyntax.AcceptedSyntaxBoundaries all Success. Adjacent DeclarationsCollection, Preprocessor, Lexer, and Bodies controls remained green. Report: `Saved/Harness/Unreal/Runs/eedc121fa6b34e7c8a4bc3a11c3e9961/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this node migrates syntax/annotation producers and their assertion adapters.

Naming assumed: `MalformedDeclaration` / `MalformedNamespace` / `MalformedRecord` (3144–3146) — catalog IDs for previously silent parser helper `false` returns. `asCSema::ReportSyntax` — declaration/body catalog reporter with optional semicolon FixIt. `asDiagnosticIdFromSyntaxReason` — hyphenated parser-reason lookup.

## [x] 3.2 Migrate semantic and declaration-resolution causes with recovery and viable suggestions

Generic semantic reasons and text-only declaration failures must become structured causes.

**Outcome**

Use the current Sema/Session work-item fragment for Diag; remove one-record-one-fragment production. Migrate Sema and CompilationSession producers using 3.3 assessment. Preserve independent recovery, distinct type-resolution reasons, warning identity and viable typo notes/fixes. Builder aggregation is owned by 2.4.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session.h:37; frontend/Sema/as_sema.h:159; 3.3 assessment`. Produces the proposed interface shape below and public test class `DiagnosticsSemantic` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asCQualType asCCompilationSession::ResolveTypeSyntax(const asSTypeSyntax& Syntax, const asCDecl& Scope);
// Keep this existing convenience boundary; add structured resolution failure values
// internally and carry original failing syntax/node, candidate reasons and related ranges
// into the 2.1 catalog groups. Normal commit consumes the 3.3 assessment.
```

**Cases**

1. **Viable typo fix** — new RED

    Compile `int F(){ int Count=1; return Cout; }`. Expect unresolved-reference, visible Count note and unique one-character replacement. Equal-distance Count/Court candidates yield advisory notes and no applicable fix.

2. **Distinct semantic causes** — new RED

    Use unknown `Missing` type, enum `A=1/0`, and a duplicate declaration across A.as/B.as. Assert different catalog identities, actual failing ranges, expected/actual type values where meaningful, and related original declaration.

3. **Additional accepted boundaries** — boundary

    Additional semantic coverage: `int F(){ int Count=1; return Cout; }` gives an unresolved-name root, one viable `Count` suggestion and its exact edit; adding equally viable `Court` makes the suggestion advisory. Distinct unknown-type, generic-arity and invalid-qualifier inputs produce distinct underlying causes. Duplicate declarations in `A.as`/`B.as` attach the conflicting ranges in stable order. A failed conversion exposes actual/expected qualified types. Call `Pick(1,2)` against one-parameter overloads to prove candidate arity reasons; existing nonnumeric conversion, `out`/`inout`, named/default argument, access, receiver-const and list-factory fixtures prove each candidate rejection family.

    Preserve every inventory cause, including constant divide-by-zero versus invalid shift/cycle/budget, inheritance cycle versus depth budget, access policy errors and the three actual warning families. A host candidate with unsupported default must not abort inspection of a valid later candidate. Assess a complete call twice and assert the same candidate/rank with no formal AST/diagnostic/image changes; only the normal commit creates conversion/default nodes.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostic_catalog.def
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticSemanticTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/**
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/data/diagnostic-migration-inventory.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsSemantic`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Evidence**

Adjacent NativeEngine run `2cf7bd6cf1ac49dbaeb3904549f0e83a` after the first producer landing: 1132 discovered, 1127 succeeded, 5 failed. DiagnosticsSemantic cases were already green; DeclarationsLanguageForms exact-count fixtures and DiagnosticsSyntax.AcceptedSyntaxBoundaries (`break` still expected GenericSemantic 4001) failed on extra session groups and the new `break-outside-control` catalog ID. Report: `Saved/Harness/Unreal/Runs/2cf7bd6cf1ac49dbaeb3904549f0e83a/AutomationReport/index.json`.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run `55bdf3b6fc58473ab55df8614c0bb450` after editor build `47ce9354203c4043b9049c1b42775d19`: Succeeded, 1132/1132, 0 failed/skipped/not-run. Cases: DiagnosticsSemantic.ViableTypoFix, DiagnosticsSemantic.DistinctSemanticCauses, DiagnosticsSemantic.AcceptedSemanticBoundaries. Adjacent DeclarationsLanguageForms, DiagnosticsSyntax, CallAssessment, and Bodies controls remained green. Report: `Saved/Harness/Unreal/Runs/55bdf3b6fc58473ab55df8614c0bb450/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this node migrates semantic/declaration producers and their assertion adapters.

Naming assumed: `asDiagnosticIdFromSemanticReason` — hyphenated session/sema reason lookup. `asCCompilationSession::SubmitSemanticGroup` — mapped-ID group submit that leaves unmapped Fail strings on StableDiagnostics only. `asCSema::AttachTypoSuggestions` — distance-1 visible-name notes and a unique SourceEdit. `asCCompilationSession::ResolveStructuredType` `OutReason` — distinct unresolved-type / generic-arity / invalid-qualifier causes.

## [x] 3.3 Extract shared non-mutating script and host call assessment

Current call resolution mixes candidate probing with diagnostic and AST mutation.

**Outcome**

Separate candidate evaluation from selected-call commit for current supported calls, constructors, indirect signatures and list initializers. Complete and incomplete modes share the current language rules.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h:159,162 (private mutating resolvers)`. Produces the proposed interface shape below and public test class `CallAssessment` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
// Proposed request and result types live in as_call_assessment.h; no formal AST writes.
asSCallAssessment asCSema::AssessCall(const asSCallAssessmentRequest& Request) const;
// Request owns argument facts, explicit scope/receiver and complete/incomplete mode.
// Result owns asSCandidateAssessment values, actual-to-formal mapping and rejection reasons.
```

**Cases**

1. **Complete and incomplete mapping** — new RED

    For `int Pick(int First,int Second=2);`, assess `Pick(Second:4,First:3)` -> authored mapping [1,0]. Assess `Pick(1, |` in incomplete mode -> future Second is unknown, not missing-required; duplicate supplied First is still rejected.

2. **Candidate-local failure and immutability** — new RED

    Host overload A requires an unsupported default; B accepts the supplied int. B stays viable. Two assessments leave AST node count, formal projection, diagnostic groups and definition projection unchanged; ordinary selected commit still materializes required conversions.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_call_assessment.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_call_assessment.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_conversion.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_initializer.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/CallAssessmentTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/FrozenHostSemanticTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `CallAssessment`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Evidence**

RED run `905bc18fd65d4d08b79ae01e8feb90d4` after empty `AssessCall` skeleton: 2 discovered, 0 succeeded. CompleteAndIncompleteMapping and CandidateLocalFailureAndImmutability failed on empty candidate lists. Report: `Saved/Harness/Unreal/Runs/905bc18fd65d4d08b79ae01e8feb90d4/AutomationReport/index.json`.

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run `e260e9ae0cf04e34a7a21e52750f8efa` after editor build `39cb2bb130d043909a0515bf0813be8e`: Succeeded, 1126/1126. CallAssessment.CompleteAndIncompleteMapping and CallAssessment.CandidateLocalFailureAndImmutability both Success. Adjacent Bodies and FrozenHostSemantics controls remained green. Report: `Saved/Harness/Unreal/Runs/e260e9ae0cf04e34a7a21e52750f8efa/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this node extracts assessment from existing call resolution.

Naming assumed: `asSCallAssessmentRequest`, `asSCallArgumentFact`, `asECallAssessmentMode`, `asECandidateRejection`, `asEArgumentSlotKind` — request/result vocabulary for complete/incomplete assessment. `asCSema::AssessScriptCandidate` / `AssessHostCandidate` / `AssessIndirectCandidate` — private per-candidate evaluators.

**Follow-up disposition**

needs_followup: 7.5. Preserve original completion/run history; these nodes own unmet acceptance. See `attachments/replans/replan-20260915-100735-tooling-review-followups.md`.

## [x] 3.4 Retain diagnostic results and exact failures across Builder and CompileOutput

Builder and CompileOutput currently lose group ownership and exact stage failure details.

**Outcome**

Use shared immutable diagnostic snapshots for stage views and CompileOutput. Preserve failure facts separately from display and API rejection. Extend the existing emission boundary only to retain its structured failure; VM instruction coverage does not expand.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h; as_compile_output.h:22; as_bytecode_emitter.h:14,32,44`. Produces the proposed interface shape below and public test class `DiagnosticsBuilder` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
TSharedRef<const asCDiagnosticResult, ESPMode::ThreadSafe> asCCompileOutput::GetDiagnosticResult() const;
// Proposed replacement result accessor; old GetDiagnostics is a deprecated flat projection.
// Extract one internal stage-ingestion helper consumed by Builder and its fixture.
// Stage results retain asEByteCodeEmissionStatus + asSByteCodeEmissionFailure fields,
// metadata/verifier statuses and group identities; accepted-stage facts are separate
// from a rejected RunStage/RunThrough request status.
```

**Cases**

1. **Single root through CompileOutput** — new RED

    Compile the real Cout fixture; take CompileOutput, destroy Builder and diagnostic collector, then read groups. Expect the same root identity and notes/fixes once, no 5001/3003 wrapper, and failure facts despite hidden display.

2. **Emission detail reaches consumer** — new RED

    Use the actual direct-emitter control `VMSourceAdmissionTests.cpp::ResourceBudgetReturnsResourceLimit`: `int Run() { return 42; }` with MaxFrameDWords=1 yields ResourceLimit. Feed that real emission result through the extracted stage-ingestion helper and assert original FunctionKey/NodeKind/StableSourceKey/StableFragmentKey and diagnostic groups. Separately drive the ordinary Builder ByteCodeEmitted path to assert it uses the same ingestion; no configurable Builder-emission API is assumed. A test-local seam may observe ingestion but must not fabricate the emitter failure or borrow the first token as its range.

3. **Nonpoisoning rejected request** — new RED

    After successful SourceReady input, request an illegal later stage directly. Expect rejected request status, unchanged accepted stage/facts, then the legal sequence remains usable. A real hidden language failure still blocks definitions; Werror does not add recovery nodes.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_compile_output.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_builder_stages.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_definition_consumer.*
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticBuilderTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/DefinitionConsumerTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsBuilder`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Evidence**

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run `bb999f72954f4b77af4945819188d674` after editor build `f72a463b32ee4178b7314c44dd29fbd7`: Succeeded, 1135/1135, 0 failed/skipped/not-run. Cases: DiagnosticsBuilder.SingleRootThroughCompileOutput, DiagnosticsBuilder.EmissionDetailReachesConsumer, DiagnosticsBuilder.NonpoisoningRejectedRequest. Focused DiagnosticsBuilder run `a5dde7606f744b24ae4bcc88cf748ec5` was 3/3. Adjacent Builder, VMSourceAdmission, and CompileLifecycle controls remained green. Report: `Saved/Harness/Unreal/Runs/bb999f72954f4b77af4945819188d674/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this node retains CompileOutput snapshots and emission ingestion.

Naming assumed: `as_bytecode_emission.h` — shared emission status/failure types without a Builder include cycle. `asIngestByteCodeEmissionResult` — single stage-ingestion helper used by ByteCodeEmitted and the fixture. `asCCompileOutput::GetDiagnosticResult` / `ReplaceDiagnosticResult` — retained snapshot plus derived flat VisibleGroups projection.

## [x] 4.1 Own readable partial analysis and precise token-to-binding selection

Tooling must own all data it traverses and distinguish safe partial reads from valid compilation.

**Outcome**

Produce the design facade/result/status contracts, real Analyze, owned input closure and token/reference selection. Query methods remain explicitly unavailable until their respective owner tasks; 4.4 owns isolated cursor parsing. A successful read freeze never implies valid AST sealing. Create Complete/GetSignatureHelp unavailable stubs only in as_tooling_completion.cpp and GetHover/FindDefinition unavailable stubs only in as_tooling_navigation.cpp; 4.2/4.3 replace their own file definitions.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_context.h:59; frontend/Compile/as_compilation_session.h; as_module_definition_set.h:125,200`. Produces the proposed interface shape below and public test class `ToolingAnalysis` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
// Proposed owner; transfer unique sets, retain the whole explicit dependency closure.
asCToolingSession(TSharedRef<const asSAnalysisInputs, ESPMode::ThreadSafe> Inputs);
asSAnalysisResponse asCToolingSession::Analyze(const asSCancellationToken& Cancel);
bool asCASTContext::FreezeForTooling();
// asCAnalysisResult owns session, source/token/identifier/type storage and inputs;
// as_semantic_selection maps bound token spans to result-local handles after worker join.
```

**Cases**

1. **Retained ownership closure** — new RED

    Analyze script use of frozen host/dependency types, release Builder and all caller references, and traverse result/type/source data. All referenced unique sets remain alive through the owning input bundle; raw unretained dependencies reject analysis.

2. **Partial read freeze** — new RED

    Analyze `int F(){ return Missing; } int G(){ return 2; }`; join workers and freeze readable result. G is inspectable, late allocation/mutation is rejected, normal VerifyAST/codec/DefinitionsFrozen still reject the erroneous graph.

3. **Identity and cancellation** — new RED

    Different analysis with equal FileID or identical bytes but different host inputs rejects foreign handles. Pre-cancelled and bounded mid-analysis cancellation return Cancelled with explicit coverage, never Success(empty).

4. **Additional accepted boundaries** — boundary

    Additional ownership controls:  retain source/AST/type/host data after releasing caller Builder/input/definition references; traverse a recovery-containing result after worker join while normal AST codec/DefinitionsFrozen reject it; reject a foreign handle even with equal FileID or identical bytes under different host options; cancellation before analysis and during bounded work reports Cancelled, not Success(empty); invalid byte/EOF positions are distinguished.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_navigation.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_types.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_analysis_result.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_analysis_result.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_verifier.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_verifier.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingAnalysisTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/NativeToolingTestSupport.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/AST/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `ToolingAnalysis`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Evidence**

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Focused ToolingAnalysis run `52376a1aed3f45999df08aeedc5cde35` after editor build `6dcee4bcb3994181a988eb3ca945d860`: Succeeded, 3/3. NativeEngine verify `3538cb5da4f94c7ea9ad9c59c44edada` after the same binary: Succeeded, 1141/1141, 0 failed/skipped/not-run. Cases: ToolingAnalysis.RetainedOwnershipClosure, ToolingAnalysis.PartialReadFreeze, ToolingAnalysis.IdentityAndCancellation. First landing `e4f2d0e910cd46509b604236d1fa2899` failed IdentityAndCancellation (same AnalysisID across sessions) and RetainedOwnershipClosure (host value-type layout). Fixes: OwnsHandle also checks AST ContextID; host fixture uses `asOBJ_REF | asOBJ_SCRIPT_OBJECT` plus `ValidateFrozenDefinitions`; script uses `HostValue@`. Report: `Saved/Harness/Unreal/Runs/3538cb5da4f94c7ea9ad9c59c44edada/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this node owns analysis freeze and handle identity.

Naming assumed: `as_tooling_types.h` status/query/input/result shells. `asCAnalysisResult` ownership of Builder/session/inputs. `FreezeForTooling` distinct from `IsSealed`. `as_tooling_completion.cpp` / `as_tooling_navigation.cpp` unavailable stubs.

**Follow-up disposition**

needs_followup: 7.1, 7.2, 7.6. Preserve original completion/run history; these nodes own unmet acceptance. See `attachments/replans/replan-20260915-100735-tooling-review-followups.md`.

## [x] 4.2 Implement contextual completion and signature help using shared assessment

Incomplete source must produce real scope-aware completion and active-formal signature help.

**Outcome**

Consumes frozen facade/result/context contracts from 4.4 and assessment from 3.3; implements only `Complete` and `GetSignatureHelp`. New class: `ToolingCompletion`. Keep area-local fixture helpers in that class so 4.3 need not share mutable helper files.

**Interfaces**

Consumes: `prerequisite 4.4 cursor context and 3.3 assessment`. Produces the proposed interface shape below and public test class `ToolingCompletion` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asSCompletionResult asCToolingSession::Complete(asSQueryPosition Position, const asSCancellationToken& Cancel);
asSSignatureHelpResult asCToolingSession::GetSignatureHelp(asSQueryPosition Position, const asSCancellationToken& Cancel);
```

**Cases**

1. **Scope and member completion** — new RED

    For `class Item { int Value; }` and `Item obj; obj.|`, return accessible Value with exact replacement span; exclude inaccessible receiver members. In nested Outer/Inner scopes return Inner and nearest shadow, excluding later locals.

2. **Real signature context** — new RED

    For Pick defaults/named arguments, `Pick(Second: |` selects formal Second. `Outer(Inner(1, |` selects Inner. Completed-call applicability matches normal compilation; comments/strings/inactive code return successful empty semantic completion.

3. **Additional accepted boundaries** — boundary

    Cases: accessible `class Item { int Value; }` member appears after `Item obj; obj.|`; private/incompatible receiver members do not appear as applicable. Inner locals shadow outer names, later locals are absent before their declaration, and a known expected type influences deterministic ranking without hiding candidates when the type is unknown. Partial identifiers have exact replacement ranges; comments/strings/inactive bodies yield empty ordinary semantic completion; namespace/type/keyword contexts use real grammar.

    For `int Pick(int First, int Second=2);` test cursor positions in `Pick(|`, `Pick(1, |` and `Pick(Second: |`; active formal mapping must follow `Second` rather than textual ordinal zero. The complete control `Pick(Second: 4, First: 3)` maps authored arguments to formal ordinals 1 then 0, matching the existing `NamedArgumentsReorderByParameterWithoutLosingAuthoredOrder` fixture. Nested `Outer(Inner(1, |` selects Inner; moving the cursor outside Inner selects Outer. Compare completed-call candidates and selected overload with ordinary compilation; retain candidates whose future arguments are merely unknown. Cover list-initializer context, explicit rejection of removed Lambda syntax, and frozen-host candidates, including unsupported defaults on an unrelated candidate. Assert formal AST, diagnostics and definition projections unchanged after each query.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCompletionTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCompletion'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `ToolingCompletion`; retain exact case results and source/binary identity. This focused prefix proves the independently acceptable output; it does not stand in for sibling product cases.

**Evidence**

RED/GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCompletion'; Fast = $true; TimeoutMs = 600000 }
```

First landing `f719088c9a714d3d882b01ab7075204c` after build `02a75ef9f4994761b383a74f4aeca726`: RealSignatureContext green; ScopeAndMemberCompletion failed on `obj.Va|` because a present member identifier did not record the receiver. Parser now notes the member base on every `Dot`. GREEN `3d92470c754b47af8de674e36a2773b3` after build `bdb6365508e54414b4777adde46f7849`: Succeeded, 2/2. Cases: ToolingCompletion.ScopeAndMemberCompletion, ToolingCompletion.RealSignatureContext. Report: `Saved/Harness/Unreal/Runs/3d92470c754b47af8de674e36a2773b3/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is ToolingCompletion.

Naming assumed: `asSSignatureHelpResult::CallName` — distinguishes nested Inner versus Outer when both share ActiveParameter 1. `asSCursorContext::CallArgumentNames` — authored names for AssessCall Incomplete.

**Follow-up disposition**

needs_followup: 7.3, 7.4, 7.5. Preserve original completion/run history; these nodes own unmet acceptance. See `attachments/replans/replan-20260915-100735-tooling-review-followups.md`.

## [x] 4.3 Implement precise hover and definition queries over retained semantic bindings

Navigation must select the bound token and return authentic retained semantic information.

**Outcome**

Consumes the sealed-for-reading result and semantic selection primitives from 4.1; implements only `GetHover` and `FindDefinition`. New class: `ToolingNavigation`. No workspace reference index or documentation parser is introduced.

**Interfaces**

Consumes: `prerequisite 4.1 retained graph and token/reference selection`. Produces the proposed interface shape below and public test class `ToolingNavigation` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asSHoverResult asCToolingSession::GetHover(const asCAnalysisResult& Result, asSQueryPosition Position, const asSCancellationToken& Cancel);
asSDefinitionResult asCToolingSession::FindDefinition(const asCAnalysisResult& Result, asSQueryPosition Position, const asSCancellationToken& Cancel);
```

**Cases**

1. **Actual identifier binding** — new RED

    In `int F(){ int Value=1; return Value; }`, hover the return use: int local Value, definition at local declaration. At `Value|;`, containing semicolon returns empty. At bound identifier EOF with no containing token, end affinity is allowed.

2. **Host location absence** — new RED

    Query an explicitly supplied frozen host callable with signature but no source: useful hover and NoSourceTarget, no invented script location. Real cross-file definitions precede declarations and deduplicate.

3. **Additional accepted boundaries** — boundary

    Cases: `int F(){ int Value=1; return Value; }` resolves the return use to the local declaration with type `int`, not the enclosing function; inner shadowed names and qualified/member components select their actual declarations; resolved overload use points to the chosen overload, with real cross-file definition first and declaration fallback ordered/deduplicated. Probe identifier interior/end, following whitespace, punctuation, comment, EOF and unbound recovery. At `Value|;`, the containing semicolon wins and returns empty; at a bound `Value|` ending at EOF with no containing token, identifier-end lookup is allowed. A frozen-host function with a valid signature but no location returns useful hover and `NoSourceTarget`, never a made-up script line. Changed input/environment identity and cancelled requests return their specific statuses; unchanged repeated queries do not mutate formal data.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_navigation.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingNavigationTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingNavigation'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `ToolingNavigation`; retain exact case results and source/binary identity. This focused prefix proves the independently acceptable output; it does not stand in for sibling product cases.

**Evidence**

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingNavigation'; Fast = $true; TimeoutMs = 600000 }
```

Run `eec198f038b54fcea9ea7698088f6cf2` after editor build `94ffed312f5747d3adf0842b303450e8`: Succeeded, 2/2. Cases: ToolingNavigation.ActualIdentifierBinding, ToolingNavigation.HostLocationAbsence. 4.1 navigation stubs returned Unavailable; this node replaces those definitions. Report: `Saved/Harness/Unreal/Runs/eec198f038b54fcea9ea7698088f6cf2/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is ToolingNavigation.

Naming assumed: `asCAnalysisResult::GetPreprocessedSources` — retained token stream for containing-token vs identifier-end selection.

**Follow-up disposition**

needs_followup: 7.1. Preserve original completion/run history; these nodes own unmet acceptance. See `attachments/replans/replan-20260915-100735-tooling-review-followups.md`.

## [x] 4.4 Capture isolated cursor context after the declaration barrier

Cursor requests need isolated parse/sema state without editing formal compilation inputs.

**Outcome**

Create request-local parser/sema scratch state for incomplete bodies and active arguments. Excludes candidate ranking and navigation, and never inserts cursor tokens into the formal source or published AST.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h; frontend/Sema/as_sema.h; 4.1 retained inputs and 3.3 assessment`. Produces the proposed interface shape below and public test class `ToolingCursor` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asSCursorContext asCToolingSession::PrepareCursor(asSQueryPosition Position, const asSCancellationToken& Cancel) const;
// Proposed private session helper. Context owns scratch parser/sema data, scope,
// receiver, expected type, replacement span and innermost call/formal mapping.
```

**Cases**

1. **Cursor preserves scope without source edit** — new RED

    For `void F(){ int Outer=1; { int Inner=2; | } }`, remove marker before snapshot creation. PrepareCursor reports nested Inner/Outer visibility at the exact original byte position; formal AST/source/diagnostics are unchanged.

2. **Barrier before incomplete body** — new RED

    Query `obj.|` or an unclosed call in A.as while its receiver type is declared in later B.as. Both source orders establish the full declaration barrier before target-body cursor parsing; cancellation discards scratch writes.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_token.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_token_kinds.def
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCursorTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCursor'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `ToolingCursor`; retain exact case results and source/binary identity. This focused prefix proves the independently acceptable output; it does not stand in for sibling product cases.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCursor'; Fast = $true; TimeoutMs = 600000 }
```

Run `455f2dbfa59a4d15b6d09a32130f412b` after editor build `7111b50840ea419eaf40d7fef575f449`: Failed 0/2. Both cases received `Unavailable` from the request-local stub (Success expected 0, actual 7; Cancelled expected 2, actual 7).

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCursor'; Fast = $true; TimeoutMs = 600000 }
```

Run `40d785e476be464fbed42b8acca9dc66` after editor build `d0694b17a722432e95df907563e4acab`: Succeeded, 2/2. Cases: ToolingCursor.CursorPreservesScopeWithoutSourceEdit, ToolingCursor.BarrierBeforeIncompleteBody. Report: `Saved/Harness/Unreal/Runs/40d785e476be464fbed42b8acca9dc66/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is ToolingCursor.

Naming assumed: `asSCursorContext` visible-name/receiver/call fields. `asCCompilationSession::LookupInScope` — public body-scope lookup used by scratch `BeginBody`. `asCSema::NoteIncompleteMember` / `NoteIncompleteCall` — parser-recorded incomplete postfix state. Prefix token slice does not require exact body-end match.

**Follow-up disposition**

needs_followup: 7.2, 7.3, 7.7. Preserve original completion/run history; these nodes own unmet acceptance. See `attachments/replans/replan-20260915-100735-tooling-review-followups.md`.

## [x] 5.1 Expose an in-process language service for compile-time format and suggestion query

Hosts need a retained in-process diagnostic facade after compilation objects are released.

**Outcome**

Consumes owned groups, Clang-style rendering and `asCSourceEditApplier` from 2.4, plus the retained CompileOutput result from 3.4 with real unresolved-name notes/fixes from 2.2. Produces `asCLanguageService::Create`, `AttachCompilation`, `GetGroups`, `Format` and `ApplyFix` with `asLANGUAGE_SERVICE_DIAGNOSTICS` and `asLANGUAGE_SERVICE_FIXES`. New class: `LanguageService`. Do not implement JSON-RPC, document sync, `asCToolingSession` query wrappers, Engine creation or `asIScriptEngine` subclassing. Completion/hover/definition bits stay reserved and must report unavailability.

**Interfaces**

Consumes: `prerequisite 3.4 CompileOutput result accessor, 2.2 renderer and 2.4 edit applier`. Produces the proposed interface shape below and public test class `LanguageService` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asELanguageServiceStatus asCLanguageService::AttachCompilation(
    TSharedRef<const asCDiagnosticResult, ESPMode::ThreadSafe> Result);
asELanguageServiceStatus asCLanguageService::Format(const asSDiagnosticGroup& Group, FString& OutText) const;
// Retains Result; Sources are owned by Result, not a separately matchable argument.
// Create/GetGroups/Format/ApplyFix follow design.md; foreign group/fix handles fail.
```

**Cases**

1. **Retained SDK attachment** — new RED

    Attach the actual Cout diagnostic snapshot, release Builder/CompileOutput and caller result references, then Format/GetGroups/ApplyFix remain valid and produce Count bytes. The service holds the same immutable result, not a borrowed pointer or copied diagnostic authority.

2. **Feature and owner boundaries** — new RED

    Diagnostics-only service rejects ApplyFix and reserved queries as unavailable. Format works; successful empty attachment differs from unavailable. Copy an owned A fix/group value or retain result A, reattach result B, then use the valid A value: reject owner mismatch without modifying either snapshot. Format returns an explicit rejection status and leaves OutText unchanged; never dereference an invalidated array view.

3. **Additional accepted boundaries** — boundary

    Cases: compile `int F(){ int Count=1; return Cout; }` without an Engine; attach the Builder diagnostic result; `Format` of the unresolved-name group matches an independently authored expected string that names `Cout` with a caret and a note naming `Count`; structured note/fix accessors expose the suggested identifier and replacement bytes without parsing that text; `ApplyFix` of the unique alternative yields a new snapshot whose re-analysis no longer reports that unresolved-name cause; the original snapshot and attached result are unchanged. Constructing with only `asLANGUAGE_SERVICE_DIAGNOSTICS` makes `ApplyFix` and reserved query features unavailable while `GetGroups`/`Format` still work. A successful empty diagnostic attachment is distinct from those unavailable statuses. No `asCreateScriptEngine` call occurs.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_language_service.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_language_service.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/LanguageServiceTests.cpp
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.LanguageService'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `LanguageService`; retain exact case results and source/binary identity. This focused prefix proves the independently acceptable output; it does not stand in for sibling product cases.

**Evidence**

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.LanguageService'; Fast = $true; TimeoutMs = 600000 }
```

Run `ace296b827844eb4b463a9b7ed1a91c4` after editor build `7b466f1234df4cf5a389eca8c748b3a9`: Succeeded, 3/3. Cases: LanguageService.RetainedSdkAttachment, LanguageService.FeatureAndOwnerBoundaries, LanguageService.AcceptedLanguageServiceBoundaries. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is LanguageService. Report: `Saved/Harness/Unreal/Runs/ace296b827844eb4b463a9b7ed1a91c4/AutomationReport/index.json`.

Naming assumed: `asELanguageServiceStatus` — Succeeded / Unavailable / NotAttached / OwnerMismatch / InvalidArgument. `QueryCompletion` / `QuerySignatureHelp` / `QueryHover` / `QueryDefinition` — reserved facade stubs without 4.1 query types.

## [x] 6.1 Close the producer matrix and prove the integrated diagnostic/tooling behavior without enabling legacy systems

Integration must prove actual producer-to-fix-to-query behavior and complete branch dispositions.

**Outcome**

New class: `DiagnosticsToolingIntegration`. This task integrates existing interfaces and evidence; a discovered product defect stays with its concrete evidence and does not grant unbounded source ownership. Replan the pending Files boundary if necessary rather than silently editing outside it. Consume `asCLanguageService` from 5.1 for format/fix round-trips; do not reimplement rendering or edit application.

**Interfaces**

Consumes: `prerequisites 2.1–4.4 and 5.1; no new runtime interface`. Produces the proposed interface shape below and public test class `DiagnosticsToolingIntegration` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
// Use the implemented Builder -> GetDiagnosticResult -> AttachCompilation ->
// Format / ApplyFix -> fresh Analyze -> query sequence. No duplicate renderer or resolver.
```

**Cases**

1. **Real compile-fix-reanalysis** — new RED

    Compile Cout -> attach retained result -> format/inspect -> apply Count fix -> fresh analysis. Intended cause disappears; old result and ranges remain revision-bound and a stale alternative rejects the new revision.

2. **Partial source and determinism** — new RED

    Erroneous F plus independent valid G still supplies accurate queries without publishable definitions. Reverse two-file and host-input order, compare 1/4 workers: identical canonical diagnostics/semantic query data, explicit coverage and no formal-query mutation.

3. **Joined early-phase failure and retained tooling data** — new RED

    Use A.as with an unterminated string, B.as with `int B(){ return 2; }`, and C.as with a malformed PP condition. Across X=1/4 and K=1/4, B retains correctly keyed PP data, A has no eligible PP product, C retains invalid PP disposition, and overall definitions remain unavailable. Repeated legal stage advancement never repeats PP diagnostics. Retained diagnostic/tooling results own required identifiers after Builder release.

4. **Additional accepted boundaries** — boundary

    Cases: full Builder error -> language-service attach -> formatted text/JSON -> selected in-memory delimiter/name fix -> fresh analysis removes the intended cause; edit into a new revision invalidates prior ranges/handles/fixes rather than reusing them. An erroneous file still supports accurate independent hover/completion without becoming publishable. Repeat multi-file diagnostics and queries with reversed source/host input order and 1/4 workers, asserting identical stable semantic results and no formal-query side effects. All inventory source causes have independent expected data, not only a total diagnostic count; all internal/derived/API branches have their explicit preserved disposition.


    NativeEngine is the integrated scope because the Change changes shared Parser/Sema/source/AST/Builder contracts. Baseline separately proves old runtime/test dormancy; these are future operations, not creation-time checks. Omit Harness Quick/Performance/Integration, Standalone, legacy/full UE suites, VM/JIT and unrelated plugin tests unless new evidence or authority establishes their relevance.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticToolingIntegrationTests.cpp
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/tasks.md
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/INDEX.md
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/data/diagnostic-migration-inventory.md
+openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/data/implementation-verification.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsToolingIntegration`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Notes**

Also run the exact `Angelscript.UnitTest.Baseline` prefix for legacy dormancy and strict validation of this Change after integration. Fresh mapped feature-group proof may be reused; unrelated Harness aggregate profiles, full UE suites, Standalone and VM/JIT execution are omitted unless new impact evidence warrants them. Inventory closure requires per-branch disposition, concrete expected payload, exact case/result and run provenance; a count-only or source-scan report is insufficient.

**Evidence**

GREEN command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Focused DiagnosticsToolingIntegration `06adc1ebf2b84578b2a36aa167ee97e6` after editor build `ae945a25e9fc43959484364d34b97e07`: Succeeded, 3/3. NativeEngine `a8f886db1ab04088aa3a6cf730a32b36`: Succeeded, 1150/1150. Cases: DiagnosticsToolingIntegration.RealCompileFixReanalysis, PartialSourceAndDeterminism, JoinedEarlyPhaseFailureAndRetainedToolingData. Baseline `71959936e39644d5bd4662e2013f653c`: PassedWithWarnings, 3 complete, 0 failed (RuntimeDormantByDefault, OptionalIntegrationsDormantByDefault, LegacySuiteExcludedByDefault). Inventory closure and run provenance: `attachments/data/implementation-verification.md` and `attachments/data/diagnostic-migration-inventory.md` section `6.1 implementation closure`. Intentionally omitted Quick/Performance/Integration/Standalone/VM-JIT: no new impact evidence. Report: `Saved/Harness/Unreal/Runs/a8f886db1ab04088aa3a6cf730a32b36/AutomationReport/index.json`.

**Follow-up disposition**

needs_followup: 8.1, 8.2. Preserve original completion/run history; these nodes own unmet acceptance. See `attachments/replans/replan-20260915-100735-tooling-review-followups.md`.


## [x] 7.1 Bind navigation to source revision and semantic environment

Bind navigation to source revision and semantic environment.

**Outcome**

Old F03 / independent F01; navigation part of old F04. The concrete behavior and completion boundary are the cases below; no editor protocol, ambient Engine or dormant language feature is added.

**Interfaces**

Consumes inspected frontend/Sema/as_tooling_navigation.cpp:14; as_tooling_types.h:42; as_tooling_session.h:18-19 under the SDK root, and the applicable existing ToolingSession entries at as_tooling_session.h:13-19:

```cpp
asSHoverResult GetHover(const asCAnalysisResult& Result, asSQueryPosition Position, const asSCancellationToken& Cancel);
asSDefinitionResult FindDefinition(const asCAnalysisResult& Result, asSQueryPosition Position, const asSCancellationToken& Cancel);
```

Produces the owning behavior on existing query/result/context types. New internal helpers and test seams follow asC/asS/asE and existing CQTest conventions; record Naming assumed during apply. No new entry point or stable-key family is introduced.

**Cases**

1. **Reject same-path foreign results** — new RED

    Create default-Identity=0 sessions for Value.as containing `int Value;` and `int Other;`, empty host sets. Pass A result to B GetHover/FindDefinition at byte 4: SnapshotMismatch; own-session queries succeed. Identical bytes with different StableScope or host definitions also reject, even with a reused caller Identity. Result-local handles never cross analysis contexts.

2. **Retained provenance and exact targets** — new RED

    For `int Pick(int A); float Pick(float A); int F(){ return Pick(1); }`, hover/definition selects the int overload. Add qualified/member references, comment text Pick and whitespace beyond identifier-end affinity: assert authentic target or none. Host metadata without location yields NoSourceTarget. Release caller inputs and retain result/display/range provenance: original revision remains readable.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_types.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_navigation.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_analysis_result.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_analysis_result.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingNavigationTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/NativeToolingTestSupport.h
```

Only the named maintained frontend behavior and its tests are owned; unrelated/dormant sources are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingNavigation'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace after an impact-related Harness editor build. Every named oracle executes; retain real grouped RED/GREEN, case identities/results and source/binary/run identity. Existing control assertions in a new feature group need not fail.

**Notes**

Old F03 / independent F01; navigation part of old F04.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingNavigation'; Fast = $true; TimeoutMs = 600000 }
```

RED run `09cddca23d7747c1a77090ee4bb9bcaa` after editor build `f922cde2c005460c92fe78a24bd2ff31`: 4 discovered, 3 succeeded, 1 failed. RejectSamePathForeignResults failed because same-path Identity=0 inputs compared equal without source bytes. RetainedProvenanceAndExactTargets already succeeded (characterization). Existing ActualIdentifierBinding and HostLocationAbsence stayed green.

GREEN run `db9e67d49735476fb177514dc23cbe3c` after editor build `54219aea14c4493090ab973acd054b46`: Succeeded, 4/4, 0 failed/skipped/not-run. Cases: ToolingNavigation.RejectSamePathForeignResults, ToolingNavigation.RetainedProvenanceAndExactTargets, plus existing ActualIdentifierBinding and HostLocationAbsence. Report: `Saved/Harness/Unreal/Runs/db9e67d49735476fb177514dc23cbe3c/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is ToolingNavigation.

Naming assumed: none. Comparison stays a file-local helper; caller `Identity` is never an acceptance shortcut.

## [x] 7.2 Preserve query status and bounded cooperative cancellation

Preserve query status and bounded cooperative cancellation.

**Outcome**

Old F05 / independent F05; cancellation/position part of old F04. The concrete behavior and completion boundary are the cases below; no editor protocol, ambient Engine or dormant language feature is added.

**Interfaces**

Consumes inspected frontend/Sema/as_tooling_completion.cpp:136,196; as_cursor_context.cpp:131-159; as_tooling_types.h:11-26 under the SDK root, and the applicable existing ToolingSession entries at as_tooling_session.h:13-19:

```cpp
asSAnalysisResponse Analyze(const asSCancellationToken& Cancel);
asSCursorContext PrepareCursor(asSQueryPosition Position, const asSCancellationToken& Cancel) const;
asSCompletionResult Complete(asSQueryPosition Position, const asSCancellationToken& Cancel);
asSSignatureHelpResult GetSignatureHelp(asSQueryPosition Position, const asSCancellationToken& Cancel);
```

Produces the owning behavior on existing query/result/context types. New internal helpers and test seams follow asC/asS/asE and existing CQTest conventions; record Naming assumed during apply. No new entry point or stable-key family is introduced.

**Cases**

1. **Invalid unavailable and empty are distinct** — new RED

    For Valid.as containing `void F(){}`, query Missing.as byte 0 and Valid.as length+1 through Complete/GetSignatureHelp: InvalidPosition. Empty key returns InvalidInput. A byte inside a multibyte UTF-8 code point rejects through the existing coordinate contract. Inject a declaration-stage failure with no usable context: AnalysisUnavailable. Inside a valid comment: Success-empty. Valid file-scope/EOF is not invalid merely because no function encloses it; 7.3 owns grammar candidates.

2. **Cancellation after work starts** — new RED

    Use deterministic test checkpoints after declaration work starts and inside bounded cursor parse/assessment work; do not use sleep races or unsynchronized bool writes. Assert Cancelled, explicit coverage for any safe partial data, no successful-empty substitute and no publishable definitions. Retain pre-cancelled Analyze controls and prove independent subsequent queries succeed.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_types.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_navigation.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_call_assessment.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser_statements.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingAnalysisTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCursorTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCompletionTests.cpp
```

Only the named maintained frontend behavior and its tests are owned; unrelated/dormant sources are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Tooling'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace after an impact-related Harness editor build. Every named oracle executes; retain real grouped RED/GREEN, case identities/results and source/binary/run identity. Existing control assertions in a new feature group need not fail.

**Notes**

Old F05 / independent F05; cancellation/position part of old F04.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Tooling'; Fast = $true; TimeoutMs = 600000 }
```

RED run `ced7ef8b5ff24583b3fce9ebdda68c89` after editor build `02dd35e3e25247b69652f4cc5b905d1d`: 22 discovered, 20 succeeded, 2 failed. ToolingCompletion.InvalidUnavailableAndEmptyAreDistinct still treated missing keys, past-end and mid-codepoint as Success. ToolingCompletion.CancellationAfterWorkStarts never became Cancelled after declaration or cursor-parse work. Existing Tooling Analysis/Cursor/Navigation/Completion controls stayed green.

GREEN run `c53948a3fc644fc8b9be9e054ec95676` after editor build `a2673c067b2a4665be28159c103318ab`: Succeeded, 22/22, 0 failed/skipped/not-run. Cases: ToolingCompletion.InvalidUnavailableAndEmptyAreDistinct, ToolingCompletion.CancellationAfterWorkStarts. Report: `Saved/Harness/Unreal/Runs/c53948a3fc644fc8b9be9e054ec95676/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is Tooling.

Naming assumed: `asCToolingSession::asEToolingCancelCheckpoint`, `DebugFailNextDeclarationStage`, `DebugCancelAt` — test-only declaration-failure and cooperative-cancel seams; production status uses the existing `asEAnalysisStatus` contract.

## [x] 7.3 Collect completion from the active scope and grammar context

Collect completion from the active scope and grammar context.

**Outcome**

Independent F04; grammar/expected-type/completion part of old F01. Excludes member filtering and signature payload. Produces cursor semantic scope facts consumed by 7.4/7.5. The concrete behavior and completion boundary are the cases below; no editor protocol, ambient Engine or dormant language feature is added.

**Interfaces**

Consumes inspected frontend/Sema/as_cursor_context.cpp:227; as_cursor_context.h:11; as_sema.h:143 under the SDK root, and the applicable existing ToolingSession entries at as_tooling_session.h:13-19:

```cpp
asSAnalysisResponse Analyze(const asSCancellationToken& Cancel);
asSCursorContext PrepareCursor(asSQueryPosition Position, const asSCancellationToken& Cancel) const;
asSCompletionResult Complete(asSQueryPosition Position, const asSCancellationToken& Cancel);
asSSignatureHelpResult GetSignatureHelp(asSQueryPosition Position, const asSCancellationToken& Cancel);
```

Produces the owning behavior on existing query/result/context types. New internal helpers and test seams follow asC/asS/asE and existing CQTest conventions; record Naming assumed during apply. No new entry point or stable-key family is introduced.

**Cases**

1. **Exited scopes and nearest shadow** — new RED

    At removed marker in `void F(int Param){ int Outer; { int Expired; } /*cursor*/ }`, Param/Outer are present and Expired absent. A completed loop local, sibling-block local and later declaration are absent. Nested Value declarations return one candidate bound to the nearest live declaration.

2. **Grammar expected type and source ownership** — new RED

    With `namespace N { class Item {} }`, query type/namespace/expression contexts, valid file scope, unfinished identifier and EOF. Assert N/Item and legal maintained grammar keywords; removed lambda/function constructs are absent. In int-expected context rank an int candidate above a known incompatible type but retain unknown-type candidates. Repeated order/identities agree. For `obj.Va`, replacement spans only Va in its revision. Comments/strings/inactive source are empty. Formal AST/diagnostics/source bytes stay unchanged.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_types.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser_statements.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCursorTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCompletionTests.cpp
```

Only the named maintained frontend behavior and its tests are owned; unrelated/dormant sources are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Tooling'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace after an impact-related Harness editor build. Every named oracle executes; retain real grouped RED/GREEN, case identities/results and source/binary/run identity. Existing control assertions in a new feature group need not fail.

**Notes**

Independent F04; grammar/expected-type/completion part of old F01. Excludes member filtering and signature payload. Produces cursor semantic scope facts consumed by 7.4/7.5.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Tooling'; Fast = $true; TimeoutMs = 600000 }
```

RED run `599a86f68d0d48198fd05f0a1c2af9fc` after editor build `9eee40e8f63445c7ad763bfe7a47a0a1`: 16 discovered, 13 succeeded, 3 failed. ToolingCursor.ExitedScopesAndNearestShadow still listed Expired after the closed inner block. ToolingCompletion.ExitedScopesAndNearestShadow offered Expired. ToolingCompletion.GrammarExpectedTypeAndSourceOwnership stayed InvalidPosition at file-scope EOF and lacked N/Item/keywords/int-expected ranking. Existing ScopeAndMemberCompletion, RealSignatureContext, CursorPreservesScopeWithoutSourceEdit and the 7.1/7.6 Tooling cases stayed green.

GREEN run `04d6866a5b2742a99853db95cd9456a2` after editor build `969989a8af5147218f9c59d64114bce9`: Succeeded, 16/16. Cases: ToolingCursor.ExitedScopesAndNearestShadow, ToolingCompletion.ExitedScopesAndNearestShadow, ToolingCompletion.GrammarExpectedTypeAndSourceOwnership. Report: `Saved/Harness/Unreal/Runs/04d6866a5b2742a99853db95cd9456a2/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is Tooling.

Naming assumed: `asSCursorVisibleSymbol`, `asSCursorContext::ExpectedTypeName`, `asSCursorContext::VisibleSymbols`, `asCSema::CollectVisibleLocalSymbols`, `asCSema::NoteLiveCursorScope`, `asCSema::NoteExpectedReturnType` — cursor facts and live-scope snapshot taken at the first unterminated compound so later `PopBodyScope` cannot erase the active lexical set.

## [x] 7.4 Use authoritative access and receiver rules for members

Use authoritative access and receiver rules for members.

**Outcome**

Old F02 / independent F03. Consumes active semantic context from 7.3; no second enum-only access policy. The concrete behavior and completion boundary are the cases below; no editor protocol, ambient Engine or dormant language feature is added.

**Interfaces**

Consumes inspected frontend/Sema/as_tooling_completion.cpp:155; as_sema.h:168 CanAccessMember; as_sema.h:140 AssessCall under the SDK root, and the applicable existing ToolingSession entries at as_tooling_session.h:13-19:

```cpp
bool asCSema::CanAccessMember(const asCDecl* Member) const;
asSCompletionResult asCToolingSession::Complete(asSQueryPosition Position, const asSCancellationToken& Cancel);
```

Produces the owning behavior on existing query/result/context types. New internal helpers and test seams follow asC/asS/asE and existing CQTest conventions; record Naming assumed during apply. No new entry point or stable-key family is introduced.

**Cases**

1. **Protected member from free function** — new RED

    Item has `protected int Hidden; int Value;`. At `obj.` in an unrelated free function, Value is present and Hidden absent. Compare normal compilation of access from the same context.

2. **Legal class access and compatible receiver** — new RED

    Inside Item offer legal private members; in a supported derived context offer legal protected members. Distinguish mutable-only method applicability for const/mutable receivers using ordinary semantic rules. Unrelated module declarations never replace the member set.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_call_assessment.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCompletionTests.cpp
```

Only the named maintained frontend behavior and its tests are owned; unrelated/dormant sources are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCompletion'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace after an impact-related Harness editor build. Every named oracle executes; retain real grouped RED/GREEN, case identities/results and source/binary/run identity. Existing control assertions in a new feature group need not fail.

**Notes**

Old F02 / independent F03. Consumes active semantic context from 7.3; no second enum-only access policy.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCompletion'; Fast = $true; TimeoutMs = 600000 }
```

RED run `02ce2a06d6fe4c7eb1c2ad14c4a29dc3` after editor build `0f04ccdcb15d469ba63c1e0a2ba89848`: 6 discovered, 4 succeeded, 2 failed. ProtectedMemberFromFreeFunction still offered protected Hidden from a free function. LegalClassAccessAndCompatibleReceiver failed the same enum-only Private filter. Existing ScopeAndMemberCompletion, RealSignatureContext, ExitedScopesAndNearestShadow and GrammarExpectedTypeAndSourceOwnership stayed green.

GREEN run `783406881957492bb1ecccebe4377fd8` after editor build `b7f89286604544408f7dea690ad8e205`: Succeeded, 6/6. Cases: ToolingCompletion.ProtectedMemberFromFreeFunction, ToolingCompletion.LegalClassAccessAndCompatibleReceiver. Report: `Saved/Harness/Unreal/Runs/783406881957492bb1ecccebe4377fd8/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is ToolingCompletion.

Naming assumed: `asCSema::SetAccessCaller`, `asSCursorContext::bReceiverReadOnly` — bind the enclosing function and nominal lookup so `CanAccessMember`/`ResolveRecord` run under the cursor caller; const receivers reuse ordinary `IsConstMethod` filtering.

## [x] 7.5 Return owned candidate signatures mappings and viability

Return owned candidate signatures mappings and viability.

**Outcome**

Old F01 signature part / independent F02. Consumes 7.3 scope/call facts. Produces the accepted rich owned payload on asSSignatureHelpResult. NativeEngine is justified by shared Parser/Sema assessment and ordinary compilation parity, covering both test classes. The concrete behavior and completion boundary are the cases below; no editor protocol, ambient Engine or dormant language feature is added.

**Interfaces**

Consumes inspected frontend/Sema/as_tooling_types.h:73; as_tooling_completion.cpp:216; as_sema.h:140 AssessCall under the SDK root, and the applicable existing ToolingSession entries at as_tooling_session.h:13-19:

```cpp
asSCallAssessment asCSema::AssessCall(const asSCallAssessmentRequest& Request) const;
asSSignatureHelpResult asCToolingSession::GetSignatureHelp(asSQueryPosition Position, const asSCancellationToken& Cancel);
```

Produces the owning behavior on existing query/result/context types. New internal helpers and test seams follow asC/asS/asE and existing CQTest conventions; record Naming assumed during apply. No new entry point or stable-key family is introduced.

**Cases**

1. **Observable overload and named-argument payload** — new RED

    For `int Pick(int First, int Second = 2); float Pick(float First);` at `Pick(`, return both ordered signatures with names/defaults. Distinguish known incompatibility from unknown future arguments. `Pick(Second: 4, First: 3)` exposes formal map [1,0] matching ordinary compilation; duplicate names expose rejection causes. Assert payload, not CallName alone.

2. **Nested host and nonmutation boundaries** — new RED

    At `Outer(Inner(1), /*cursor*/)` select Outer; inside Inner select Inner. Nested list-initializer commas do not increment the outer argument index. Frozen host overloads include one unsupported-default candidate: isolate its rejection without hiding legal candidates. Compare formal AST/node/body projection, diagnostics and frozen host definitions before/after repeated requests. Retain response after request destruction: copied signatures/maps/identity remain valid.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_types.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_call_assessment.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_call_assessment.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser_statements.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCompletionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/CallAssessmentTests.cpp
```

Only the named maintained frontend behavior and its tests are owned; unrelated/dormant sources are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace after an impact-related Harness editor build. Every named oracle executes; retain real grouped RED/GREEN, case identities/results and source/binary/run identity. Existing control assertions in a new feature group need not fail.

**Notes**

Old F01 signature part / independent F02. Consumes 7.3 scope/call facts. Produces the accepted rich owned payload on asSSignatureHelpResult. NativeEngine is justified by shared Parser/Sema assessment and ordinary compilation parity, covering both test classes.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Observed feature-group RED on ToolingCompletion run `be3e40f8ddf64960add0d4597e298288` after editor build `999dd53ae9c84d309dcb3b296d5bcc27`: 8 discovered, 6 succeeded, 2 failed. ObservableOverloadAndNamedArgumentPayload and NestedHostAndNonmutationBoundaries saw empty Signatures. Existing ToolingCompletion cases stayed green.

GREEN command (card prefix) after editor build `6f5d3553ab1d4e6c8caf6056509e6db7`: ToolingCompletion run `518a059b69f64222ade7941fe3a5d4b3` 8/8, then NativeEngine run `85e9764b0be54d35bee18020a52c346f` Succeeded 1161/1161. Cases: ToolingCompletion.ObservableOverloadAndNamedArgumentPayload, ToolingCompletion.NestedHostAndNonmutationBoundaries, plus existing CallAssessment.CompleteAndIncompleteMapping and CallAssessment.CandidateLocalFailureAndImmutability. Report: `Saved/Harness/Unreal/Runs/85e9764b0be54d35bee18020a52c346f/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration: this card's proving prefix is NativeEngine.

Naming assumed: `asSSignatureParameter`, `asSSignatureCandidate`, `asSSignatureHelpResult::Signatures`/`SelectedIndex`, `asSCursorContext::CallArgumentTypeNames`/`CallArgumentIsInitList`/`bInnermostCallArgumentIsInitList`, `asCSema::NoteIncompleteInitList` — owned copies of AssessCall viability, maps and slots; host unsupported defaults stay visible under Incomplete.

## [x] 7.6 Audit ownership before exposing readable analysis

Audit ownership before exposing readable analysis.

**Outcome**

Old F06 accepted design-audit follow-up. The missing check is confirmed; no production corruption is claimed. Retain existing ownership model and valid-AST/publication separation. The concrete behavior and completion boundary are the cases below; no editor protocol, ambient Engine or dormant language feature is added.

**Interfaces**

Consumes inspected frontend/Sema/../AST/as_ast_context.cpp:226; as_tooling_session.cpp:12,93; design.md Native query facade and ownership under the SDK root, and the applicable existing ToolingSession entries at as_tooling_session.h:13-19:

```cpp
bool asCASTContext::FreezeForTooling();
asSAnalysisResponse asCToolingSession::Analyze(const asSCancellationToken& Cancel);
```

Produces the owning behavior on existing query/result/context types. New internal helpers and test seams follow asC/asS/asE and existing CQTest conventions; record Naming assumed during apply. No new entry point or stable-key family is introduced.

**Cases**

1. **Foreign range or readable edge** — new RED

    Through a bounded test construction seam provide a range from another source snapshot or readable node edge from another AST context. Unsafe freeze/publication fails and Analyze returns AnalysisUnavailable without traversable data. Safe recovery in the owned graph still yields readable Partial, never a valid seal.

2. **Transitive leases and partial-freeze control** — new RED

    Frozen A depends on frozen B and script references B metadata through A. Release caller references: result retains B. Unretained or mutable B rejects before traversal; inspect ownership/destruction counters, never freed-memory reads. Retain ToolingAnalysis.PartialReadFreeze: late Create blocked, recovery readable, VerifyAST false and normal definitions unavailable.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_context.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_context.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_verifier.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/as_ast_verifier.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_analysis_result.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_analysis_result.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingAnalysisTests.cpp
```

Only the named maintained frontend behavior and its tests are owned; unrelated/dormant sources are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingAnalysis'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace after an impact-related Harness editor build. Every named oracle executes; retain real grouped RED/GREEN, case identities/results and source/binary/run identity. Existing control assertions in a new feature group need not fail.

**Notes**

Old F06 accepted design-audit follow-up. The missing check is confirmed; no production corruption is claimed. Retain existing ownership model and valid-AST/publication separation.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingAnalysis'; Fast = $true; TimeoutMs = 600000 }
```

RED run `527e104972584cccb0d9390c25b8d7a1` after editor build `4a163bb502c0450aa45adc8ae38de045`: 5 discovered, 3 succeeded, 2 failed. ForeignRangeOrReadableEdge still froze after a foreign SnapshotID; TransitiveLeasesAndPartialFreezeControl accepted HostValue without owned Inner. Existing PartialReadFreeze, RetainedOwnershipClosure and IdentityAndCancellation stayed green.

GREEN run `7f3e504f9f7e40a98353194c97734ff8` after editor build `a3eff6da95344fb2bcd6e41028b63cf6`: Succeeded, 5/5. Cases: ToolingAnalysis.ForeignRangeOrReadableEdge, ToolingAnalysis.TransitiveLeasesAndPartialFreezeControl. Report: `Saved/Harness/Unreal/Runs/7f3e504f9f7e40a98353194c97734ff8/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is ToolingAnalysis.

Naming assumed: `asCASTNode::DebugForceSourceRange` and `asCToolingSession::DebugPlantForeignRangeOnNextAnalyze` — test-only seams that bypass `SetSourceRange` snapshot/file identity guards so Freeze can observe a foreign range.

## [x] 7.7 Prepare declarations once per cursor request

Prepare declarations once per cursor request.

**Outcome**

Old F07 accepted in-Change advisory follow-up. Share declaration preparation only within the request. Stage count needs no timing/Performance gate; shared files do not invent dependency edges. The concrete behavior and completion boundary are the cases below; no editor protocol, ambient Engine or dormant language feature is added.

**Interfaces**

Consumes inspected frontend/Sema/as_tooling_completion.cpp:13,129,189; as_cursor_context.cpp:121 under the SDK root, and the applicable existing ToolingSession entries at as_tooling_session.h:13-19:

```cpp
asSAnalysisResponse Analyze(const asSCancellationToken& Cancel);
asSCursorContext PrepareCursor(asSQueryPosition Position, const asSCancellationToken& Cancel) const;
asSCompletionResult Complete(asSQueryPosition Position, const asSCancellationToken& Cancel);
asSSignatureHelpResult GetSignatureHelp(asSQueryPosition Position, const asSCancellationToken& Cancel);
```

Produces the owning behavior on existing query/result/context types. New internal helpers and test seams follow asC/asS/asE and existing CQTest conventions; record Naming assumed during apply. No new entry point or stable-key family is introduced.

**Cases**

1. **One actual declaration preparation** — new RED

    For one Complete call and separately one GetSignatureHelp call over two files, observe actual declaration-stage entry through a test-only seam: exactly one, versus the current two. Counting a helper that hides another Builder is not the oracle.

2. **Request isolation remains intact** — existing control

    Retain ToolingCursor.CursorPreservesScopeWithoutSourceEdit and BarrierBeforeIncompleteBody and existing completion/signature controls. Compare formal AST/diagnostics/source bytes before/after. Standalone PrepareCursor remains usable; cancelled/non-code requests retain their statuses.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_session.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_tooling_completion.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_cursor_context.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCursorTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCompletionTests.cpp
```

Only the named maintained frontend behavior and its tests are owned; unrelated/dormant sources are excluded.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Tooling'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace after an impact-related Harness editor build. Every named oracle executes; retain real grouped RED/GREEN, case identities/results and source/binary/run identity. Existing control assertions in a new feature group need not fail.

**Notes**

Old F07 accepted in-Change advisory follow-up. Share declaration preparation only within the request. Stage count needs no timing/Performance gate; shared files do not invent dependency edges.

**Evidence**

RED command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Tooling'; Fast = $true; TimeoutMs = 600000 }
```

RED run `b30b092e2c6047148e36fc863e342670` after editor build `236b1491b3e240be90e823d04d8f71c7`: 23 discovered, 22 succeeded, 1 failed. ToolingCompletion.OneActualDeclarationPreparation observed two `DeclarationsResolved` stage entries for one Complete over two files (expected 1). Existing Tooling Analysis/Cursor/Navigation/Completion controls stayed green, including ToolingCursor.CursorPreservesScopeWithoutSourceEdit and BarrierBeforeIncompleteBody.

GREEN run `632135d7d7984e408726bed911620e1f` after editor build `f7e5b8e620c6426486f6573245891ff5`: Succeeded, 23/23, 0 failed/skipped/not-run. Cases: ToolingCompletion.OneActualDeclarationPreparation (Complete, GetSignatureHelp, and standalone PrepareCursor each entered declarations once); request isolation retained by the existing ToolingCursor/Completion controls in the same report. Report: `Saved/Harness/Unreal/Runs/632135d7d7984e408726bed911620e1f/AutomationReport/index.json`. Intentionally omitted NativeEngine/Quick/Performance/Integration: this card's proving prefix is Tooling.

Naming assumed: `asCBuilder::DebugResetDeclarationsResolvedEntries` / `DebugGetDeclarationsResolvedEntries` — test-only actual `RunStage(DeclarationsResolved)` entry counter, not a helper-call wrapper.

## [x] 8.1 Verify repaired acceptance on final content

Map original 4.1-4.4 oracles and both Reviews to concrete current-content case results or evidence-backed rejection. Verify producer/fix/query integration. Preserve missing historical RED honestly; new repairs require observed RED/GREEN. Test-method counts alone do not prove coverage.

**Outcome**

Map original 4.1-4.4 oracles and both Reviews to concrete current-content case results or evidence-backed rejection. Verify producer/fix/query integration. Preserve missing historical RED honestly; new repairs require observed RED/GREEN. Test-method counts alone do not prove coverage.

**Files**

```diff
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/tasks.md
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/INDEX.md
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/data/implementation-verification.md
```

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Run from the selected workspace.

**Notes**

Owns old F04 provenance/coverage. Reuse a fresh 7.5 report only if no subsequent source change invalidates it and all required cases are present; otherwise run after a Harness editor build with writers stopped. Shared Parser/Sema/AST impact warrants NativeEngine. Reuse Baseline dormancy evidence unless startup/gate impact or adjacent failures warrant rerun. Also run strict Change validation. Omit Quick/Performance/Standalone/VM-JIT without new impact evidence. This task edits evidence, not product repairs.

**Evidence**

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

NativeEngine run `58e6f563f214438bbf7ace83d26d4aeb` after editor build `f7e5b8e620c6426486f6573245891ff5`: Succeeded, 1164/1164, 0 failed/skipped/not-run. Mapped 4.1–4.4 and both Review oracles in `attachments/data/implementation-verification.md`. 7.5 NativeEngine `85e9764b0be54d35bee18020a52c346f` (1161/1161) is stale after 7.2/7.7 source changes. Baseline `71959936e39644d5bd4662e2013f653c` reused (no startup/gate impact). `openspec.doctor` Succeeded. Strict Change validation Succeeded (`6059fb81bb9e4b66b194a63f43c7a4b8`). Honest missing historical RED recorded for 4.1/4.2/4.3/4.4 third-method gaps and 3.1/2.x/5.1/6.1 GREEN-only cards; 7.x RED/GREEN is not relabeled as 4.x historical RED. Report: `Saved/Harness/Unreal/Runs/58e6f563f214438bbf7ace83d26d4aeb/AutomationReport/index.json`. Intentionally omitted Quick/Performance/Integration/Standalone/VM-JIT: no new impact; card prefix is NativeEngine.

## [x] 8.2 Resolve both user-requested Reviews on the repaired snapshot

Bind a new immutable source/requirements/evidence snapshot and re-review every finding resolution condition. Append evidence/disposition without rewriting observations; close or explicitly supersede both reports. Report arrival is not closure. This node exists because the user explicitly requested Review.

**Outcome**

Bind a new immutable source/requirements/evidence snapshot and re-review every finding resolution condition. Append evidence/disposition without rewriting observations; close or explicitly supersede both reports. Report arrival is not closure. This node exists because the user explicitly requested Review.

**Files**

```diff
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/tasks.md
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/INDEX.md
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/reviews/review-20260915-093506-frontend-diagnostics-final-inline.md
 openspec/changes/angelscript/feature-frontend-diagnostics-and-tooling/attachments/reviews/review-20260915-095353-frontend-diagnostics-independent-inline.md
```

**Verification**

```powershell
Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'angelscript/feature-frontend-diagnostics-and-tooling'; ClosureKind = 'completed'; RequireTerminal = $true }
```

Run from the selected workspace.

**Notes**

Both Reviews require terminal state, exact indexing, ordered real timestamps, reproducible snapshots and no open/deferred Critical or Required finding. Every advisory needs an explicit disposition. This command is necessary but does not replace actual source re-review or 8.1. Follow verify/spec-sync/knowledge-disposition policy before terminal checking. This node does not perform archive, commit, push or workspace actions.

**Evidence**

Re-reviewed both reports against immutable snapshot `Saved/Harness/Reviews/review-20260915-110219-frontend-diagnostics-repaired` (manifest SHA-256 `a615a6132c4c78fb82ee7b7dc7ad918d2fdfa11d8451cf545b8d71c940876a0d`; NativeEngine `58e6f563f214438bbf7ace83d26d4aeb` 1164/1164). Original observations were not rewritten. Final F01–F07 and independent F01–F05 are `resolved`; both records are `state: closed`, `verdict: APPROVE`, `closed_at: 2026-09-15T11:02:43.603910+08:00`. Specs remain unsynced (no archive). Knowledge candidates remain unpromoted. Workflow evaluation is written last against the current Change digest. Proving command:

```powershell
Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{ Change = 'angelscript/feature-frontend-diagnostics-and-tooling'; ClosureKind = 'completed'; RequireTerminal = $true }
```

This node does not archive, commit, or push.
