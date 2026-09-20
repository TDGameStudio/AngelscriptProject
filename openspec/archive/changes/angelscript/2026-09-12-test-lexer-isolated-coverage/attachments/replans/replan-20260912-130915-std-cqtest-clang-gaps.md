---
replan_id: replan-20260912-130915-std-cqtest-clang-gaps
status: applied
source: user
source_ref: "2026-09-12 requests to use one CQTest namespace import, make FNativeEngineTokenizerTest standard-library-owned, inspect Clang lexer tests, fill applicable gaps, and show the resulting design"
scope: "Tokenizer helper ownership/import boundary, sticky EOF, Clang-derived coverage, BOM product behavior, and live tokenizer path; no C++ implementation"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: c6648f712b18c74340ede13a4b94ac8fb78e6826c49704bf231ca30f5347d689
result_tasks_sha256: d9df5dacf90ce01e5e8f6ec5bda1b71e8073423a6dc4b0a4f8e5894da03bb6ba
created_at: 2026-09-12T13:09:15+08:00
resume_task: "1.1"
---

## Trigger and Evidence

The user replaced two accepted helper conventions: use the C++ standard library inside `FNativeEngineTokenizerTest`, and import its helper namespace once around each file-scope CQTest class rather than repeating class-scope using declarations. Macro inspection establishes that CQTest registration/assertion names are global macros and require no namespace import; C++ permits `using namespace LexerTest;` at file scope but not inside a class. The earlier user-confirmed `{Unit}Test` convention supplies `LexerTest`.

Fixed LLVM/Clang 22.1.8 inspection also invalidated the Change's historical coverage summary. `clang/unittests/Lex` has 11 C++ files, not 12, and 143 tests: 29 in mixed `LexerTest.cpp`, four in the HLSL Root Signature pull lexer, and 110 mostly in PP/dependency/header/module boundaries. Exact source recovery, buffer-edge EOF, raw/normal projection parity, and explicit case policy apply to `asCTokenizer`; macro provenance, split/peek/navigation, preamble, headers/modules, and C line-splicing do not.

Two plan defects surfaced. The helper stopped at first EOF and could not retain `MalformedBytesAlwaysAdvanceAndDiagnoseOnce` assertions that pull EOF a second time. The task's optional product path `frontend/as_frontend_tokenizer.cpp` no longer exists after the phase-directory refactor; the live path is `frontend/Lexer/as_tokenizer.cpp`.

Finally, AngelScript 2.38 `asCTokenizer::IsWhiteSpace` directly identifies `EF BB BF` as three-byte whitespace, while the live reconstructed tokenizer emits `UnicodeIdentifierDisallowed [0,3)` under default options. This is an evidence-backed tokenizer defect rather than a Clang-derived product guess. The current lexing delta now states the durable BOM behavior and task 1.3 owns grouped RED/GREEN.

## Decision

Use `LexerTest::FNativeEngineTokenizerTest`. Own bytes, case names, expectations, token/diagnostic collections, rendered descriptions, and stable run indirection with `std::string`, `std::vector`, and `std::unique_ptr`; expose `std::string_view` and `std::span`. Keep `FromText(FStringView)` as the authored UE-text boundary, change exact bytes to `FromUtf8Bytes(std::string_view)`, adapt temporarily to snapshot `TConstArrayView<uint8>`, and convert UTF-8 failure text to `FString` only at the CQTest asserter.

Each scenario TU contains one `using namespace LexerTest;` immediately before global `TEST_CLASS_WITH_FLAGS`. `RunOnce` keeps one EOF in the primary stream and performs one separate stable repeated-EOF probe exposed by `GetRepeatedEndOfFile`; the total bound becomes at most byte count plus two successful pulls.

Retain the three-node DAG. Task 1.1 adds exact authored source slices and an eighteenth Contracts method for empty/pure-trivia EOF. Task 1.2 adds a fourth SpelledKinds method for case-sensitive keyword negatives. Task 1.3 adds valid nonidentifier Unicode, comment/string buffer edges, CRLF, full Retain/Raw lexical parity, and leading-BOM RED/repair at the live tokenizer path. Final focused inventory is 18 Contracts, four SpelledKinds, and nine Recovery methods.

## Impact

The Change remains a Lexer-only pilot but now modifies `angelscript/language/frontend/lexing` as well as testing because BOM changes observable token/diagnostic behavior. Only task 1.3 may edit product code, and only after its exact grouped RED. TestCode, common source/generator infrastructure, preprocessor/parser behavior, other `NewVersion` tests, and sibling helper placeholders remain outside scope.

Current truth explicitly defers unconfirmed string/newline recovery, CR-only start-of-line behavior, non-BMP identifier categories, and malformed bytes inside comments/strings. No C/C++ behavior is inferred from Clang for those decisions.

## Old Task Disposition

No task was complete and no implementation evidence existed. Tasks 1.1, 1.2, and 1.3 remain unchecked and are revised under their permanent IDs. Their outcome boundaries, interfaces, cases, and acceptance expand as described above. Direct edges remain `1.2 <- 1.1` and `1.3 <- 1.1`; no new task or edge is needed because the additions belong to the same independently provable helper, vocabulary, and recovery products.

## Diff Snapshot

- Affected status before application is `?? openspec/changes/angelscript/test-lexer-isolated-coverage/`; tracked `git diff --stat` for that path is empty because the whole Change remains untracked.
- Parent HEAD is `afeff74519a0d81e40702f140503cffe911789c6`; plugin HEAD is `ad4d4830bb1b43a3439939bf4fc78aa16ae28d9d`. Both match the start of this replan and the base task hash remained exact.
- Tasks `~`: 1.1, 1.2, 1.3; Task `+/-`: none.
- DAG edges `+/-/~`: none; both existing direct edges are preserved.
- Artifacts `~`: `change.yaml`, `proposal.md`, `design.md`, `tasks.md`, testing/baseline delta, `attachments/INDEX.md`, planning validation, and Lexer knowledge candidate.
- Artifacts `+`: lexing delta, current Clang coverage map, standard-library/CQTest talk, and this applied replan.

## Preserved Work

All product and test implementation source remains byte-for-byte untouched by this planning update, including the 17-method Lexer TU and reserved helper/AST placeholder files. The 115/107 vocabulary counts and digests, 16-row malformed generator recipe/digest, three scenario identities, helper filename, public TestDir, task IDs, and Task DAG remain accepted. Historical draft findings, talks, and the earlier applied replan remain immutable; current artifacts and INDEX mark their superseded claims precisely.

No task checkbox, sibling Change, build output, Unreal process, or Automation result is changed or claimed. Unrelated parent and plugin worktree changes are preserved.

## References and Result

- Current research: `attachments/data/clang-lexer-coverage-map.md`.
- Current helper/import decision: `attachments/talks/talk-20260912-130915-std-helper-and-cqtest-using.md`.
- Product evidence: `Reference/angelscript-v2.38.0/sdk/angelscript/source/as_tokenizer.cpp:183-194` and live `frontend/Lexer/as_tokenizer.cpp`.
- Isolated candidate strict validation succeeded in Harness run `2bf9251ecb524045bb9694dfd7beed7a`.
- Candidate task projection succeeded in Harness run `1b1b2da6143f41d88ea5d54b7fec7fc0`: three incomplete tasks, Ready root 1.1, blocked siblings 1.2/1.3, intended direct edges, and live product path ownership.

The applied task bytes have the recorded result hash. Resume at task 1.1 after strict validation of the canonical Change.

