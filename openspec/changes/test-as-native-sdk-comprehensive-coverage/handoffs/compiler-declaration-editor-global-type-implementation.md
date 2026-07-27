# Compiler declaration/editor/global/type implementation handoff

## Scope

This batch implements the five catalog owners assigned to the following exact
CQTest methods:

| Product | Exact owner |
| --- | --- |
| `COMPILER-BUILDER-DECLARATION-PUBLICATION` | `Compiler/AngelscriptNativeBuilderDeclarationTests.cpp\|FBuilderDeclarationTests\|StagesPublishDeclarationFamiliesWithoutEarlyLeak` |
| `COMPILER-BUILDER-EDITOR-ONLY-CLASSIFICATION` | `Compiler/AngelscriptNativeBuilderEditorOnlyTests.cpp\|FBuilderEditorOnlyTests\|EditorOnlyModesClassifyDeclarationsAndIsolateSections` |
| `COMPILER-BUILDER-CONST-GLOBAL-STATE` | `Compiler/AngelscriptNativeBuilderGlobalTests.cpp\|FBuilderGlobalTests\|ConstGlobalsPreserveDescriptorAddressAndRuntimeState` |
| `COMPILER-BUILDER-FORK-DECLARATION-REJECTION` | `Compiler/AngelscriptNativeBuilderTypeTests.cpp\|FBuilderTypeTests\|ForkDeclarationRejectionsRemainAtomicAndRecover` |
| `COMPILER-BUILDER-DECLARATION-COLLISION` | `Compiler/AngelscriptNativeBuilderTypeTests.cpp\|FBuilderTypeTests\|DeclarationCollisionsFailAtomicallyAndRecover` |

Only the six assigned Compiler test files were changed in the plugin. This
handoff is the only parent-repository record added by the batch. No catalog,
task, shared-support, or production-runtime file was changed.

## Implemented evidence

### Staged declaration publication

- Prints all 50 catalog source IDs for
  `family × scope × stage`:
  class/enum/function/import/const-global × global/namespace ×
  parse/type/function/layout/code.
- Uses one complete, Allman-formatted source containing both scopes, overloads,
  imports, const globals, classes, enums, and an executable entry point.
- Checks the parse-stage publication barrier, type-stage publication without
  functions/globals, function-stage exact scoped publication, distinct overload
  identities, import/global counts, layout completion, final bytecode, and
  runtime resolution of global plus namespaced constants.

### Editor-only classification

- Prints all eight catalog IDs for
  `declaration kind × mode × section relation`.
- Covers class and function nodes in line-block and whole-module modes.
- Covers the owning section and a second retained script section with matching
  row ranges.
- `WITH_EDITOR=0` no longer passes product evidence via a constant-true
  assertion; it reports that the editor-only contract requires an editor build.
- The single-owner helper was moved into the CQTest class.

### Const-global state

- Prints all 16 catalog IDs for
  `initializer × scope × type`.
- Covers literal/folded-expression × global/namespace ×
  int/int64/double/bool.
- For every cell, checks the builder descriptor, compiled/pure-constant flags,
  exact namespace, module index/type/const metadata, allocated address value,
  reader bytecode, and runtime return value.
- The int64 path uses the raw SDK invoker's QWord return support rather than an
  unsupported `ExecuteScriptFunction<int64>` specialization.

### Current-fork declaration rejection

- Prints the four catalog IDs for mutable-global/script-interface ×
  same-engine/fresh-module recovery.
- Script interfaces are asserted to fail at parse with located diagnostics and
  empty downstream publication tables.
- Mutable globals are asserted to fail at function/global generation with the
  current fork diagnostic and no executable `Entry` bytecode.
- Each failure is discarded and followed by both a corrected same-name module
  on the same engine and a fresh recovery module; both publish exact `Entry`
  metadata/bytecode and execute to `42`.

### Declaration collisions

- Prints the three catalog IDs for class/class, function/function, and
  global/global collisions with same-name replacement.
- Class collisions are asserted at type generation; function/global collisions
  are asserted at function/global generation.
- The tests retain owning-section diagnostics and assert that no downstream
  executable `Entry` is published.
- Each failed module is discarded, rebuilt under the same module name with a
  corrected declaration, and executed to `42`.

## Retained methods and explicit dispositions

Every pre-existing `TEST_METHOD` in the six files now has either one product
owner marker or an explicit allowed non-product disposition.

- `AggregateSupport` is used when a retained method supplies evidence to a
  stronger aggregate owner, including namespace, editor-only supplementary,
  type-stage, inheritance-layout, and property-overload probes.
- `LegacyCompatibility` is used for retained declaration/global/mutable-global
  compatibility probes whose product contract is now owned by a stronger exact
  owner.
- No unsupported `StrongerProductOwner` or `ProductSupplement` disposition
  remains.

All inline AngelScript added by this batch uses `ASTEST_AS_ANSI` and Allman
formatting. Combined review sources use `AppendGeneratedAsLine`; escaped
newline construction was removed from the assigned files.

## Static verification

The user-requested build batching rule was followed: this implementation batch
was not built and no automation test was run.

Static checks completed:

- `ReconcileNativeSdkSource.ps1 -RequireComplete`
  - products: 311
  - implemented: 310
  - disabled implemented: 1
  - incomplete products: 0
  - methods: 680
  - product-owned methods: 306
  - explicit non-product methods: 374
  - unresolved methods: 0
- `AuditInlineAsFormatting.ps1 -RequireClean`
  - raw sources: 295
  - conforming: 295
  - violations: 0
- `AuditNativeSdkBoundaries.ps1 -RequireClean`: exit code 0.
- Scoped plugin `git diff --check` for the six assigned files: clean. Git only
  reported the repository's normal LF-to-CRLF working-copy warning.

## Required integration verification

Because this batch intentionally did not build, it must not yet be described as
compiled or passing. At the coherent Compiler milestone:

1. Run the repository build entry point once.
2. Batch-fix all compiler errors before rebuilding.
3. Run the five narrow owner prefixes/methods.
4. Run the full Compiler prefix.
5. Run the full `Angelscript.TestModule.AngelScriptSDK` prefix.
6. Re-run source reconciliation, inline formatting, boundary audit, and scoped
   diff-check against the final source state.

Any observed fork diagnostic-text difference or stage-publication difference
must be recorded before weakening an assertion. The catalog expects exact
current-fork rejection and atomic recovery, not an either/or outcome.
