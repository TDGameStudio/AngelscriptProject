# Compiler Layout, Lifecycle, and Parse Implementation Handoff

## Scope

Implemented the three exact Compiler product owners declared by
`catalogs/coverage-products.psd1`:

- `COMPILER-BUILDER-CLASS-LAYOUT`
  - `Compiler/AngelscriptNativeBuilderLayoutTests.cpp`
  - `FBuilderLayoutTests::ClassLayoutsPreserveInheritanceInitializersAndOverloads`
- `COMPILER-BUILDER-LIFECYCLE`
  - `Compiler/AngelscriptNativeBuilderLifecycleTests.cpp`
  - `FBuilderLifecycleTests::BuilderLifecycleClearsTransientStateAndRebuilds`
- `COMPILER-BUILDER-PARSE-STAGE`
  - `Compiler/AngelscriptNativeBuilderParsingTests.cpp`
  - `FBuilderParsingTests::ParseStageRetainsRootsAndBlocksDownstreamPublication`

No catalog, task, reconciliation, runtime, or unrelated test file was changed by
this batch.

## Implemented evidence

### Class layout

- Registers the exact product owner and all seven declared evidence layers.
- Emits all six shape/stage case IDs:
  - inheritance × layout/code
  - property initializer × layout/code
  - method overload × layout/code
- Prints the complete generated source for every case ID.
- The combined source actually exercises:
  - exact `BaseCounter`/`Counter` inheritance;
  - inherited and declared initialized properties;
  - integer and float method overloads;
  - a runtime path that reads both initialized properties and dispatches both
    overloads.
- Before `BuildCompileCode`, the owner checks base identity, property layout,
  and both exact overload declarations.
- After code generation, it checks exact `Entry` publication, non-empty
  bytecode, retained type/function metadata, and exact runtime result `42`.
- The three former focused methods are retained as
  `LegacyCompatibility` and each prints its complete source. They no longer
  compete for product ownership.

### Builder lifecycle

- Registers the exact product owner and its six declared evidence layers.
- Emits all nine operation/phase case IDs:
  - module success × before/after/rebuild
  - module failure × before/after/rebuild
  - standalone reset × before/after/rebuild
- Prints the complete valid or invalid source associated with each case ID.
- Proves that:
  - adding valid source creates a transient module builder;
  - successful `Module::Build` releases that builder and publishes executable
    `Entry` bytecode;
  - invalid source fails, retains a diagnostic, releases the failed builder,
    and publishes no functions;
  - a replacement module under the same owned name builds and publishes clean
    executable bytecode;
  - standalone `Reset` clears `scriptsParsed`, error count, and warning count
    while preserving its owned parser instances.
- The former success, standalone-reset, and stage-failure methods are retained
  as source-backed `LegacyCompatibility` methods. The stage-failure rationale
  explicitly separates lifecycle ownership from the parse-stage publication
  barrier.

### Parse stage

- Registers the exact product owner and all four declared evidence layers.
- Executes both declared section-count shapes:
  - one section containing namespace, class, enum, function, and global
    families;
  - two independently retained sections splitting type and function/global
    families.
- Emits and prints all ten section-count/family case IDs.
- Checks parser cardinality and non-null `snScript` roots, then checks the
  expected namespace/class/enum/function/declaration families.
- Proves that parse completion alone leaves builder class/function/global
  descriptions and module type/function/global publication tables empty.

## Method ownership result

Across the three scoped files there are nine `TEST_METHOD`s:

- 3 exact `AS_NATIVE_PRODUCT` owners;
- 6 explicit `AS_NATIVE_NON_PRODUCT("LegacyCompatibility", ...)` methods;
- 0 methods left without a product or non-product disposition.

## Static verification

Performed without building or running tests, as required for this coherent
source batch:

```powershell
git -C Plugins/Angelscript diff --check -- `
  Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeBuilderLayoutTests.cpp `
  Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeBuilderLifecycleTests.cpp `
  Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeBuilderParsingTests.cpp
```

Result: exit code `0`; no whitespace errors. Git only reported the repository's
normal future LF-to-CRLF conversion warnings.

The final scoped source diff is 324 insertions and 61 deletions. The batch
intentionally has no build/test claim.

## Required next verification stage

After the remaining coherent Compiler source batch is finished:

1. run the source-ownership, generated-source, and inline-AS audits;
2. perform one integration build for the complete batch;
3. repair compile failures together;
4. run the three narrow Compiler prefixes;
5. run the full `Angelscript.TestModule.AngelScriptSDK` prefix;
6. record exact pass/fail/Disabled, duration, generated-source, shutdown, and
   crash evidence in the OpenSpec.
