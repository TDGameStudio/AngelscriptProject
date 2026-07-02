## 1. Full-Scope Audit

- [x] 1.1 <!-- Non-TDD --> Expand scope from the old modified-file set to every C++ test file under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` (`89` `.cpp`, `6` `.h`).
- [x] 1.2 <!-- Non-TDD --> Run a repeatable raw-string and source-variable audit over the full Bindings directory.
- [x] 1.3 <!-- Non-TDD --> Run a repeatable inline AS style audit over the full Bindings directory.
- [x] 1.4 <!-- Non-TDD --> Run a repeatable helper-result audit over the full Bindings directory.
- [x] 1.5 <!-- Non-TDD --> Run a repeatable C++ `TEST_CLASS_WITH_FLAGS` column-zero audit over the full Bindings directory.
- [x] 1.6 <!-- Non-TDD --> Run repeatable AS control-flow brace and C++ `TEST_METHOD` column-zero audits over the full Bindings directory.

## 2. Source Refactor

- [x] 2.1 <!-- Non-TDD --> Normalize Bindings inline AS fixtures to `ASTEST_AS(...)` / `ASTEST_AS_ANSI(...)` where they are test source.
- [x] 2.2 <!-- Non-TDD --> Reformat embedded AS snippets to avoid column-zero content, column-zero closers, K&R braces, missing function/class blank lines, and missing `UPROPERTY()` spacing.
- [x] 2.3 <!-- Non-TDD --> Rename generic inline AS source locals where multiple snippets or generated templates need scenario-specific names.
- [x] 2.4 <!-- Non-TDD --> Convert dynamic AS builders away from `FString::Printf(ASTEST_AS(...))` to normalized templates plus token replacement.
- [x] 2.5 <!-- Non-TDD --> Wrap ignored `ExpectGlobal*`, `Execute*`, parity, and math verification helper returns in matcher-backed assertions.
- [x] 2.6 <!-- Non-TDD --> Keep Bindings changes test-only with no runtime/editor binding behavior changes.

## 3. Records

- [x] 3.1 <!-- Non-TDD --> Update `proposal.md` and the spec delta to describe the full Bindings directory audit scope.
- [x] 3.2 <!-- Non-TDD --> Rewrite `file-audit.md` from the stale 39-file issue table into the current 95-file full-scope audit result.
- [x] 3.3 <!-- Non-TDD --> Keep `review-notes.md` as the historical second-review root cause and mark it superseded by the full-scope audit.
- [x] 3.4 <!-- Non-TDD --> Record final build and Bindings automation results in `verification.md`.
- [x] 3.5 <!-- Non-TDD --> Record the Bindings-vs-Coverage responsibility boundary and update the spec so Bindings remains a binding-surface contract layer.

## 4. Final Verification

- [x] 4.1 <!-- Non-TDD --> Run all four full-directory audits and confirm `issue_files=0`.
- [x] 4.2 <!-- Non-TDD --> Run `git -C Plugins\Angelscript diff --check -- Source\AngelscriptTest\Bindings`.
- [x] 4.3 <!-- Non-TDD --> Run `openspec validate "refactor-bindings-test-layout" --strict --json`.
- [x] 4.4 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label bindings-layout-review-build-final-2 -TimeoutMs 1800000 -NoXGE`.
- [x] 4.5 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-layout-review-final-3 -TimeoutMs 900000`.
