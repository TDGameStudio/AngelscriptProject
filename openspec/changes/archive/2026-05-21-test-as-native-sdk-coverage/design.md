## Context

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` currently has four white-box test files for the native compiler core, totaling 17 `TEST_METHOD` cases (see `proposal.md`). Each layer already has minimal infrastructure for internal-state access (`FTokenizerAccessor : asCTokenizer` exposing `GetToken`; `FParserAccessor : asCParser` exposing `Reset` / `ParseExpression` / `ParseStatement`; direct `asCByteCode` construction through `asCBuilder`), but each file only covers 3-5 representative scenarios. Large branches remain unpinned: the full token taxonomy, operator matrix, AST node shapes, opcode buckets, jump resolution, and error recovery.

The project is in a maturity stage where core runtime / editor / test infrastructure are stable. The AS fork baseline is 2.33 + selective 2.38 backports (`Documents/Guides/AngelscriptForkStrategy.md`), and the project continues to surgically absorb upstream improvements. This fork strategy raises the need for behavior-locking tests over the native compiler core: any uncovered branch can become a regression source during each backport.

Reference material already exists in `Reference/angelscript-v2.38.0/sdk/tests/test_feature/source/test_compiler.cpp` (6286 lines), `test_parser.cpp`, and `testlongtoken.cpp`, but these are not connected to the project test runner. Use them as scenario inspiration, not direct ports; rewrite cases as CQTest-style project tests.

Constraints:

- Follow `Documents/Guides/TestConventions.md` §1 (test layer matrix): Native Core tests live under `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`, use prefix `Angelscript.TestModule.AngelScriptSDK.*`, use helpers from `AngelscriptNativeTestSupport.h` / `AngelscriptTestAdapter.h`, and do not introduce `FAngelscriptEngine`.
- Follow `Documents/Rules/ASInlineFormattingRule.md` (column-0 origin, Tab indentation, Allman braces, `R"(...)"` or `R"AS(...)AS"`); ASSDK-layer tests must not use `\n` string concatenation.
- Use `Tools/RunTests.ps1` / `Tools/RunTestSuite.ps1` as standard entry points, with every command carrying an explicit timeout (`Documents/Guides/Test.md` mandatory constraint).

## Goals / Non-Goals

**Goals:**

- Raise native SDK four-layer coverage from sample-level to systematic (17 → ~132 `TEST_METHOD`) without changing product code.
- Keep each layer mergeable as an independent PR; the completion standard for each PR is a green sub-prefix `RunTests.ps1` run plus no regression in the full `Angelscript.TestModule.AngelScriptSDK` group.
- Keep all shared helpers inline header-only in the existing `AngelscriptNativeTestSupport.h` namespace; do not create new `*Helpers.h` files.
- Do not change class names / Automation prefixes in the existing four core files (`AngelscriptTokenizerTests.cpp`, `AngelscriptParserTests.cpp`, `AngelscriptScriptNodeTests.cpp`, `AngelscriptBytecodeTests.cpp`), avoiding discovery regressions.
- Split files by topic, about ~10 `TEST_METHOD` / 150-300 LOC per file, to keep review easy and avoid single-file incremental compile bloat.

**Non-Goals:**

- Do not modify product code (zero behavior change).
- Do not connect or port `Reference/angelscript-v2.38.0/sdk/tests/` as a separate native suite entry point.
- Do not add or modify Reference SDK code.
- Do not close debt items already listed in `TechnicalDebtInventory.md`.
- Do not add or modify Automation groups or `DefaultEngine.ini` entries; the existing `AngelscriptNative` group already globs `Angelscript.TestModule.AngelScriptSDK.*`.
- Do not require exhaustive 100% enumeration (for example, all ~200 opcodes); this round targets representative and high-value boundaries.
- Do not add "must support" assertions for uncertain features such as lambdas, octal literals, or nested block comments; use behavior-locking names such as `_OrDocumentReject` / `_DocumentBehavior`.

## Decisions

### D1. Use the OpenSpec flow

**Choice**: use the full OpenSpec change lifecycle (propose → apply → archive), change-id `test-as-native-sdk-coverage`, with no product-code changes beyond the SPEC delta.

**Why**: even though this has zero product-code changes and could be considered low-risk enough to skip OpenSpec under `AGENTS.md`, the scope (12 files / ~3000-5000 LOC / 4 phases) and multi-phase landing benefit from a tracked proposal. `tasks.md` is the only implementation plan, and phase checkboxes act as progress signals.

**Alternative**: skip OpenSpec and open a direct PR — rejected, because it loses archival and multi-person collaboration visibility.

### D2. Split files by topic (three new files per layer)

**Choice**: add three `AngelscriptNative<Layer><Topic>Tests.cpp` files per layer, without touching the existing four files and without putting every new case in one file.

**Why**: existing files keep their "smoke / sanity entry point" meaning. New files are organized by subtopic (for example, Tokenizer split into Literals / Operators / Whitespace), giving clear review boundaries, keeping each file ≤ 300 LOC, and limiting incremental compile cost. `Documents/Guides/TestConventions.md` §2 ASSDK / Native rules require `AngelscriptNative*Tests.cpp` naming.

**Alternative**: append everything to the existing four files — rejected; each file would grow to 1500+ LOC, violating the "clear topic" intent of §2 naming rules and making review difficult.

**Alternative**: create one mega file per layer — rejected for the same reason, and because it loses the topic dimension.

### D3. Automation prefixes use layer + topic

**Choice**: each new `TEST_CLASS_WITH_FLAGS` uses `Angelscript.TestModule.AngelScriptSDK.<Layer>.<Topic>` paths (for example, `…AngelScriptSDK.Tokenizer.Literals`), and is collected automatically through the existing `AngelscriptNative` group glob `Contains="Angelscript.TestModule.AngelScriptSDK.,MatchFromStart=true"`.

**Why**: this follows the layer-first prefix strategy in `TestConventions.md` §4, avoids a new `DefaultEngine.ini` group, and allows each sub-prefix to be run independently with `RunTests.ps1 -TestPrefix "…AngelScriptSDK.Tokenizer"`.

**Alternative**: use a flat `…AngelScriptSDK.<Topic>` prefix without Layer — rejected, because it loses layer ownership and mixes Tokenizer and Bytecode topics at the same level.

### D4. Keep all helpers inline in `AngelscriptNativeTestSupport.h`

**Choice**: add seven helpers (`CreateBareSdkEngine`, `TokenizeAll`, `CountNodesOfType`, `NodeTypeHistogram`, `MaxNodeDepth`, `DumpBytecodeOpcodes`, `EmitToBuffer`) as inline functions inside the existing `AngelscriptNativeTestSupport` namespace.

**Why**: existing helpers (`FNativeMessageCollector`, `CreateNativeEngine`, `CompileNativeModule`, `PrepareAndExecute`) already use the inline header-only pattern. Keeping the pattern avoids a new compilation unit, and every new file can immediately use `#include "AngelscriptNativeTestSupport.h"`.

**Alternative**: create `AngelscriptNativeSdkInternalTestSupport.h` to distinguish "public API helpers" from "internal accessor helpers" — rejected; the helper count is small (7 vs 6), and splitting would add cognitive overhead instead of reducing it.

### D5. Reuse the existing accessor pattern

**Choice**: Tokenizer uses `struct FTokenizerAccessor : asCTokenizer { using asCTokenizer::GetToken; };` (already in `AngelscriptTokenizerTests.cpp`); Parser uses `struct FParserAccessor : asCParser` (already in `AngelscriptParserTests.cpp`, exposing `Reset` / `ParseExpressionSnippet` / `ParseStatementSnippet`). New files copy these accessors into their own anonymous / private namespaces.

**Why**: this is the established project pattern and does not introduce a new mechanism. Each file keeps isolation through its own anonymous namespace.

**Alternative**: move accessors into the shared header (`AngelscriptNativeTestSupport.h`) — rejected; `asCTokenizer` and `asCParser` are fork-internal headers (`source/as_tokenizer.h`, `source/as_parser.h`) that need `StartAngelscriptHeaders.h` / `EndAngelscriptHeaders.h` isolation. Putting them in the shared header would pollute every includer; local declarations are cleaner.

### D6. Use behavior-locking names for uncertain features

**Choice**: for features whose current fork support is uncertain, such as lambdas, octal literals, and nested block comments, suffix test names with `_OrDocumentReject` / `_DocumentBehavior` / `_IfSupported`, and assert current actual behavior rather than mandatory support.

**Why**: the fork currently targets 2.33 + selective 2.38, and some 2.38 features may not have been backported. Pre-studying every feature's support status would be more expensive than writing the case. Behavior-locking tests avoid assuming either support or rejection; they pin the current response, and if a future backport changes behavior, the test fails loudly and can be updated intentionally.

**Alternative**: research support status for every feature before backporting — rejected; the cost is higher than writing the cases, and many token/parser boundaries cannot be reliably confirmed from docs ahead of time.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Existing 17-test discovery breaks | Do not change class names / prefixes in the existing four files; before each phase submission, run the full `Angelscript.TestModule.AngelScriptSDK` prefix and confirm existing cases still pass 100% |
| AS internal APIs drift (`asCByteCode`, `asCScriptNode` fields reshape during selective 2.38 backports) | Tests use only fields exposed in the current fork baseline (`2.33 + selective 2.38`); cases such as `InstrSizeMatchesInfoTable` validate indirectly via `asBCInfo[op].type` → `asBCTypeSize[]` instead of hard-coding sizes |
| Test runtime grows too much | All ~115 cases are in-memory-level tests (no module `Build()`), expected to run in milliseconds each and add < 10s total, far below the 600000ms default budget |
| Class-name conflicts across phases | Use uniform `F<File>` class prefixes (for example, `FAngelscriptNativeTokenizerLiteralsTests`); each file uses an independent `namespace ..._Private` to avoid helper-name collisions |
| Uncertain feature support causes false positives | Use `_OrDocumentReject` names plus behavior-locking assertions (see D6) |
| Reference SDK inspiration is insufficient or old | After Phase 0, before each phase starts, quickly scan `test_feature/source/{test_compiler,test_parser,testlongtoken}.cpp` to extract layer-relevant scenarios; do not port directly, rewrite in CQTest style |
| `ASInlineFormattingRule.md` misuse causes review churn | Check each file's first raw string with the review template (column 0, Tab indentation, Allman braces); after Phase 0 helpers, optionally write a lint helper or keep a fixed self-checklist in the PR description |

## Migration Plan

There is no runtime migration; this is pure test addition with zero product behavior change.

Landing proceeds by phase, one PR per phase:

1. **Phase 0 — Helpers**: append seven inline helpers to `AngelscriptNativeTestSupport.h`; existing 17 tests still pass 100%.
2. **Phase 1 — Tokenizer**: three new files, ~30 cases; `…AngelScriptSDK.Tokenizer.*` passes.
3. **Phase 2 — Parser**: three new files, ~35 cases; `…AngelScriptSDK.Parser.*` passes.
4. **Phase 3 — ScriptNode**: three new files, ~25 cases; `…AngelScriptSDK.ScriptNode.*` passes.
5. **Phase 4 — Bytecode**: three new files, ~25 cases; `…AngelScriptSDK.Bytecode.*` passes; update `TestCatalog.md` / `Test.md` / `Plugins/Angelscript/AGENTS.md`; archive via `openspec-archive-change`.

After each phase:
- Run the layer sub-prefix plus full `Angelscript.TestModule.AngelScriptSDK` prefix regression (commands in `tasks.md`).
- Check the corresponding checkbox in `tasks.md`.
- Submit a PR, wait for review / merge, then proceed to the next phase.

Rollback strategy: each phase is an independent PR. If any phase reveals a non-test problem (for example, fork internal API already changed), revert only that PR; already-merged previous phases remain unaffected.

## Open Questions

- Q1: Does the fork currently accept or reject lambda expressions / octal literals / nested block comments / heredoc strings (`asEP_ALLOW_MULTILINE_STRINGS`)? **Resolution path**: do not answer this in the propose phase; when a case is first written during apply, measure current behavior and lock it with a comment (see D6 behavior-locking mode).
- Q2: Does `asCByteCode::Optimize()` expose a stable enough interface in this fork for direct test calls? **Resolution path**: at the start of Phase 4, inspect the current public method surface already used by the four existing `AngelscriptBytecodeTests.cpp` cases, then decide whether cases such as `OptimizeReducesOrPreservesSize` need an accessor friend.
- Q3: Is `Reference/angelscript-v2.38.0/sdk/tests/` `testlongtoken.cpp` worth porting as a separate file? **Resolution path**: a single Phase 1 case `LongIdentifierBoundary` is enough for the core scenario; do not create a dedicated file for it.
