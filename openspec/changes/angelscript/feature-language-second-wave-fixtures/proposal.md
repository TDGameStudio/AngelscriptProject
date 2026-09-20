## Why

Admitted Language already has 475 `@begin` cases, but Auto, Class, Inheritance, Destructors, Typedef, and Mixin still sit in Pending as old `root` stars. File-count comparison with Pending/Language is misleading; the real gap is those host-free theme roots.

## What Changes

- Rewrite the six themes into `AngelscriptTestCode/Language/{Theme,ThemeCompileFail}.as` using the current pocket contract.
- Merge overlapping class/super negatives out of `Language/Syntax/ClassDeclarationCompileFail`.
- Project the new FileTags and extend the language-fixtures inventory and Skill examples.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/language-fixtures`: inventory adds the six second-wave FileTags and their CompileFail siblings.

## Impact

Parent repository: `AngelscriptTestCode/Language/**`, Language Migration census, CodeGenTool tests, angelscript-test Skill examples, OpenSpec language-fixtures.
Plugin submodule: `TestCode/Generated/Language/**`, `LanguageFixtureCorpusTests`.

## Non-goals

First-wave thickening. Properties, top-level Const, Syntax/Function. UClass, World, Bindings leftovers. Parser/Builder grammar changes. 122 generators. Compile or execute AngelScript.
