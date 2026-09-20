---
replan_id: replan-20260912-133353-unity-safe-class-aliases
status: applied
source: user
source_ref: "2026-09-12 request: 先这样, 你replan 下, 然后我们准备实现了; follows acceptance of using X = LexerTest::X to avoid Unity-build scope leakage"
scope: "CQTest helper-name visibility and exact per-class alias sets; no behavior, Task DAG, C++ implementation, build, or Automation change"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: d9df5dacf90ce01e5e8f6ec5bda1b71e8073423a6dc4b0a4f8e5894da03bb6ba
result_tasks_sha256: 212648117c34f983b8d36836323597600aaf3dc0abef6b52f51a2e6014f3ca65
created_at: 2026-09-12T13:33:53+08:00
resume_task: "1.1"
---

## Trigger and Evidence

The user identified that the accepted file-scope helper namespace import can leak short names across an Unreal Unity translation unit, then selected class-scope aliases in the explicit form `using X = LexerTest::X`. This invalidates the current helper visibility design and the structure acceptance case in each of tasks 1.1, 1.2, and 1.3, but it does not change tokenizer behavior or public Automation identity.

UE 5.8 CQTest inspection proves `TEST_CLASS_WITH_FLAGS` expands to a global `struct`; the following braces are a class body. A compiled Clang probe rejects both a namespace using-directive in that class and a using-declaration that refers through namespace `LexerTest`, while accepting an alias declaration such as `using FExpectedToken = LexerTest::FExpectedToken;`. `TEST_METHOD` registers a member through `FFunctionRegistrar`, so a private alias block must restore `public:` before method registrations.

Because class-scope aliases are visible only in their owning class, this arrangement does not pollute later fragments combined by Unity. CQTest macros remain global and require no helper import.

## Decision

Keep `LexerTest` as the helper namespace and keep `TEST_CLASS_WITH_FLAGS` at global scope. Declare only these private aliases, then restore `public:` before every `TEST_METHOD`:

| Scenario class | Exact aliases |
|---|---|
| `Contracts` | `FNativeEngineTokenizerTest`, `FExpectedToken`, `FLexExpectation` |
| `SpelledKinds` | `FNativeEngineTokenizerTest` |
| `Recovery` | `FNativeEngineTokenizerTest`, `FExpectedToken`, `FExpectedLexDiagnostic`, `FLexExpectation`, `FMalformedUtf8Case` |

Each declaration is `using X = LexerTest::X;`. Do not add a namespace-wide using-directive or any file-scope helper alias. If implementation proves a listed alias is unused, remove it; if a scenario must spell another existing helper type, add only that class-local alias and record the concrete use in the owning task evidence.

## Impact

The three-node Task DAG, task IDs, dependencies, method inventories, helper interface, standard-library ownership, all test behavior, BOM product repair boundary, delta specs, file map, and focused verification commands remain unchanged. Only the helper visibility portions of proposal, design, task architecture/global constraints/interfaces/Cases, planning validation, knowledge candidate, and attachment navigation change. A new decision talk records the language and Unity evidence.

The structure Case in every task is renamed `CqtestHelperAliasesStayClassScoped` and now proves the exact class-specific alias set, global CQTest class location, `public:` restoration, and absence of translation-unit-wide helper visibility.

## Old Task Disposition

No task is complete and no C++ implementation evidence exists. Tasks 1.1, 1.2, and 1.3 remain unchecked under their permanent IDs. Each retains its bounded outcome and verification; only its CQTest structure acceptance and illustrative class shape are revised. Direct edges remain `1.2 <- 1.1` and `1.3 <- 1.1`; there is no new, removed, or changed edge.

The standard-library ownership portion of `talk-20260912-130915-std-helper-and-cqtest-using.md` remains valid. Its file-scope import decision is historical and superseded by `talk-20260912-133353-unity-safe-class-aliases.md`; neither historical talk nor the earlier applied replan is edited.

## Diff Snapshot

- Affected canonical status before application is `?? openspec/changes/angelscript/test-lexer-isolated-coverage/`; tracked `git diff --stat` is empty because the Change remains wholly untracked.
- Parent HEAD is `afeff74519a0d81e40702f140503cffe911789c6`; plugin HEAD is `ad4d4830bb1b43a3439939bf4fc78aa16ae28d9d`.
- Tasks `~`: 1.1, 1.2, 1.3; Task `+/-`: none.
- DAG edges `+/-/~`: none; both existing direct edges are preserved.
- Artifacts `~`: `proposal.md`, `design.md`, `tasks.md`, `attachments/INDEX.md`, `attachments/data/planning-validation.md`, and `attachments/knowledges/isolated-lexer-checklex-matrix.md`.
- Artifacts `+`: `attachments/talks/talk-20260912-133353-unity-safe-class-aliases.md` and this applied replan.
- Durable delta specs, `change.yaml`, Clang coverage data, historical attachments, and implementation source are unchanged.

## Preserved Work

All accepted tokenizer contracts remain intact: 18 Contracts methods, four SpelledKinds methods, nine Recovery methods, 115/107 vocabulary counts and fixed digest, six maximal-munch rows, keyword casing matrix, 16-row malformed generator and digest, authored source slices, separate repeated EOF, exact recovery/state rows, Retain/Raw parity, and grouped BOM RED/repair.

The original 17-method Lexer TU, reserved helper/AST placeholder files, and live tokenizer implementation remain byte-for-byte untouched by this planning update. Unrelated parent and plugin worktree changes are preserved. No build, Unreal worker, Automation run, checkbox, sibling Change, or public name is changed or claimed.

## References and Result

- Current decision: `attachments/talks/talk-20260912-133353-unity-safe-class-aliases.md`.
- Superseded import decision: `attachments/talks/talk-20260912-130915-std-helper-and-cqtest-using.md`.
- CQTest evidence: UE 5.8 `Engine/Source/Developer/CQTest/Public/CQTest.h:264-282,287-291,310`.
- The first isolated candidate strict validation succeeded in Harness run `8d3bf1869858416abac849bce7275100`.
- Candidate task projection succeeded in Harness run `37f211927cea4c5587cb5d92a3455f41`: three incomplete tasks, Ready root 1.1, blocked siblings 1.2/1.3, unchanged direct edges, and unchanged file roles.

The candidate task bytes have the recorded result hash. Apply the same bytes to the canonical Change, validate strictly, confirm task projection, and resume at task 1.1.

