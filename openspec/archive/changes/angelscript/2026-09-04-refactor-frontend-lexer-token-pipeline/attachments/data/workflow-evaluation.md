---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/refactor-frontend-lexer-token-pipeline
closure_kind: completed
input_sha256: 0c5e3f7d8dcbd9b5a226a77d11b0dbdeed64e94a9b6f6912063452212513a69c
captured_at: 2026-09-05T03:22:20.4134484+08:00
---

# Workflow Evaluation

## Lifecycle

- Consumed the completed NativeEngine CQTest foundation and source-diagnostics capability as the third dependency in the nine-Change frontend sequence.
- Used focused RED/GREEN cycles for frozen options and source-referential tokens, session identifier interning and pull scanning, then Unicode/recovery/trivia/concurrency behavior.
- Kept the new final-name `frontend::asCTokenizer` isolated from the preserved production tokenizer, Parser, Builder, Engine, preprocessor, VM, reflection, and Standalone paths.
- Created `angelscript/language/frontend/lexing` through the portable CLI, synchronized all five durable requirements without delta headings, and promoted the Clang lexer hot-path knowledge into the capability.
- Completed all five tasks with one applied unique-basename Replan, one evidence-backed rejected Harness observation, and no requested Review.

## Verification

- Task `1.1` RED builds `6f6caf04f5db42abbbfe26f6ca462f2` and `954671d4208b457a8b4bfa440ff1c92e` proved the absent contract and rejected implicit engine-pointer-to-bool construction; GREEN build `d070a67f8c0c434ca922ee70c72d773a` passed.
- Task `1.2` expected RED `2cece68cb7bb411d9be21821bff4a520`; GREEN build/test `1d3889103b514a2ebb4f3733756245b5` / `0c649506fa7e40ffbb1b099a37037b68` passed 6/6.
- Task `2.1` expected RED `0d7107769ee74a9f915d19889a7828a9`; final repaired build/test `e7c60165d4ea48439cb3f41a26e67aea` / `4e29fd17bd0a44c693f50d52268a7f21` passed 11/11 with zero warnings and errors.
- Measurement build/test `d5d303db4568426395d702726bab78d1` / `bc2097f7758d456eb34c5835016b5d9f` passed 12/12 and recorded 34,304 bytes, 9,728 tokens, 12 cold unique-identifier allocations, and zero additional warm allocations.
- Final incremental editor build `b4b2d64ee293432385456788b45a6e6b` succeeded; final exact Lexer Fast test `fb0813c4e6d2487d8f86aa2ceaaa26f0` passed 12/12 with zero failures, skips, warnings, or errors.
- OpenSpec doctor, exact strict active-Change validation, strict all-current-spec validation, Task DAG 5/5 completion, and Harness evolution structural checks passed.

## Material friction and corrective action

- Prior real UBT evidence established that same-module C++ sources require unique basenames. The indexed Replan therefore used `as_frontend_tokenizer.cpp` while preserving the final public-internal header and `frontend::asCTokenizer` identity.
- A Boolean Unicode option admitted engine pointers through standard conversion. Replacing it with the strong `asEUnicodeIdentifierPolicy` enum made the no-Engine boundary statically enforceable.
- CQTest cannot stringify custom source-range wrappers for `AreEqual`; the test-only comparison was reduced to supported scalar file and byte-offset fields after exact failure logs identified the assertion boundary.
- One synchronous `ue.test` caller returned no envelope before its managed worker finished. Complete run artifacts survived and the behavior did not recur twice, so the indexed issue rejects a speculative Harness repair while preserving exact evidence.

## Durable contract and knowledge disposition

The full delta is present in `openspec/specs/angelscript/language/frontend/lexing/spec.md`. Capability knowledge retains the evidence-backed Clang ownership, token layout, interning, slow-path, and measurement guidance. Change-local knowledge and the measurement baseline remain immutable provenance after archive.

## Scope boundary and provenance

Harness aggregate profiles, full UE suites, Standalone, legacy tokenizer/parser tests, upper Runtime tests, and Unreal product builds were intentionally omitted. No production route consumes the new lexer yet; the exact editor build and complete Lexer prefix directly prove compilation, pull semantics, source ranges, keyword/reflection spelling, session interning, Unicode policy, malformed-input progress, trivia modes, concurrent determinism, and the non-timing allocation gate. Raw UE artifacts remain under ignored `Saved/Harness/Unreal/Runs/<RunId>/`; `data/lexer-baseline.md` and `data/lexer-verification.md` retain compact durable evidence and provenance.
