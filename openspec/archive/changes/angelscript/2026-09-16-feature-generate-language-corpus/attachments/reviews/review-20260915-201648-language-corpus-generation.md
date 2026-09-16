---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-15T20:16:48.077427+08:00
reviewed_at: 2026-09-15T20:17:07.364685+08:00
closed_at: 2026-09-15T20:17:55.451546+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260915-201648-language-corpus-generation
snapshot_sha256: 38e38263c653faa605e3eca3432bf5e2c6a2e8b0f20858ffc9007a4120918033
verdict: APPROVE
---

# Language corpus generation review

## Scope and stage

User asked whether verification is complete and to review the generated Language sources. This is an External Review of the frozen generation snapshot (659 files, parent `acb127e8539638b0a2ff6392b894d976a81b5bdb`), not a runtime compile/execute review and not an archive gate by itself.

Snapshot includes the Change records, 122 specialized generators plus the empty `FCodeGenerator` base, 122 product test TUs plus `LanguageGeneratorCorpusTests.cpp`, 122 representative golds, author rule files, and the 14.1 Harness summary/`index.json` for runId `d6bbeeb31cd544078d7ac3f8ba619f87`. Excluded: the live Review file, Legacy, generated-AS compile/execute, Unreal binaries, and unrelated dirty paths.

No Unreal rebuild or Automation rerun was started. Freshness used file `LastWriteTimeUtc` against the 14.1 report stamp `2026-09-15T12:00:40Z` / local `20:00:40+08:00`. Zero of 618 owned generator/test/gold/rule files are newer than that report. `task.status` reports 123/123 complete, remaining 0.

File references below are snapshot paths; live workspace links are convenience only.

## Finding F01 — Nine early product tests still keep file-level helper namespaces

severity: Advisory
status: deferred
follow_up: Relocate `ForLoop` through `OpLogicalNot` helpers into `TEST_CLASS_WITH_FLAGS` `private:` if a later hygiene pass is authorized; re-prove those nine prefixes after the move.

Location: `Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/Generate/{ForLoop,BranchCondition,Condition,LiveLocalCleanup,LoopCondTransfer,LoopDepth,NestedTarget,StatementTransfer,OpLogicalNot}GeneratorTests.cpp`.

Observation: Those nine TUs still wrap expected-cell tables in `namespace XxxTest` and, for ForLoop/BranchCondition, file-scope `using` aliases. The later 113 product TUs put typed tables and helpers in `private:` inside the test class and keep `using` inside `TEST_METHOD`.

Impact/evidence: This does not change generated `.as`, cell counts, or the 14.1 corpus proof. It is a maintainability drift from the helper-placement convention used for the rest of the library. Change task cards do not require in-class helpers.

Resolution condition: Optional. If enforced, move helpers into the class, drop file-level `XxxTest` namespaces, and re-run each product's `GeneratesAndExportsAllCases` plus `LanguageGeneratorCorpus.VerifiesCompleteCorpus`.

## Verified sound

Inventory and proof:

- `AngelscriptTestCode/Generators/INDEX.md` and `LanguageGeneratorCorpusTests.cpp` `BuildInventory` both list 122 products and the same partition `36686 = 28689 Normal + 5999 Reject + 1998 Fault`. Row-by-row Class/Cells/Normal/Reject/Fault compared with zero mismatches.
- 14.1 `Summary.json` Outcome `PassedWithWarnings`, `Passed=true`, `Complete=true`, `Failed=0`, `Errors=0`. `fullTestPath` `Angelscript.UnitTest.Framework.Generate.LanguageGeneratorCorpus.VerifiesCompleteCorpus` state `Success`. Duration 10.37s. Warnings are unrelated MetaSound tag noise.
- Unreal.log: `LanguageGeneratorCorpus products=122 cells=36686 passed=21359 skipped=7658 unsupported=564 exceptions=1106 rejects=5999`. Disposition sum is 36686. Normal-zero member `LANG-INH-CAST-CONST-SIBLING-IDENTITY_COMPARE`. Divide-by-zero member `LANG-FE-TRANSFER-LIFETIME-EXCEPTION-INSIDE_FOR-VALUE_OBJECT_CONST_REF`.
- Corpus fixture constructs every `F*Generator` directly, checks `ListCases` vs inventory, `OutCaseCount = Normal+Fault`, dump leaf `ClassWithoutF.as` with no underscore, PascalCase `EntryLangCfLoopDepthWhileZeroBreak`, unknown `GetExpected==0` is not membership, and exactly 122 registered `GeneratesAndExportsAllCases` methods.

Golds (122 files under `FrameworkTests/Gold/LanguageGenerators/`):

- UTF-8 without BOM, LF, final newline, tab indentation, no trailing whitespace, no `int Entry*_` underscore names.
- Sampled representative sources match the documented source shapes:
  - ForLoop: present/omitted clause headers and packed observation formula.
  - LoopDepth: WHILE/ONE/NONE and WHILE/TWO/BREAK bodies with shared helpers once.
  - OpAssignment: local/field/property plus `ApplyAssignAlias_int(Value, Source)` (full alias call, not a prefix-only needle).
  - OpUnary: `+`/`-`/`~` glyphs on mutable/const/temporary/field/alias rows.
  - ExprChain: `.opCast()` at depth TWO; invalid intermediate and missing terminal rows present.
  - FnParamPosition: object `Target = 1` before probe.
  - TransferValidity: five illegal transfer shapes plus SWITCH-BREAK / LOOP-BREAK / LOOP-CONTINUE.
  - SwitchPlacement: case/default outside switch, duplicate default, case-after-default in function/branch/loop/after-switch.
  - RegisteredFuncdef: reject-module source still emits named entries; corpus treats the product as reject-only with empty aggregate.

Generators and tests:

- 123 headers under `Framework/Generate` (122 products + `AngelscriptTestCodeGenerator.h`). 122 product test TUs. ForLoop public identity remains `Angelscript.UnitTest.Framework.ForLoopGenerator`; every other product uses `Angelscript.UnitTest.Framework.Generate.<ClassWithoutF>`.
- Product tests own dump write; corpus does not rewrite dumps or enable Legacy.

Out of scope by design (not a defect): generated AngelScript is not compiled or executed. Observation limits (ConvAbi host setup, PropRebuild SourceOnly, unsupported/skipped consumer rows) remain explicit.

## Verdict

APPROVE. The 122 products and 36,686 cells are present, golds match the formatting and naming contract, and the 14.1 corpus run is still a valid proof of this snapshot. F01 is Advisory and deferred. No Critical or Required finding.

Verification story: coordinator-supplied 14.1 runId `d6bbeeb31cd544078d7ac3f8ba619f87` plus a read-only inventory/gold/freshness audit of the snapshot. No new `ue.build` / `ue.test`.
