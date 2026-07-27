# Operator Responsibility Split Implementation Plan

**Goal:** Give each of the fourteen operator products in the four reviewed mixed-responsibility sources one subject-specific C++ owner file without changing any registered behavior.

**Architecture:** Keep the first positive owner in each existing source and move each remaining product owner into a new `.cpp`. Each destination retains the original Automation path and copies the complete transitive set of class-private declarations used by its unchanged `TEST_METHOD`. Shared declarations remain local copies when needed by more than one owner so native callbacks and fixture state remain translation-unit-local.

**Tech stack:** Unreal Engine CQTest, raw AngelScript SDK fixtures, PowerShell catalog/reconciliation scripts, OpenSpec CSV/PSD1 records.

## Global constraints

- Preserve every `TEST_METHOD`, Automation path, `AS_NATIVE_PRODUCT` ID, generated case ID, printed source, native registration, assertion, and cleanup path.
- Move complete helper/type declaration blocks without rewriting their behavior.
- One product owner per subject-specific `.cpp`.
- Do not create a worktree.
- Do not build or run automation tests.
- Apply source and record changes with `apply_patch`.

## Exact owner map

| Product | Destination file | Destination class | Method |
|---|---|---|---|
| `LANG-OP-ASSIGNMENT` | `Language/Operators/AngelscriptNativeAssignmentOperatorTests.cpp` | `FAssignmentOperatorTests` | `TypesByOperatorAndCategory` |
| `LANG-OP-ASSIGNMENT-TARGET-REJECTION` | `Language/Operators/AngelscriptNativeAssignmentTargetRejectionTests.cpp` | `FAssignmentTargetRejectionTests` | `WritableTargetRejections` |
| `LANG-OP-ASSIGNMENT-TYPE-REJECTION` | `Language/Operators/AngelscriptNativeAssignmentTypeRejectionTests.cpp` | `FAssignmentTypeRejectionTests` | `TypeRejections` |
| `LANG-OP-COMPARISON-FLOAT` | `Language/Operators/AngelscriptNativeComparisonOperatorTests.cpp` | `FComparisonOperatorTests` | `FloatingTypesByOperatorValueAndOrder` |
| `LANG-OP-COMPARISON-ENUM-ALIAS` | `Language/Operators/AngelscriptNativeEnumAliasComparisonOperatorTests.cpp` | `FEnumAliasComparisonOperatorTests` | `EnumAndAliasByOperatorPairAndOrder` |
| `LANG-OP-COMPARISON-REFERENCE` | `Language/Operators/AngelscriptNativeReferenceComparisonOperatorTests.cpp` | `FReferenceComparisonOperatorTests` | `ReferencesByOperatorRelationAndOrder` |
| `LANG-OP-COMPARISON-OVERLOAD` | `Language/Operators/AngelscriptNativeOverloadedComparisonOperatorTests.cpp` | `FOverloadedComparisonOperatorTests` | `OverloadsByOperatorRelationOrderAndReceiver` |
| `LANG-OP-INCREMENT` | `Language/Operators/AngelscriptNativeIncrementOperatorTests.cpp` | `FIncrementOperatorTests` | `TypesByOperatorCategoryAndObservation` |
| `LANG-OP-INCREMENT-TARGET-REJECTION` | `Language/Operators/AngelscriptNativeIncrementTargetRejectionTests.cpp` | `FIncrementTargetRejectionTests` | `WritableTargetRejections` |
| `LANG-OP-INCREMENT-TYPE-REJECTION` | `Language/Operators/AngelscriptNativeIncrementTypeRejectionTests.cpp` | `FIncrementTypeRejectionTests` | `BoolTypeRejections` |
| `LANG-OP-OVERLOAD-INTEGER-CONSUMER` | `Language/Operators/AngelscriptNativeOverloadedOperatorTests.cpp` | `FOverloadedOperatorTests` | `IntegerResultsByScenarioAndConsumer` |
| `LANG-OP-OVERLOAD-BOOLEAN-CONSUMER` | `Language/Operators/AngelscriptNativeOverloadedBooleanConsumerTests.cpp` | `FOverloadedBooleanConsumerTests` | `BooleanResultsByScenarioAndConsumer` |
| `LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER` | `Language/Operators/AngelscriptNativeOverloadedAssignmentConsumerTests.cpp` | `FOverloadedAssignmentConsumerTests` | `AssignmentResultsByScenarioAndConsumer` |
| `LANG-OP-OVERLOAD-DUPLICATE-DECLARATION` | `Language/Operators/AngelscriptNativeOverloadedDuplicateDeclarationTests.cpp` | `FOverloadedDuplicateDeclarationTests` | `DuplicateDeclarationsByFamily` |

## Tasks

### 1. Materialize the fourteen source owners

- [ ] Parse each reviewed class into complete top-level member declarations.
- [ ] Compute each owner method's transitive declaration dependency set.
- [ ] Rebuild the four existing files with only their retained product owner.
- [ ] Add the ten destination files with the unchanged owner method and required declaration set.
- [ ] Confirm every generated-source reporting call and case-ID constructor is present in the corresponding destination.

### 2. Update authoritative owner records

- [ ] Change the fourteen `Owner` values in `catalogs/coverage-products.psd1`.
- [ ] Change the fourteen file/class values in `catalogs/generated-source-registry.csv`.
- [ ] Change source-path owner references in authoritative predecessor dispositions and reviewed language assertion records.
- [ ] Replace the four mixed-responsibility quality-review rows with current rows for all fourteen destination files.

### 3. Reconcile static records

- [ ] Expand the product catalog so expected IDs and cardinality owners use the new paths.
- [ ] Run source reconciliation into the current audit outputs.
- [ ] Refresh method/file/assertion inventories needed by the reconciliation scripts.
- [ ] Confirm all fourteen products resolve to one exact owner and all generated builders/reporting sites resolve in their destination files.

### 4. Static verification

- [ ] Run `git diff --check` for the fourteen source files and changed records.
- [ ] Compare pre/post method names, Automation paths, product IDs, case-ID strings, source-print calls, assertion counts, raw-engine creation/destruction, context creation/release, and module discard markers.
- [ ] Confirm each source contains exactly one `AS_NATIVE_PRODUCT`.
- [ ] Confirm the four obsolete multi-owner source shapes no longer exist.
- [ ] Record that no build or automation test was executed.
