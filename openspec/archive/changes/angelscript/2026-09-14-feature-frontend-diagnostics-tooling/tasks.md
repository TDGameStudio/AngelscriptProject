---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1", "1.3"]
    "1.3": []
    "1.4": ["1.1"]
    "2.1": ["1.1"]
    "2.2": ["2.1", "2.3"]
    "2.3": ["1.1"]
    "2.4": ["2.2"]
    "3.1": ["2.4"]
    "3.2": ["3.4"]
    "3.3": ["3.1"]
    "3.4": ["3.1", "2.3"]
    "4.1": ["1.2", "1.4", "3.2", "3.3", "5.1"]
    "5.1": ["1.2", "1.4", "2.4"]
---

# Clang-style frontend diagnostics and native semantic tooling

## Goal

Provide rich source-accurate diagnostics, engine-independent semantic queries, and an in-process SDK facade so compilation failures can format Clang-style suggestions and inspect notes/fixes without a language-server process.

## Architecture

Layer 1 produces `asSDiagnosticGroup` values from a concrete `as_diagnostic_catalog.def` during Builder compilation; Layer 2 renders those groups (Clang-style text, JSON, atomic edits) and runs cursor queries on `asCToolingSession` over an owned `asCAnalysisResult`; Layer 3 is the in-process `asCLanguageService` facade that attaches a compilation result, formats, inspects notes/fixes and applies one alternative in memory. A JSON-RPC/LSP adapter is later work over layers 2 and 3, and no Engine, LLVM dependency or legacy runtime activation is required. See `design.md`.

## Global constraints

- Current baseline: SDK root `Source/AngelscriptRuntime/angelscript`, with `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}`. DefinitionSet and CompileOutput replaced MetadataImage-era Builder ownership; neither compile output nor tooling is an Engine publication. Lambda/source-funcdef syntax stays removed. New planned helpers follow the owning phase, with no new public phase directory.

- The user authorized creation and subsequent planning replans; product apply has not been requested. The fourteen nodes below are future product implementation; every checkbox remains unchecked until a later apply authorization. Planning validation and this replan do not authorize applying the tasks, UE execution, durable-spec synchronization, archive or Git operations.
- Read `attachments/INDEX.md`, `design.md` and the owning rows of `attachments/data/diagnostic-migration-inventory.md` before later implementation. The catalog/producer inventory is a coverage aid, not a second execution ledger. Names introduced in design are proposed interfaces, not preexisting APIs.
- Paths in Files are repository-relative. New implementation stays inside the maintained plugin; no `Legacy/**`, existing extension, host project, generated StaticJIT file, Skill or CLI source is included. Keep current canonical AS namespace and stable-key contracts. The separately planned testing framework is not an implementation prerequisite.
- Use current replacement CQTest under `WITH_ANGELSCRIPT_TESTS`, with no ambient AS Engine or legacy force include. New test files below Diagnostics/ and Tooling/ use `TestDir = Angelscript.UnitTest.NativeEngine` and the exact class names listed in each card. The physical subdirectory is not part of the public identity.
- New names use existing `asC/asS/asE` SDK conventions and CQTest area naming; proposed signatures below are future contracts, not claims of existing symbols. Record `Naming assumed` for convention-derived helper names during apply. All commands run from the selected workspace after Harness context setup and an impact-related incremental editor build; this replan runs none of them.
- Compatible Ready groups may share a supported common-prefix proving selection. For example, a justified NativeEngine run can cover DiagnosticsPresentation plus DiagnosticsSyntax, and `Angelscript.UnitTest.NativeEngine.Tooling` can cover completion and navigation together.
- Future closure follows the existing verify/sync/archive Skills after product verification and explicit continuation. Creation does not synchronize these proposed deltas into current specs or record any task complete. Commit, push and workspace actions are not tasks in this Change.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement / acceptance boundary | Task owner |
|---|---|
| Catalog, owned groups, deterministic warning/limit/failure policy | 1.1 |
| Text/JSON fidelity and real caret suggestions | 1.2 |
| UTF-8/UTF-16, CRLF, malformed-byte and EOF positions | 1.3 |
| Revision/owner/expected-byte checks and atomic alternatives | 1.4 |
| Every current lexical/PP/parser/annotation cause | 2.1 |
| Declaration/type/body reasons, recovery and viable typo suggestions | 2.2 |
| Shared complete/incomplete candidate rules without commit side effects | 2.3 |
| Builder root forwarding, CompileOutput ownership, emission/status fidelity | 2.4 |
| Partial read freeze, input/dependency lifetime, handles/status/cancellation and selection | 3.1 |
| Real scope/member completion and active-formal signature help | 3.2 |
| Token-bound hover and authentic definition targets | 3.3 |
| Isolated incomplete-body cursor context and declaration barrier | 3.4 |
| Producer matrix closure, compile-fix-reanalysis, worker determinism and dormancy | 4.1 |
| Owned in-process format/note/fix facade and feature/owner boundaries | 5.1 |

Self-review 2026-09-12: all six capability deltas and acceptance boundaries mapped; placeholder scan clean; current consumed symbols and proposed outputs distinguished. Record: `attachments/data/planning-validation.md`.

## [ ] 1.1 Implement the catalog, owned diagnostic groups and independent policy/failure facts

Flat records currently cannot retain complete root/note/fix groups or independent policy facts.

**Outcome**

The package-wide `.cpp` ownership is **only mechanical consumer adaptation** to the new diagnostic collection/view API; exclude semantic producer migration, parsing/call/type rules, AST/metadata algorithms and all Legacy files. Reserve concrete catalog entries for every inventory reason without claiming that the producer uses them yet. Keep old generic meanings reserved. Move presentation implementation behind `as_diagnostic_renderer.*` so 1.2 can work without editing collection semantics.

Produces `asSDiagnosticGroup`, `asCDiagnosticResult`, immutable `asSDiagnosticOptions`, concrete catalog descriptors, optional source validation and an adapter for existing observation consumers. New class: `DiagnosticsCore`.

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

3. **Additional accepted boundaries** — boundary

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
 openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsCore`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

## [ ] 1.2 Render complete diagnostic groups as Clang-style text and versioned JSON

Diagnostic consumers need faithful group presentation from the retained source revision.

**Outcome**

Render the 1.1 immutable result using 1.3 positions. Typed arguments, notes, highlights and fix alternatives survive text/JSON observation. Excludes source edit application and the SDK facade.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostics.h:59; prerequisite 1.1 and 1.3 outputs`. Produces the proposed interface shape below and public test class `DiagnosticsPresentation` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

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

## [ ] 1.3 Provide exact UTF-8 and UTF-16 position conversion

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

    UTF-8 bytes for `A中😀\r\nZ`: byte 8 -> UTF-16 (0,4), byte 10 -> (1,0), EOF 11 -> (1,1). Byte 9, byte 2 and UTF-16 (0,3) are rejected; output parameters stay unchanged.

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

## [ ] 1.4 Apply revision-bound fix alternatives atomically in memory

Fix alternatives need complete precondition checking before a new snapshot is exposed.

**Outcome**

Validate the whole alternative, including owner, bytes and revision, before creating any output. Excludes producer suggestion ranking and filesystem writes.

**Interfaces**

Consumes: `prerequisite 1.1 fix values and snapshot-bound byte ranges`. Produces the proposed interface shape below and public test class `DiagnosticsEdit` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

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

## [ ] 2.1 Migrate every lexical, preprocessing, parser and annotation-collection cause with precise recovery and safe delimiter proposals

Syntax producers must explain the real cause and continue at grammar-owned recovery boundaries.

**Outcome**

Sema ownership here is limited to parser reporting/recovery and annotation collection; do not implement the remaining semantic causes owned by 2.2. Existing test-folder changes are diagnostic assertion/fixture migrations, not unrelated language expansion. New class: `DiagnosticsSyntax`.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema.h:57; frontend/Lexer/as_tokenizer.h; frontend/Parser/as_parser.h`. Produces the proposed interface shape below and public test class `DiagnosticsSyntax` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asCRecoveryDecl* asCSema::ActOnRecovery(asCSourceRange Range, FString Message, asUINT DiagnosticID = 3001);
// Existing adapter above becomes catalog/group reporting from 1.1; every source branch
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
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/as_diagnostic_catalog.def
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticSyntaxTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/*.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/**
 openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsSyntax`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

## [ ] 2.2 Migrate semantic and declaration-resolution causes with recovery and viable suggestions

Generic semantic reasons and text-only declaration failures must become structured causes.

**Outcome**

Migrate Sema and CompilationSession producers using 2.3 assessment. Preserve independent recovery, distinct type-resolution reasons, warning identity and viable typo notes/fixes. Builder aggregation is owned by 2.4.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session.h:37; frontend/Sema/as_sema.h:159; 2.3 assessment`. Produces the proposed interface shape below and public test class `DiagnosticsSemantic` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
asCQualType asCCompilationSession::ResolveTypeSyntax(const asSTypeSyntax& Syntax, const asCDecl& Scope);
// Keep this existing convenience boundary; add structured resolution failure values
// internally and carry original failing syntax/node, candidate reasons and related ranges
// into the 1.1 catalog groups. Normal commit consumes the 2.3 assessment.
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
 openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsSemantic`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

## [ ] 2.3 Extract shared non-mutating script and host call assessment

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

## [ ] 2.4 Retain diagnostic results and exact failures across Builder and CompileOutput

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

## [ ] 3.1 Own readable partial analysis and precise token-to-binding selection

Tooling must own all data it traverses and distinguish safe partial reads from valid compilation.

**Outcome**

Produce the design facade/result/status contracts, real Analyze, owned input closure and token/reference selection. Query methods remain explicitly unavailable until their respective owner tasks; 3.4 owns isolated cursor parsing. A successful read freeze never implies valid AST sealing. Create Complete/GetSignatureHelp unavailable stubs only in as_tooling_completion.cpp and GetHover/FindDefinition unavailable stubs only in as_tooling_navigation.cpp; 3.2/3.3 replace their own file definitions.

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

## [ ] 3.2 Implement contextual completion and signature help using shared assessment

Incomplete source must produce real scope-aware completion and active-formal signature help.

**Outcome**

Consumes frozen facade/result/context contracts from 3.4 and assessment from 2.3; implements only `Complete` and `GetSignatureHelp`. New class: `ToolingCompletion`. Keep area-local fixture helpers in that class so 3.3 need not share mutable helper files.

**Interfaces**

Consumes: `prerequisite 3.4 cursor context and 2.3 assessment`. Produces the proposed interface shape below and public test class `ToolingCompletion` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

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

## [ ] 3.3 Implement precise hover and definition queries over retained semantic bindings

Navigation must select the bound token and return authentic retained semantic information.

**Outcome**

Consumes the sealed-for-reading result and semantic selection primitives from 3.1; implements only `GetHover` and `FindDefinition`. New class: `ToolingNavigation`. No workspace reference index or documentation parser is introduced.

**Interfaces**

Consumes: `prerequisite 3.1 retained graph and token/reference selection`. Produces the proposed interface shape below and public test class `ToolingNavigation` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

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

## [ ] 3.4 Capture isolated cursor context after the declaration barrier

Cursor requests need isolated parse/sema state without editing formal compilation inputs.

**Outcome**

Create request-local parser/sema scratch state for incomplete bodies and active arguments. Excludes candidate ranking and navigation, and never inserts cursor tokens into the formal source or published AST.

**Interfaces**

Consumes: `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.h; frontend/Sema/as_sema.h; 3.1 retained inputs and 2.3 assessment`. Produces the proposed interface shape below and public test class `ToolingCursor` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

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

## [ ] 4.1 Close the producer matrix and prove the integrated diagnostic/tooling behavior without enabling legacy systems

Integration must prove actual producer-to-fix-to-query behavior and complete branch dispositions.

**Outcome**

New class: `DiagnosticsToolingIntegration`. This task integrates existing interfaces and evidence; a discovered product defect stays with its concrete evidence and does not grant unbounded source ownership. Replan the pending Files boundary if necessary rather than silently editing outside it. Consume `asCLanguageService` from 5.1 for format/fix round-trips; do not reimplement rendering or edit application.

**Interfaces**

Consumes: `prerequisites 1.1–3.4 and 5.1; no new runtime interface`. Produces the proposed interface shape below and public test class `DiagnosticsToolingIntegration` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

```cpp
// Use the implemented Builder -> GetDiagnosticResult -> AttachCompilation ->
// Format / ApplyFix -> fresh Analyze -> query sequence. No duplicate renderer or resolver.
```

**Cases**

1. **Real compile-fix-reanalysis** — new RED

    Compile Cout -> attach retained result -> format/inspect -> apply Count fix -> fresh analysis. Intended cause disappears; old result and ranges remain revision-bound and a stale alternative rejects the new revision.

2. **Partial source and determinism** — new RED

    Erroneous F plus independent valid G still supplies accurate queries without publishable definitions. Reverse two-file and host-input order, compare 1/4 workers: identical canonical diagnostics/semantic query data, explicit coverage and no formal-query mutation.

3. **Additional accepted boundaries** — boundary

    Cases: full Builder error -> language-service attach -> formatted text/JSON -> selected in-memory delimiter/name fix -> fresh analysis removes the intended cause; edit into a new revision invalidates prior ranges/handles/fixes rather than reusing them. An erroneous file still supports accurate independent hover/completion without becoming publishable. Repeat multi-file diagnostics and queries with reversed source/host input order and 1/4 workers, asserting identical stable semantic results and no formal-query side effects. All inventory source causes have independent expected data, not only a total diagnostic count; all internal/derived/API branches have their explicit preserved disposition.


    NativeEngine is the integrated scope because the Change changes shared Parser/Sema/source/AST/Builder contracts. Baseline separately proves old runtime/test dormancy; these are future operations, not creation-time checks. Omit Harness Quick/Performance/Integration, Standalone, legacy/full UE suites, VM/JIT and unrelated plugin tests unless new evidence or authority establishes their relevance.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticToolingIntegrationTests.cpp
 openspec/changes/angelscript/feature-frontend-diagnostics-tooling/tasks.md
 openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/INDEX.md
 openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md
+openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/implementation-verification.md
```

Globs are limited to this card's behavior and diagnostic compatibility adapters; dormant sources and unrelated language changes are excluded. New implementation files use the existing six phase directories. Shared files constrain scheduling, not the dependency graph.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }
```

Selected-workspace setup is in Global constraints. All named new cases must be discovered under `DiagnosticsToolingIntegration`; retain exact case results and source/binary identity. The NativeEngine selection includes adjacent consumers because this node changes a shared diagnostic, semantic, ownership or integrated contract.

**Notes**

Also run the exact `Angelscript.UnitTest.Baseline` prefix for legacy dormancy and strict validation of this Change after integration. Fresh mapped feature-group proof may be reused; unrelated Harness aggregate profiles, full UE suites, Standalone and VM/JIT execution are omitted unless new impact evidence warrants them. Inventory closure requires per-branch disposition, concrete expected payload, exact case/result and run provenance; a count-only or source-scan report is insufficient.

## [ ] 5.1 Expose an in-process language service for compile-time format and suggestion query

Hosts need a retained in-process diagnostic facade after compilation objects are released.

**Outcome**

Consumes owned groups, Clang-style rendering and `asCSourceEditApplier` from 1.4, plus the retained CompileOutput result from 2.4 with real unresolved-name notes/fixes from 2.2. Produces `asCLanguageService::Create`, `AttachCompilation`, `GetGroups`, `Format` and `ApplyFix` with `asLANGUAGE_SERVICE_DIAGNOSTICS` and `asLANGUAGE_SERVICE_FIXES`. New class: `LanguageService`. Do not implement JSON-RPC, document sync, `asCToolingSession` query wrappers, Engine creation or `asIScriptEngine` subclassing. Completion/hover/definition bits stay reserved and must report unavailability.

**Interfaces**

Consumes: `prerequisite 2.4 CompileOutput result accessor, 1.2 renderer and 1.4 edit applier`. Produces the proposed interface shape below and public test class `LanguageService` under `Angelscript.UnitTest.NativeEngine` (existing CQTest convention). Runtime names come from design.md and the existing SDK naming convention; task-local helper types are defined by this producing node.

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
