## Why

`AngelscriptTest/Bindings` contains many broad compatibility tests that grew before the current CQTest and inline AngelScript formatting rules were written. The project now also has `AngelscriptTest/Coverage`, backed by OpenSpec `test-coverage`, as the authoritative large matrix coverage layer. This change applies the current unit-test and inline AngelScript formatting rules across the full Bindings test directory, and records a narrower responsibility for Bindings: binding-surface contract and smoke tests for AS-visible manual/default binds rather than exhaustive behavior coverage.

## What Changes

- Refactor Bindings tests so the main test flow lives in `TEST_CLASS_WITH_FLAGS` / `TEST_METHOD` bodies instead of file-level `RunXxxSection()` wrappers where practical.
- Split large compatibility methods into scenario-specific methods with module names that match the covered scenario.
- Convert inline AngelScript fixtures under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` to `ASTEST_AS(...)` / `ASTEST_AS_ANSI(...)` where they are test source and enforce the `ASInlineFormattingRule.md` brace, blank-line, and indentation rules.
- Ensure helpers returning `bool`, including `ExpectGlobalInt(s)` and execution helpers, are consumed by matcher assertions instead of ignored.
- Record the responsibility boundary between `Bindings/` and `Coverage/`: Bindings proves exposed entrypoints exist and call the intended native path; Coverage owns broad semantic matrices and coverage-gap tracking.
- Keep this as a test-only refactor: no runtime binding behavior, public plugin APIs, or generated binding contracts should change.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `as-bindings-test-execute-and-naming`: Tightens the expected layout, naming, assertion consumption, inline AS formatting, and Bindings-vs-Coverage responsibility boundary for refactored Bindings tests.

## Impact

- Source: all C++ test files under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` (`89` `.cpp` and `6` `.h` files) are in audit scope; implementation edits touch `88` `.cpp` files plus the shared Bindings section header. `AngelscriptContainerBindingsTests.cpp` remains an empty deprecated migration placeholder.
- Coverage boundary: `Plugins/Angelscript/Source/AngelscriptTest/Coverage` and OpenSpec `test-coverage` remain the home for broad behavior matrices, while this change keeps Bindings focused on binding-surface contracts.
- Documentation contract: `Documents/UnitTest/UnitTest.md` and `Documents/Rules/ASInlineFormattingRule.md` define the rules this change applies.
- Validation: full plugin build plus `Angelscript.TestModule.Bindings.` automation prefix.
- Behavior: test code structure and readability only; Angelscript runtime/editor behavior must remain unchanged.
