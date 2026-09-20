---
replan_id: replan-20260912-123336-unified-tokenizer-test-boundary
status: applied
source: user
source_ref: "2026-09-12 request to replan this Change, evaluate std::string, improve Lexer coverage, and design one owned-input/output helper with bounded negative generation and a future TestCode seam"
scope: "Lexer-only tokenizer fixture, independent vocabulary oracle, exact recovery coverage, and three-node Task DAG; no C++ implementation"
base_commit: ef2e473c886da39e5f3942f783062c6366e9ba3c
base_tasks_sha256: 84615484baa7217b60a782437d412a171e656aa278e802ecebc63cd1db333b9a
result_tasks_sha256: c6648f712b18c74340ede13a4b94ac8fb78e6826c49704bf231ca30f5347d689
created_at: 2026-09-12T12:33:36+08:00
resume_task: "1.1"
---

## Trigger and Evidence

The user explicitly requested a replan and asked for a more unified Lexer test object, direct helper checks, bounded generated negative cases, approximate resulting usage, and a clean seam for the later common TestCode work. Inspection invalidated three accepted planning assumptions: the live source declares 17 contract methods rather than 16; the proposed spelled-kind walk generated input from the same `.def` table consumed by tokenizer punctuation/keyword recognition and could therefore self-confirm deletion or retargeting; and the current durable lexing contract requires table-driven malformed-input termination/recovery while the old mixed case checks only aggregate diagnostics.

The inspected source boundaries support a stronger local design. `FSourceInput::FromText` performs the project-standard `FTCHARToUTF8` conversion, `asCSourceSnapshot::AddFile` copies an explicit `TConstArrayView<uint8>`, `asSLexOptions` is copy-constructible but deliberately non-assignable, `asCTokenizer` owns a frozen option copy, and UE 5.8 CQTest exposes `FNoDiscardAsserter::Fail(FString)`. The workspace also contains the user-reserved empty `NativeEngineTokenizerTest.h/.cpp` pair. The separate `angelscript/refactor-testing-unified-framework` Change already owns generic source identity/history, catalogs, typed rows, artifacts, and reusable generators.

The parent HEAD advanced externally from `46c9c66d4f727d87687807c775f2b3dced36094e` to the recorded base commit while this candidate was prepared. The only parent-level overlap was the `Plugins/Angelscript` gitlink; comparison of its old/new submodule commits found no change to the tokenizer, source snapshot/manager, diagnostics, Lexer test, NativeEngine support, or reserved helper paths. The original task hash also remained unchanged, so the candidate evidence and semantic patch stayed applicable.

## Decision

Replace the free `FLexerSource` / `CheckLex` plan with `AngelscriptNativeEngineTest::FNativeEngineTokenizerTest`. Named factories distinguish authored text from byte-exact input; the object owns bytes and a movable out-of-line run state, freezes extracted option enum values, performs at most `byte_count + 1` pulls, captures tokens and emitted diagnostics once, renders `Describe()`, and offers concise `CheckKinds` plus detailed `Check` through an explicit CQTest asserter.

Keep the 107-row dynamic spelled-token round trip for breadth, but add a fixed 64-bit FNV-1a acceptance fingerprint `0xa912c3f84387564e` over all 115 kind/spelling rows plus explicit maximal-munch cases. Add a third `Recovery` scenario with 16 exact input-only malformed-UTF-8 rows, fixed recipe fingerprint `0x5b75772962a8f9f5`, and independently authored progress, flags, diagnostic identity/range, NUL/unknown, Unicode, string, comment, and trivia expectations. Do not add `std::string`: it neither represents UE text encoding nor improves the existing explicit raw-byte boundary.

## Impact

The Change remains Lexer-only and planning-only. Public scenarios become `Contracts`, `SpelledKinds`, and `Recovery` beneath `Angelscript.UnitTest.NativeEngine.Lexer`. Registering test translation units stay in `NativeEngine/Lexer`; replacement-only support stays in `TestFramework/NativeEngine`; the old Lexer TU will be deleted during implementation. Product tokenizer code remains optional scope only if grouped RED proves a defect. The later unified-framework Change is not edited and retains ownership of generic TestCode/data/generation infrastructure.

## Old Task Disposition

No task was complete and no implementation evidence existed. The old unchecked 1.1 and 1.2 cards are superseded by current cards under the same permanent IDs: 1.1 now owns the stable run object plus all 17 contracts, and 1.2 adds an independent table anchor rather than claiming the shared-table round trip is independent. New task 1.3 owns bounded negative generation and exact recovery/state coverage. The preserved edge `1.2 <- 1.1` remains; new edge `1.3 <- 1.1` makes 1.2 and 1.3 independent siblings after the helper lands.

## Diff Snapshot

- Affected status is `?? openspec/changes/angelscript/test-lexer-isolated-coverage/`; tracked `git diff --stat` is empty because this whole active Change was already untracked.
- Task `~`: 1.1, 1.2; Task `+`: 1.3; Task `-`: none.
- DAG edge `+`: `1.3 <- 1.1`; edge `~/-`: none; `1.2 <- 1.1` is preserved.
- Artifacts `~`: `proposal.md`, `design.md`, `tasks.md`, testing/baseline delta spec, `attachments/INDEX.md`, planning validation, and the Lexer knowledge candidate.
- Artifacts `+`: the unified-boundary talk and this applied replan.

## Preserved Work

All current product/test implementation source remains byte-for-byte untouched by this update, including the 17-method Lexer TU and the reserved empty helper/AST placeholder files. Historical draft findings and creation-time talks remain intact and indexed; current artifacts explicitly mark their 16-method and same-table-oracle assumptions as superseded. No task checkbox, product spec, sibling Change, foreign TestCode plan, build output, or Automation result is changed or claimed.

## References and Result

The isolated candidate passed strict OpenSpec validation in Harness run `217b7559b9484afb962ea5b71509dbe0`. Harness task projection run `da0594c4d904462aac926968a9e17699` parsed three incomplete tasks, one Ready root (1.1), and two blocked siblings with the intended direct edges and owned paths. Attachment membership was exact (19 candidate files before this replan) and INDEX remained below 120 lines. The applied task bytes have the recorded result hash; resume at task 1.1 after live strict validation.
