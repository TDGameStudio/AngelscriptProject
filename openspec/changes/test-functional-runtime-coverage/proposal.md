## Why

The `Functional` test surface already carries useful runtime coverage, but a few files still stop at compile-and-symbol registration placeholders when the branch can already execute the underlying behavior. That makes the suite harder to trust as a runtime contract and hides which cases are real branch limitations versus simply incomplete tests.

## What Changes

- Replace compile-only placeholder assertions in the functional runtime themes with executable runtime checks where the branch already supports the behavior.
- Keep explicit negative contracts for runtime paths that are still genuinely unsupported on this branch, instead of silently implying success.
- Preserve the existing theme-owned `Angelscript.TestModule.Functional.<Theme>.*` discovery layout and file ownership boundaries.
- Sync the test catalog and test guide so the functional runtime surface and any explicit unsupported boundaries remain visible.

## Capabilities

### New Capabilities
- `functional-runtime-behavior-coverage`: Restores explicit runtime assertions for the functional themes that currently mix execution coverage with placeholder compile-only checks.

### Modified Capabilities
- None.

## Impact

- Targeted functional test files under `Plugins/Angelscript/Source/AngelscriptTest/Functional/`, especially `Objects/AngelscriptObjectModelTests.cpp`, `Operators/AngelscriptOperatorTests.cpp`, `Handles/AngelscriptHandleTests.cpp`, and `Inheritance/AngelscriptInheritanceTests.cpp`.
- Shared runtime-test helpers under `Plugins/Angelscript/Source/AngelscriptTest/Shared/` if a case needs a more direct runtime harness.
- `Documents/Guides/TestCatalog.md` and `Documents/Guides/Test.md` for the functional runtime coverage map and verification entry points.
