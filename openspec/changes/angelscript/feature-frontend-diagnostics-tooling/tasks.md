---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.1"]
    "2.2": ["2.1"]
    "3.1": ["2.2"]
    "3.2": ["3.1"]
    "3.3": ["3.1"]
    "4.1": ["1.2", "3.2", "3.3", "5.1"]
    "5.1": ["1.2", "2.2"]
---

## Authorized delivery and execution boundary

The user explicitly requested **Change creation only**. The following nine nodes are future product implementation; every checkbox remains unchecked until a later apply authorization. Planning validation and this replan do not authorize applying the tasks, UE execution, durable-spec synchronization, archive or Git operations.

Read `attachments/INDEX.md`, `design.md` and the owning rows of `attachments/data/diagnostic-migration-inventory.md` before later implementation. The catalog/producer inventory is a coverage aid, not a second execution ledger. Names introduced in design are proposed interfaces, not preexisting APIs.

Paths in Files are repository-relative. New implementation stays inside the maintained plugin; no `Legacy/**`, existing extension, host project, generated StaticJIT file, Skill or CLI source is included. Keep current canonical AS namespace and stable-key contracts. The separately planned testing framework is not an implementation prerequisite.

## Future verification setup

Use current replacement CQTest under `WITH_ANGELSCRIPT_TESTS`, with no ambient AS Engine or legacy force include. New test files below Diagnostics/ and Tooling/ use `TestDir = Angelscript.UnitTest.NativeEngine` and the exact class names listed in each card. The physical subdirectory is not part of the public identity.

After implementation is separately authorized, import Harness in the current PowerShell 7 process and select the current workspace:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command workspace.activate -Context $context
```

The coordinator alone schedules UE operations. Freeze source writers throughout each build and Automation run; an intervening edit invalidates binary evidence for that edit. For each feature group, prepare its related concrete cases, observe the expected RED together, implement that bounded outcome and rerun the same selection for GREEN. Compileable interface stubs may enable a genuine missing-behavior RED; never claim that tests first run after implementation were preimplementation RED.

Use a fresh incremental editor build for changed C++ before each proving phase:

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{
    Target = 'AngelscriptProjectEditor'
    Platform = 'Win64'
    Configuration = 'Development'
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    TimeoutMs = 3600000
}
```

Compatible Ready groups may share a supported common-prefix proving selection. For example, a justified NativeEngine run can cover DiagnosticsPresentation plus DiagnosticsSyntax, and `Angelscript.UnitTest.NativeEngine.Tooling` can cover completion and navigation together. Preserve exact task-to-case mapping, RunId, report path and source/binary identity. Sharing one run does not bypass DAG dependencies, prove cases that were not discovered, or turn a partly failing report green. No one-process-per-case policy and no promise of one total run per group applies.

Ordinary local failures stay inside the owning task. Replan only when evidence invalidates an accepted requirement, interface handoff, Files scope, DAG dependency or verification boundary. Do not add routine Review nodes.

## 1. Diagnostic authority and presentation

- [ ] 1.1 Implement the catalog, owned diagnostic groups and independent policy/failure facts — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_diagnostic*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_builder_stages.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticCoreTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/SourceDiagnosticsTests.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder_frontend.cpp`, `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md`

  The package-wide `.cpp` ownership is **only mechanical consumer adaptation** to the new diagnostic collection/view API; exclude semantic producer migration, parsing/call/type rules, AST/metadata algorithms and all Legacy files. Reserve concrete catalog entries for every inventory reason without claiming that the producer uses them yet. Keep old generic meanings reserved. Move presentation implementation behind `as_diagnostic_renderer.*` so 1.2 can work without editing collection semantics.

  Produces `asSDiagnosticGroup`, `asCDiagnosticResult`, immutable `asSDiagnosticOptions`, concrete catalog descriptors, optional source validation and an adapter for existing observation consumers. New class: `DiagnosticsCore`.

  Cases: primary in `A.as` with a note in `B.as` stays one group under reversed fragment submission and 1/4 workers; an explicit nonlocated input error is retained; a provided foreign-snapshot range is rejected; disabled warnings, per-ID/group/global precedence and Werror preserve warning identity; a hidden error still fails validity; limit 1 retains a whole primary/notes/fixes group and marks truncation; retained diagnostic rendering data survives release of caller source references. Existing SourceDiagnostics byte-range/provenance tests remain regression controls.

  1. Expand the inventory to branch-level dispositions and required typed arguments/ranges/notes/cases; add grouped core tests with expected RED for flat-note ordering, dropped nonlocated errors, missing ownership and absent policy facts.
  2. Implement the catalog/result/policy contracts and minimum compilation-coherent adapters, without pretending generic producers have migrated. Establish deterministic ordering and whole-group retention.
  3. Run grouped GREEN and retain exact case evidence. NativeEngine is justified here by the shared diagnostic consumer contract used across every existing frontend family; no legacy/full UE suite is implied.

- [ ] 1.2 Implement faithful text/JSON presentation, explicit positions and atomic source-edit application — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.DiagnosticsPresentation'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_diagnostic_renderer.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_position_codec.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_edit.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticPresentationTests.cpp`

  Consumes owned groups/fix alternatives from 1.1; produces `asCSourcePositionCodec`, `asCSourceEditApplier::Apply`, complete diagnostic JSON and Clang-style text from `asCDiagnosticRenderer`. New class: `DiagnosticsPresentation`. Do not generate syntax/typo fixes here; use controlled record fixtures to prove this transport/presentation outcome. Task 5.1 wraps the same renderer through `asCLanguageService`; do not create that facade here.

  Cases: exact JSON preservation of semantic arguments, notes, highlights, two alternatives and replacement bytes; a 64-bit revision beyond JavaScript's exact integer range remains a string; source-less text has no fake line; tab/multiline carets and malformed-byte display remain deterministic. For the decoded Unicode sequence `A\u4E2D\U0001F600\r\nZ` encoded as UTF-8, byte offset 8 maps to UTF-8 `(0,8)` and UTF-16 `(0,4)`, offset 10 maps to `(1,0)`, EOF 11 maps to `(1,1)`; offset 9 and an interior UTF-16 surrogate position are rejected. Preserve native one-based byte presentation APIs.

  Constructed unresolved-name fixture: primary range on `Cout`, note and unique fix naming `Count`. Independently authored expected text must include the invalid identifier, a caret under that use, a note naming `Count` and a caret or range on the suggestion. Do not assert by formatting twice and comparing the formatter to itself.

  Edits: insert `;` at a zero-length range; replace an identifier; apply two disjoint edits atomically; reject overlap, two conflicting same-point insertions, changed source revision/expected bytes, foreign file and unmappable synthetic source without modifying any supplied buffer.

  1. Add the structured-output/position/edit and constructed caret-suggestion cases; observe RED for missing JSON fields, absent encoding conversion, unsupported atomic preconditions and text that omits the identifier caret or suggestion note.
  2. Implement rendering/codec/edit application against immutable source authority; keep this a native in-memory operation with no LSP or file writer.
  3. Rerun the exact group for GREEN and verify every field with independent expected values, not by comparing two calls to the same formatter.

## 2. Complete producer migration

- [ ] 2.1 Migrate every lexical, preprocessing, parser and annotation-collection cause with precise recovery and safe delimiter proposals — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_tokenizer.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tokenizer.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_parser.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_diagnostic_catalog.def`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticSyntaxTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/**`, `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md`

  Sema ownership here is limited to parser reporting/recovery and annotation collection; do not implement the remaining semantic causes owned by 2.2. Existing test-folder changes are diagnostic assertion/fixture migrations, not unrelated language expansion. New class: `DiagnosticsSyntax`.

  Concrete cases: byte sequence `0xC0,0xAF` advances and diagnoses malformed UTF-8 without a second semantic literal error; unclosed string/comment selects the original bytes; `#if defined(\n#endif` reports its malformed condition while an unknown flag in an unevaluated operand retains current short-circuit behavior; unexpected/duplicate/missing conditional directives have distinct causes and paired locations where available. `int F(){ return 1 } int G(){ return 2; }` proposes a semicolon immediately after `1`, preserves `G`, and does not claim `F` valid. Invalid parameter annotation must produce a real structured diagnostic instead of only an invalid bit. Removed syntax remains rejected, while comments/strings/skipped branches retain their current meaning.

  The inventory's complete declaration/expression/statement reason lists are mandatory additional cases, including generic helper `false` returns and every `MalformedCondition` branch. Existing valid lexer/token-boundary, annotation/delegate/event and control-flow cases are regression controls, not new RED claims.

  1. Add concrete cause/range/note/recovery assertions across the bounded producer families; run RED together for generic IDs, silent annotation errors and absent delimiter suggestions.
  2. Migrate each source-producing branch, retain original token progress/provenance and route parser body failures through concrete catalog causes. Populate only safe proposed edits; 1.2 owns their application.
  3. Run GREEN and map each inventory branch to its real scenario. The NativeEngine superset is justified by parser recovery and diagnostic API changes spanning Lexer, PP, declarations, bodies and reflection; it may also prove an independently ready presentation group.

- [ ] 2.2 Migrate semantic/session/Builder causes and share side-effect-free candidate assessment — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_call_assessment.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_diagnostic_catalog.def`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_definition_consumer.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_builder_stages.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder_frontend.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticSemanticTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/DefinitionConsumerTests.cpp`, `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md`

  Produces structured type-resolution failure reasons, `asSCallAssessment`/`asSCandidateAssessment`, assessment-versus-commit call paths, contextual typo proposals and nonduplicating Builder results. Do not change language conversion ranking, stable-key meaning, metadata registration or runtime execution. New class: `DiagnosticsSemantic`.

  Cases: `int F(){ int Count=1; return Cout; }` gives an unresolved-name root, one viable `Count` suggestion and its exact edit; adding equally viable `Court` makes the suggestion advisory. Distinct unknown-type, generic-arity and invalid-qualifier inputs produce distinct underlying causes. Duplicate declarations in `A.as`/`B.as` attach the conflicting ranges in stable order. A failed conversion exposes actual/expected qualified types. Call `Pick(1,2)` against one-parameter overloads to prove candidate arity reasons; existing nonnumeric conversion, `out`/`inout`, named/default argument, access, receiver-const, lambda and list-factory fixtures prove each candidate rejection family.

  Preserve every inventory cause, including constant divide-by-zero versus invalid shift/cycle/budget, inheritance cycle versus depth budget, access policy errors and the three actual warning families. A host candidate with unsupported default must not abort inspection of a valid later candidate. Assess a complete call twice and assert the same candidate/rank with no formal AST/diagnostic/image changes; only the normal commit creates conversion/default nodes.

  Builder cases: invalid options before lexing yields a nonlocated error; existing root errors are emitted once rather than 5001/3003 text wrappers; definition range and exact metadata/verifier status survive aggregation; an illegal stage request does not consume/poison the prior successful stage; a hidden language error still blocks definitions; a real warning under Werror blocks build without adding Recovery nodes. An independent later invalid statement remains diagnosed after one earlier invalid expression.

  1. Add grouped semantic/driver/candidate negative and boundary tests; observe RED for text-only declaration failures, generic rejection messages, mutating assessments, duplicate wrappers and silent nonlocated failure.
  2. Implement the complete bounded migration, extracting assessment from both script and host resolution and preserving internal/status-versus-source distinctions. Carry safe independent analysis past errors without weakening normal publication.
  3. Run GREEN and close every owned producer branch with concrete evidence. NativeEngine is required here because shared lookup/conversion/Builder contracts affect declarations, bodies, definitions and type/AST consumers.

## 3. Native semantic queries

- [ ] 3.1 Implement owned partial analysis and isolated cursor-query foundations — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tooling_session.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tooling_completion.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tooling_navigation.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tooling_types.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_analysis_result.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_cursor_context.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_semantic_selection.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_parser.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_token.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_token_kinds.def`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_context.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_ast_context.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_verifier.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_ast_verifier.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingAnalysisTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/NativeToolingTestSupport.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/AST/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp`

  Produces the five facade declarations and result types defined in design, real `Analyze`, owned `asCAnalysisResult`, isolated cursor context and token/reference selection primitives. Create completion/signature unavailable stubs only in `as_tooling_completion.cpp` and hover/definition unavailable stubs only in `as_tooling_navigation.cpp`; never define these functions in the session file or shared header. Tasks 3.2/3.3 subsequently replace only their respective file's stubs with real implementations. Unimplemented entrypoints explicitly report unavailable rather than fake successful empty results. New class: `ToolingAnalysis`.

  Cases: retain source/AST/type/host data after releasing caller Builder/input/image references; traverse a recovery-containing result after worker join while normal AST codec/DefinitionsFrozen reject it; reject a foreign handle even with equal FileID or identical bytes under different host options; cancellation before analysis and during bounded work reports Cancelled, not Success(empty); invalid byte/EOF positions are distinguished. For `void F(){ int Outer=1; { int Inner=2; | } }`, the isolated cursor context captures the actual nested scope, does not alter source offsets and leaves formal projections/diagnostics unchanged. Include `obj.|`, unclosed calls and a later-file type to prove cursor preparation still establishes the global declaration barrier.

  1. Prepare lifetime/partial-state/cursor-context tests, using a fixture marker removed before snapshot creation; observe RED for unavailable ownership-safe analysis and absent isolated cursor context.
  2. Implement result ownership, separate `FreezeForTooling`, explicit statuses/coverage and read-only selection/context capture. Do not set valid sealing flags or resolve against a half-collected source set.
  3. Run GREEN with normal AST verification/codec and Builder regression controls. The NativeEngine scope is justified by shared AST mutation barriers and session phases, not by an LSP integration claim.

- [ ] 3.2 Implement contextual completion and signature help using shared assessment — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingCompletion'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tooling_completion.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingCompletionTests.cpp`

  Consumes frozen facade/result/context contracts from 3.1 and assessment from 2.2; implements only `Complete` and `GetSignatureHelp`. New class: `ToolingCompletion`. Keep area-local fixture helpers in that class so 3.3 need not share mutable helper files.

  Cases: accessible `class Item { int Value; }` member appears after `Item obj; obj.|`; private/incompatible receiver members do not appear as applicable. Inner locals shadow outer names, later locals are absent before their declaration, and a known expected type influences deterministic ranking without hiding candidates when the type is unknown. Partial identifiers have exact replacement ranges; comments/strings/inactive bodies yield empty ordinary semantic completion; namespace/type/keyword contexts use real grammar.

  For `int Pick(int First, int Second=2);` test cursor positions in `Pick(|`, `Pick(1, |` and `Pick(Second: |`; active formal mapping must follow `Second` rather than textual ordinal zero. The complete control `Pick(Second: 4, First: 3)` maps authored arguments to formal ordinals 1 then 0, matching the existing `NamedArgumentsReorderByParameterWithoutLosingAuthoredOrder` fixture. Nested `Outer(Inner(1, |` selects Inner; moving the cursor outside Inner selects Outer. Compare completed-call candidates and selected overload with ordinary compilation; retain candidates whose future arguments are merely unknown. Cover lambda/list context and frozen-host candidates, including unsupported defaults on an unrelated candidate. Assert formal AST, diagnostics and image projections unchanged after each query.

  1. Add grouped actual-source query tests; observe explicit unavailable/absent candidate behavior as RED, not success on hand-built expected candidates.
  2. Implement deterministic completion/parameter mapping over the cursor and assessment primitives, without a second name/type system, workspace index, TS fallback or ordinary diagnostic side effects.
  3. Rerun this prefix for GREEN. A shared `Angelscript.UnitTest.NativeEngine.Tooling` run may also prove an independently Ready navigation task when exact cases/results are mapped.

- [ ] 3.3 Implement precise hover and definition queries over retained semantic bindings — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ToolingNavigation'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tooling_navigation.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Tooling/ToolingNavigationTests.cpp`

  Consumes the sealed-for-reading result and semantic selection primitives from 3.1; implements only `GetHover` and `FindDefinition`. New class: `ToolingNavigation`. No workspace reference index or documentation parser is introduced.

  Cases: `int F(){ int Value=1; return Value; }` resolves the return use to the local declaration with type `int`, not the enclosing function; inner shadowed names and qualified/member components select their actual declarations; resolved overload use points to the chosen overload, with real cross-file definition first and declaration fallback ordered/deduplicated. Probe identifier interior/end, following whitespace, punctuation, comment, EOF and unbound recovery. At `Value|;`, the containing semicolon wins and returns empty; at a bound `Value|` ending at EOF with no containing token, identifier-end lookup is allowed. A frozen-host function with a valid signature but no location returns useful hover and `NoSourceTarget`, never a made-up script line. Changed input/environment identity and cancelled requests return their specific statuses; unchanged repeated queries do not mutate formal data.

  1. Prepare exact target-range/type/signature and empty/error-result cases; observe unavailable navigation RED through the native facade.
  2. Implement token/reference-driven hover and authentic target projection with owned payloads and deterministic ordering.
  3. Rerun the same group for GREEN, preserving proof that caller-owned input/image references can already be released. Compatible Ready 3.2 work can share one Tooling proving run with separate case maps.

## 4. Integrated completion proof

- [ ] 4.1 Close the producer matrix and prove the integrated diagnostic/tooling behavior without enabling legacy systems — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/DiagnosticToolingIntegrationTests.cpp`, `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/tasks.md`, `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/INDEX.md`, `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md`, `openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/implementation-verification.md`

  New class: `DiagnosticsToolingIntegration`. This task integrates existing interfaces and evidence; a discovered product defect stays with its concrete evidence and does not grant unbounded source ownership. Replan the pending Files boundary if necessary rather than silently editing outside it. Consume `asCLanguageService` from 5.1 for format/fix round-trips; do not reimplement rendering or edit application.

  Cases: full Builder error -> language-service attach -> formatted text/JSON -> selected in-memory delimiter/name fix -> fresh analysis removes the intended cause; edit into a new revision invalidates prior ranges/handles/fixes rather than reusing them. An erroneous file still supports accurate independent hover/completion without becoming publishable. Repeat multi-file diagnostics and queries with reversed source/host input order and 1/4 workers, asserting identical stable semantic results and no formal-query side effects. All inventory source causes have independent expected data, not only a total diagnostic count; all internal/derived/API branches have their explicit preserved disposition.

  1. Add the integrated source/fix/query cases before any integration repair. Run grouped RED if missing cross-component behavior remains; if prior feature groups already satisfy these integration controls, record baseline GREEN honestly rather than manufacturing RED.
  2. Run the fresh mapped NativeEngine gate, audit every inventory row and retain source/binary identities, RunIds, complete paths/results and report provenance. Aggregate counts or missing cases cannot close the matrix.
  3. Run the additional dormancy gate `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline'; Fast = $true; TimeoutMs = 600000 }` and strict Change validation `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-frontend-diagnostics-tooling', '--strict', '--json')`. Record every intentionally omitted heavier operation and reason.

  NativeEngine is the integrated scope because the Change changes shared Parser/Sema/source/AST/Builder contracts. Baseline separately proves old runtime/test dormancy; these are future operations, not creation-time checks. Omit Harness Quick/Performance/Integration, Standalone, legacy/full UE suites, VM/JIT and unrelated plugin tests unless new evidence or authority establishes their relevance.

## 5. In-process SDK language service

- [ ] 5.1 Expose an in-process language service for compile-time format and suggestion query — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.LanguageService'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_language_service.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_language_service.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Diagnostics/LanguageServiceTests.cpp`

  Consumes owned groups, Clang-style rendering and `asCSourceEditApplier` from 1.2, plus real unresolved-name notes/fixes from 2.2. Produces `asCLanguageService::Create`, `AttachCompilation`, `GetGroups`, `Format` and `ApplyFix` with `asLANGUAGE_SERVICE_DIAGNOSTICS` and `asLANGUAGE_SERVICE_FIXES`. New class: `LanguageService`. Do not implement JSON-RPC, document sync, `asCToolingSession` query wrappers, Engine creation or `asIScriptEngine` subclassing. Completion/hover/definition bits stay reserved and must report unavailability.

  Cases: compile `int F(){ int Count=1; return Cout; }` without an Engine; attach the Builder diagnostic result; `Format` of the unresolved-name group matches an independently authored expected string that names `Cout` with a caret and a note naming `Count`; structured note/fix accessors expose the suggested identifier and replacement bytes without parsing that text; `ApplyFix` of the unique alternative yields a new snapshot whose re-analysis no longer reports that unresolved-name cause; the original snapshot and attached result are unchanged. Constructing with only `asLANGUAGE_SERVICE_DIAGNOSTICS` makes `ApplyFix` and reserved query features unavailable while `GetGroups`/`Format` still work. A successful empty diagnostic attachment is distinct from those unavailable statuses. No `asCreateScriptEngine` call occurs.

  1. Add the compile-attach/format/inspect/apply and feature-flag cases; observe RED for a missing facade, text-only notes or Engine-backed formatting.
  2. Implement the in-process facade over the existing renderer and edit applier, attaching the original diagnostic result rather than copying groups into a second authority.
  3. Rerun this prefix for GREEN. Compatible Ready 1.2 presentation cases may share a NativeEngine proving run when exact case maps are retained; this node is not proven by presentation fixtures alone.

## Requirement-to-outcome mapping

- Source-diagnostics catalog/groups/policy: 1.1; full real producer behavior: 2.1 and 2.2; source presentation/edits: 1.2; compile-time SDK format/note/fix facade: 5.1; actual producer-fix-reanalysis integration: 4.1.
- Builder stage/root-cause/state contract and declaration/body explanation/recovery: 2.2, with syntax/collection recovery supplied by 2.1.
- AST partial-read ownership and tooling input/status/barrier contract: 3.1, with normal publication regression controls retained.
- Tooling candidate assessment: 2.2; cursor completion/signature: 3.2; precise hover/definition: 3.3; cross-family result consistency: 4.1.

Future closure follows the existing verify/sync/archive Skills after product verification and explicit continuation. Creation does not synchronize these proposed deltas into current specs or record any task complete. Commit, push and workspace actions are not tasks in this Change.
