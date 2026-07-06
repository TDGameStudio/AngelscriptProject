# ClassGenerator Test Hygiene Audit

## Scope

This note belongs to `refactor-as-generator-artifact-boundaries` and tracks `Documents/UnitTest/UnitTest.md` conformance work for `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator` before the generator artifact split relies on these tests as regression coverage.

## Normalized Batches

### Batch 1 — default statement safety

- `AngelscriptDefaultStatementSafetyTests.cpp`
  - moved engine creation/reset to class-level CQTest lifecycle
  - kept per-method module cleanup local
  - replaced raw `TEXT(R"AS")` fixtures with `ASTEST_AS(R"AS(... )AS")`
  - preserved diagnostics coverage for unsafe construction/defaults-only access

### Batch 2 — small artifact/lifecycle tests

- `AngelscriptASClassTickSettingsTests.cpp`
- `AngelscriptASStructDiscardTests.cpp`
- `AngelscriptASGeneratedTypeIdentityTests.cpp`
- `AngelscriptASClassReplicationTests.cpp`
- `AngelscriptASFunctionWorldContextTests.cpp`
- `AngelscriptInterfaceDispatchBridgeTests.cpp`

Applied shape:

```text
TEST_CLASS_WITH_FLAGS
  private narrow constants/helpers
  public BEFORE_ALL / AFTER_ALL
  TEST_METHOD
    ASTEST_GET_ENGINE
    FAngelscriptEngineScope
    ON_SCOPE_EXIT
      discard modules / local files only
    ASTEST_AS inline fixture
    same public artifact/runtime assertions
```

### Batch 3 — script class / struct lifecycle and hot reload

- `AngelscriptScriptStructHotReloadTests.cpp`
- `AngelscriptScriptClassStructureTests.cpp`
- `AngelscriptLiteralAssetPostInitTests.cpp`
- `AngelscriptComposeOntoClassTests.cpp`

Applied shape:

```text
TEST_CLASS_WITH_FLAGS
  public BEFORE_ALL / AFTER_ALL
  TEST_METHOD
    ASTEST_GET_ENGINE
    FAngelscriptEngineScope
    ON_SCOPE_EXIT
      discard module and generated script file state only
    ASTEST_AS inline fixture
    same generated UClass/UASStruct/runtime artifact assertions
```

Intentional isolation exceptions:

- `AngelscriptScriptClassCreationTests.cpp`
- `AngelscriptScriptClassShapeTests.cpp`

These tests keep per-method clean shared-clone acquisition through `AcquireFreshScriptClassEngine()` because they validate script class publication, blueprint child creation, and generated-class shape in scenarios where stale global engine/class state changes the observable result. The methods still use explicit `FAngelscriptEngineScope`, block-form `ON_SCOPE_EXIT`, local module cleanup, and `ASTEST_AS` fixtures.

### Batch 4 — ASFunction behavior matrices

- `AngelscriptASFunctionProcessEventTests.cpp`
- `AngelscriptASFunctionOptimizedCallTests.cpp`
- `AngelscriptASFunctionDispatchTests.cpp`
- `AngelscriptASFunctionMetadataTests.cpp`
- `AngelscriptASFunctionArgumentMatrixTests.cpp`

Applied shape:

```text
TEST_CLASS_WITH_FLAGS
  private narrow constants/helpers or file-local helper namespace
  public BEFORE_ALL / AFTER_ALL
  TEST_METHOD
    ASTEST_GET_ENGINE
    FAngelscriptEngineScope
    ON_SCOPE_EXIT
      discard only the modules compiled by the method
    ASTEST_AS inline fixture
    explicit AngelscriptFunctionalTestUtils:: helper ownership
    same UASFunction dispatch/process-event/metadata assertions
```

No intentional per-test clean-engine exceptions were added in this batch. The files keep the existing `Angelscript.TestModule.ClassGenerator.ASFunction` automation prefix so they remain the behavior guard for the later `UASFunction` and dispatch-variant split.
### Batch 5 — ASClass metadata/reference/construction helpers

- `AngelscriptASClassHelperTests.cpp`
- `AngelscriptASClassReferenceSchemaTests.cpp`
- `AngelscriptASClassMetadataTests.cpp`
- `AngelscriptASClassConstructionContextTests.cpp`

Applied shape:

```text
TEST_CLASS_WITH_FLAGS
  private existing helper namespace or class-local helpers
  public BEFORE_ALL / AFTER_ALL
  TEST_METHOD
    ASTEST_GET_ENGINE
    FAngelscriptEngineScope
    ON_SCOPE_EXIT
      discard only the modules compiled by the method
      preserve transient UObject/Blueprint/GC cleanup
    ASTEST_AS inline fixture
    explicit AngelscriptFunctionalTestUtils:: helper ownership only for functional utilities
    same UASClass helper/reference-schema/metadata/construction-context assertions
```

No intentional per-test clean-engine exceptions were added in this batch. The reference-schema soft-reload test keeps its existing single-method reload chain because the observable contract is state stability across repeated reloads within one engine.

### Batch 6 — ASClass construction/component behavior matrices

- `AngelscriptASClassObjectConstructionTests.cpp`
- `AngelscriptASClassActorConstructionTests.cpp`
- `AngelscriptASClassComponentConstructionTests.cpp`
- `AngelscriptASClassComponentMetadataTests.cpp`

Applied shape:

```text
TEST_CLASS_WITH_FLAGS
  private existing constants/helpers or file-local helper namespace
  public BEFORE_ALL / AFTER_ALL
  TEST_METHOD
    ASTEST_GET_ENGINE
    FAngelscriptEngineScope
    ON_SCOPE_EXIT
      discard only the modules compiled by the method
      preserve transient UObject/component/actor/GC cleanup
    ASTEST_AS inline fixture
    explicit AngelscriptFunctionalTestUtils:: helper ownership only for functional utilities
    same UASClass constructor/default-component/soft-reload assertions
```

No intentional per-test clean-engine exceptions were added in this batch. The component metadata soft-reload test keeps its reload sequence inside one method because the observable contract is metadata stability across a body-only reload.

### Batch 7 — helper ownership cleanup for early hygiene files

- `AngelscriptASClassTickSettingsTests.cpp`
- `AngelscriptASClassReplicationTests.cpp`
- `AngelscriptASFunctionWorldContextTests.cpp`
- `AngelscriptInterfaceDispatchBridgeTests.cpp`

Applied shape:

```text
TEST_METHOD
  no broad AngelscriptFunctionalTestUtils namespace import
  explicit AngelscriptFunctionalTestUtils:: qualification for functional utilities
  global test helpers remain unqualified
  same ASClass/ASFunction/interface dispatch assertions
```

No lifecycle or behavior changes were added in this batch. `FindGeneratedClass`, `FindGeneratedFunction`, compile helpers from the shared test layer, and `FScopedTestWorldContextScope` remain global/shared helpers rather than functional utilities.

### Batch 8 — generator entrypoint and residual high-risk scan

- `ClassGeneratorTests.cpp`

Applied shape:

```text
TEST_CLASS_WITH_FLAGS
  public BEFORE_ALL / AFTER_ALL
  TEST_METHOD
    ASTEST_GET_ENGINE
    FAngelscriptEngineScope
    same empty-module class-generator setup assertions
```

The test no longer bypasses the shared CQTest lifecycle through production-engine discovery or direct shared-clone acquisition. The root `Angelscript.TestModule.ClassGenerator` entrypoint now follows the same engine ownership shape as the artifact behavior suites.

### Batch 9 — local namespace and shared-helper ownership cleanup

- `AngelscriptInterfaceDispatchBridgeTests.cpp`
- `AngelscriptASClassReplicationTests.cpp`
- `AngelscriptLiteralAssetPostInitTests.cpp`
- `AngelscriptASStructDiscardTests.cpp`
- `AngelscriptASGeneratedTypeIdentityTests.cpp`
- `AngelscriptScriptClassStructureTests.cpp`
- `AngelscriptASFunctionDispatchTests.cpp`
- `AngelscriptASFunctionProcessEventTests.cpp`
- `AngelscriptASFunctionOptimizedCallTests.cpp`
- `AngelscriptScriptStructHotReloadTests.cpp`
- `AngelscriptScriptClassCreationTests.cpp`
- `AngelscriptScriptClassShapeTests.cpp`
- `AngelscriptComposeOntoClassTests.cpp`

Applied shape:

```text
TEST_METHOD
  no method-local using namespace imports
  explicit file-local helper namespace qualification where ownership is local to the file
  explicit AngelscriptFunctionalTestUtils:: qualification only for functional utilities
  generated-artifact helpers remain global/shared helpers
  same compile/reload/dispatch/class-shape assertions
```

No lifecycle, isolation, prefix, or behavior assertion changes were added in this batch. The cleanup keeps intentional per-test clean-engine semantics in `AngelscriptScriptClassCreationTests.cpp` and `AngelscriptScriptClassShapeTests.cpp` while removing local namespace imports that obscured helper ownership.

## Structural Cohesion Closure Batches

Batch 1–9 removed hard hygiene violations and helper-ownership ambiguity, but they did not fully close the `UnitTest.md` structure-cohesion rule for all movement-guard tests. The following batches are now the authoritative cleanup scope before artifact movement.

### Closure Batch A — high-priority generated-artifact guards

- `AngelscriptASFunctionOptimizedCallTests.cpp`
- `AngelscriptASFunctionDispatchTests.cpp`
- `AngelscriptASFunctionProcessEventTests.cpp`
- `AngelscriptASGeneratedTypeIdentityTests.cpp`
- `AngelscriptASClassReferenceSchemaTests.cpp`
- `AngelscriptLiteralAssetPostInitTests.cpp`

Required shape:

```text
TEST_CLASS_WITH_FLAGS
  private constants, observation structs, and helpers used only by that class
  public BEFORE_ALL / AFTER_ALL / TEST_METHOD
  TEST_METHOD
    keeps compile source, reload sequence, and expected assertions visible in the main flow
    uses shared generated-artifact helpers only where ownership is truly shared
    avoids file-level helper namespaces for one-class-only helpers
```

### Closure Batch B — script class and metadata namespace/helper externalization

- `AngelscriptASClassMetadataTests.cpp`
- `AngelscriptScriptClassStructureTests.cpp`
- `AngelscriptScriptClassShapeTests.cpp`
- `AngelscriptScriptClassCreationTests.cpp`
- `AngelscriptComposeOntoClassTests.cpp`
- `AngelscriptScriptStructHotReloadTests.cpp`

Required shape:

```text
TEST_CLASS_WITH_FLAGS
  class-local helper ownership where helpers serve one CQTest class
  documented per-test clean-engine exception remains only for creation/shape semantics
  script fixtures stay near the scenario unless repeated data generation is the clearer boundary
```

### Closure Batch C — ASClass construction family

- `AngelscriptASClassActorConstructionTests.cpp`
- `AngelscriptASClassComponentConstructionTests.cpp`
- `AngelscriptASClassObjectConstructionTests.cpp`
- `AngelscriptASClassConstructionContextTests.cpp`
- `AngelscriptASClassHelperTests.cpp`

Required shape:

```text
TEST_CLASS_WITH_FLAGS
  construction/default-object/component helpers owned by the class that consumes them
  actor/component/world cleanup remains explicit in each scenario
  helper extraction hides lookup and cleanup noise, not constructor/default-component assertions
```

### Closure Batch D — light residual cleanup

- `AngelscriptASStructDiscardTests.cpp`
- `AngelscriptASClassReplicationTests.cpp`
- `AngelscriptInterfaceDispatchBridgeTests.cpp`

Required shape:

```text
TEST_CLASS_WITH_FLAGS
  remove remaining one-class-only file-local helper wrappers when present
  keep existing public behavior assertions and automation prefixes unchanged
```

## Remaining Risk Buckets

Current scan after Closure Batch D no longer shows method-level engine lifecycle, raw `TEXT(R"AS")` fixtures, old `_AutoEngineScope` wrappers, broad functional-test namespace imports, method-local namespace imports, legacy automation macros, production-engine fallback, direct shared-clone acquisition, misqualified generated-artifact shared helpers, or one-class-only file-level helper namespaces in `ClassGenerator`.

The closure batches above are now applied for the movement-guard tests. Remaining structure debt is limited to documented isolation exceptions and high-risk movement guards that were not part of this cohesion pass.

The files below remain high-risk movement guards because they cover compile/reload planning and diagnostics, not because a hard hygiene violation remains:

- `AngelscriptAdditionalCompileChecksTests.cpp`
- `AngelscriptClassGeneratorReloadPropagationTests.cpp`
- `AngelscriptClassGeneratorNameConflictTests.cpp`
- `AngelscriptClassGeneratorInterfaceListTests.cpp`
- `AngelscriptComponentMetadataValidationTests.cpp`

## Refactor Rule

Do not combine hygiene with behavior changes. Each batch should only normalize lifecycle and inline fixture shape, then run the narrowest matching `Angelscript.TestModule.ClassGenerator.*` prefix before those tests are used as guards for artifact movement.