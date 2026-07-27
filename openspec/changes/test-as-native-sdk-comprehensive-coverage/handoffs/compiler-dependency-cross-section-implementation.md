# Compiler dependency / cross-section owner implementation

## Outcome

Implemented the two catalog-declared Compiler owners in:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeBuilderDependencyTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeBuilderBytecodeTests.cpp`

No production code, catalog, OpenSpec planning artifact, shared support file, or other plugin file was edited.

## Product owners

### `COMPILER-BUILDER-MODULE-DEPENDENCY`

Owner:

`FBuilderDependencyTests.ModuleDependenciesPreserveTargetsFlagsAndFailureIsolation`

Implemented four catalog scenarios:

1. `direct_module`
   - exact dependency module key;
   - zero node-derived line/column;
   - structural and hard flags both false;
   - repeated marking deduplicates to one table row;
   - dependent builder completes layout/code generation and publishes Entry bytecode;
   - provider and dependent modules are absent after the scenario.
2. `structural_type`
   - exact provider type and provider module identity;
   - structural flag true and hard flag false;
   - zero line/column;
   - repeated structural marking deduplicates;
   - type generation is completed before the direct internal call;
   - provider and dependent modules are absent after the scenario.
3. `hard_function`
   - fixture deliberately uses an ordinary `ConstructedValue()` function; it does not claim a default constructor;
   - exact function and provider module identity;
   - hard flag true and structural flag false;
   - zero line/column;
   - repeated function marking deduplicates;
   - dependent builder completes layout/code generation and publishes Entry bytecode;
   - provider and dependent modules are absent after the scenario.
4. `global_initializer_rejection`
   - exact unavailable `InitializerValue()` function target;
   - hard flag true and structural flag false;
   - zero line/column and repeat deduplication before build;
   - exact dependent section plus unavailable symbol diagnostic;
   - build failure;
   - all published functions are checked for absent executable bytecode;
   - provider and rejected dependent modules are absent after the scenario.

### `COMPILER-BUILDER-CROSS-SECTION-PUBLICATION`

Owner:

`FBuilderDependencyTests.CrossSectionPublicationPreservesOwnersAndExecution`

Implemented two catalog shapes:

1. `provider_consumer`
   - consumer section is inserted before provider to exercise forward section resolution;
   - exact provider and Entry declarations;
   - exact `GetScriptSectionName()` ownership for both functions;
   - provider and consumer bytecode;
   - cross-section execution returns 42;
   - module is discarded before the second shape.
2. `type_helper_entry`
   - entry, helper, and type sections are inserted in reverse dependency order;
   - exact class property count and method publication;
   - exact method/helper/Entry section ownership;
   - bytecode for method, helper, and Entry;
   - cross-section execution returns 42;
   - module is absent after the shape.

## Source review logging

- Added one class-private `PrintGeneratedAsSource` forwarding point.
- The owners print 13 source records with stable IDs:
  - eight module-dependency sources;
  - two provider/consumer sources;
  - three type/helper/entry sources.
- Each source is printed before it is compiled or added to its builder module.
- Inline AngelScript uses `ASTEST_AS_ANSI` and Allman formatting.

## Legacy method dispositions

No test was deleted.

- Five pre-existing dependency/cross-section methods now carry `AS_NATIVE_NON_PRODUCT` and point to one of the two new owners.
- Eight pre-existing builder-bytecode methods now carry `AS_NATIVE_NON_PRODUCT`:
  - the old provider/consumer method points to `COMPILER-BUILDER-CROSS-SECTION-PUBLICATION`;
  - the remaining focused bytecode compatibility methods point to existing `COMPILER-BYTECODE-SHAPE`.
- The historically misleading `DefaultConstructorCallMarksHardValueDependency` method is retained for Automation compatibility, but its disposition explicitly records that its body exercises an ordinary function dependency.

## Unit-test style cleanup

Within the touched dependency methods:

- replaced single-line `if (...) return;` forms with braced blocks;
- replaced one-line AngelScript fixtures with readable `ASTEST_AS_ANSI` Allman fixtures;
- preserved CQTest class-owned engine lifecycle;
- kept the owner flows inside their `TEST_METHOD`s;
- guarded later builder stages and execution when an earlier stage fails, so a failed assertion does not turn into an unsafe follow-on call.

## Verification and concerns

- Per task instruction, no build or Automation test was run.
- Final verification is limited to a scoped `git diff --check` for the two plugin files and this handoff.
- The new source-reporting helper introduces a generated-source reporting site in `AngelscriptNativeBuilderDependencyTests.cpp`. The task explicitly prohibited editing `catalogs/generated-source-registry.csv`; the coordinating change owner must add or reconcile that registry entry separately if the catalog validator requires it.
- Compile/runtime behavior remains unverified until the coordinating batch performs its planned build and narrow Compiler test run.
