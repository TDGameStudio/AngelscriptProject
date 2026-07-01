## Why

`chore-angelscript-compile-settings` introduces `bCompileAngelscriptUnitTests` and the `WITH_ANGELSCRIPT_UNITTESTS` compile definition, but the existing `AngelscriptTest` tree still contains hundreds of C++ test registration translation units. To make the setting effective and auditable, the test sources need a mechanical refactor that consistently wraps unit-test registration code with the new macro.

The affected surface is large: the current scan found 549 `.cpp` files under `Plugins/Angelscript/Source/AngelscriptTest`, with 527 files containing CQTest or Unreal automation registration macros. The remaining files are module, helper, AOT fixture, generated, or test support code and must not be blindly wrapped as if they were registration units.

## What Changes

- Add a follow-up refactor that applies `#if WITH_ANGELSCRIPT_UNITTESTS` / `#endif` to Angelscript C++ unit-test registration source files.
- Treat files containing `TEST_CLASS_WITH_FLAGS`, `TEST_METHOD`, `IMPLEMENT_*_AUTOMATION_TEST`, or `DEFINE_SPEC` as primary wrapping candidates.
- Classify non-registration `.cpp` files separately so support code, test-only UObject types, generated AOT files, commandlets, and module startup code remain build-correct.
- Keep the macro defined by `chore-angelscript-compile-settings`; this change only consumes that macro.
- Use a repeatable scan/check script or command sequence to prove that all intended test registration files are gated and no old macro names are used.
- Update `Documents/UnitTest/UnitTest.md` so future Angelscript C++ unit tests follow the same `WITH_ANGELSCRIPT_UNITTESTS` gate convention.

## Capabilities

### New Capabilities

- `angelscript-unit-test-gates`: Angelscript C++ unit test registration sources are consistently controlled by `WITH_ANGELSCRIPT_UNITTESTS`.

### Modified Capabilities

- None.

## Impact

- Affects most `.cpp` files under `Plugins/Angelscript/Source/AngelscriptTest` that contain test registration macros.
- May affect test support `.cpp` files only when they instantiate test-only static registration objects or otherwise depend on unit-test-only code paths.
- Does not change runtime/editor production modules outside the test module.
- Depends on `chore-angelscript-compile-settings` for the macro definition.
- Requires build verification with `bCompileAngelscriptUnitTests=false` and test discovery verification with `bCompileAngelscriptUnitTests=true`.
- Requires documentation updates in `Documents/UnitTest/UnitTest.md`.
