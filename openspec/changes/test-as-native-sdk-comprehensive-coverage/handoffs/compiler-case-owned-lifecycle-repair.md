# Compiler Case-Owned Lifecycle Repair

## Scope

This batch applies the exact Compiler subset from
`fixture-and-large-file-quality-review.csv` whose lifecycle disposition is
`ChangeRequiredClassOwnedMutableOrUnjustified`.

It changes fixture ownership only. Product IDs, product markers, generated case
IDs, AngelScript inputs, assertions, test method names, and file/domain
responsibilities are unchanged. No large file is split in this batch.

## Files and method counts

| File | `TEST_METHOD` count |
|---|---:|
| `Compiler/AngelscriptNativeBuilderApplicationTests.cpp` | 9 |
| `Compiler/AngelscriptNativeBuilderBytecodeTests.cpp` | 9 |
| `Compiler/AngelscriptNativeBuilderDeclarationTests.cpp` | 2 |
| `Compiler/AngelscriptNativeBuilderDependencyTests.cpp` | 7 |
| `Compiler/AngelscriptNativeBuilderDiagnosticTests.cpp` | 10 |
| `Compiler/AngelscriptNativeBuilderEditorOnlyTests.cpp` | 3 |
| `Compiler/AngelscriptNativeBuilderFunctionTests.cpp` | 4 |
| `Compiler/AngelscriptNativeBuilderGlobalTests.cpp` | 3 |
| `Compiler/AngelscriptNativeBuilderLayoutTests.cpp` | 4 |
| `Compiler/AngelscriptNativeBuilderLifecycleTests.cpp` | 4 |
| `Compiler/AngelscriptNativeBuilderNamespaceTests.cpp` | 1 |
| `Compiler/AngelscriptNativeBuilderParsingTests.cpp` | 1 |
| `Compiler/AngelscriptNativeBuilderPropertyTests.cpp` | 1 |
| `Compiler/AngelscriptNativeBuilderTypeTests.cpp` | 4 |
| `Compiler/AngelscriptNativeCompilerCartesianDepthTests.cpp` | 5 |
| `Compiler/AngelscriptNativeOutputBufferTests.cpp` | 2 |
| **Total** | **69** |

## Lifecycle shape

Every one of the 69 methods now starts with a method-local raw SDK engine:

```cpp
AngelscriptNativeTestSupport::FNativeTestEngine Engine;
Engine.Create(*TestRunner);
ON_SCOPE_EXIT
{
	Engine.Destroy();
};
```

The cleanup guard is registered immediately after successful construction.
Modules, builders, contexts hidden behind the native execution helper, scoped
module names, and other dependent objects are declared after this guard.
Reverse destruction therefore releases method-owned dependencies before the
engine guard runs.

All 18 class-level lifecycle hook blocks were removed:

- 16 `inline static FNativeTestEngine` members;
- 16 `BEFORE_ALL` engine creates;
- 16 `AFTER_ALL` engine destroys;
- 16 `BEFORE_EACH` message resets.

`AngelscriptNativeCompilerCartesianDepthTests.cpp` contains three CQTest
classes, so its former shared-fixture shape accounted for three of those hook
blocks. The other 15 files each contained one block.

Eight narrow diagnostic helpers formerly read a class-owned `Engine`. They now
take `const FNativeTestEngine& Engine` explicitly, and all call sites pass the
method-owned engine:

- BuilderDependency;
- BuilderFunction;
- BuilderLayout;
- BuilderLifecycle;
- BuilderNamespace;
- BuilderParsing;
- BuilderProperty;
- BuilderType.

No method-independent immutable helper was moved or deleted.

## Create and destroy accounting

Static file-level accounting reports:

- 69 `TEST_METHOD` declarations;
- 69 immediate method-entry `Engine.Create(*TestRunner)` calls;
- 69 matching method-entry multiline `ON_SCOPE_EXIT` destroy calls;
- one additional intentional destroy/create pair inside
  `InvalidBuildsRecoverAcrossShapeAndEngineRoute`, preserving its existing
  `fresh_engine` recovery axis;
- **70 total create calls and 70 total destroy calls**;
- zero class-static `FNativeTestEngine` declarations;
- zero `BEFORE_ALL`, `AFTER_ALL`, or `BEFORE_EACH` hooks in the 16 files;
- zero direct `CreateContext` calls in these files, so no independent context
  release migration was required;
- zero one-line `ON_SCOPE_EXIT { ... }` cleanup blocks in the scoped files.

The fresh-engine recovery case remains covered by the method-entry scope guard:
the explicit mid-method destroy occurs before recreation, and the original
guard destroys the final recreated engine at method exit.

## File-level verification

Because other agents are editing the shared OpenSpec/catalog state, this batch
does not run catalog expansion, source reconciliation, boundary, inline-AS, or
other global scripts that rewrite audit CSVs.

The permitted read-only/file-level checks verify:

- every scoped `TEST_METHOD` begins with the exact local create plus multiline
  destroy guard;
- method/create/destroy accounting shown above;
- no scoped file retains static mutable engine state or CQTest lifecycle hooks;
- no zero-argument diagnostic helper call remains after explicit engine
  parameterization;
- no new one-line cleanup block was introduced;
- scoped `git diff --check` passes;
- no trailing whitespace is present in the 16 modified source files or this
  handoff.

Per instruction, no build or automation test was run. This record claims
fixture-shape and static file-level completion only, not compile or runtime
success.
