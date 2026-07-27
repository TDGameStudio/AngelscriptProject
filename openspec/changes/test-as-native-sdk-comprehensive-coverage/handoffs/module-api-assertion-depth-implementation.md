# Module API assertion-depth implementation handoff

## Scope

- Modified source: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Module/AngelscriptNativeModuleApiContractTests.cpp`.
- Reviewed without modifying: `handoffs/assertion-depth-runtime-module-review.csv` and the matching rows in `catalogs/coverage-products.psd1`.
- No build or UE/SDK test was run by instruction. Static verification only is recorded below.

## Exact-owner coverage added

| Product | Exact Owner | Direct lifecycle / cleanup oracle added |
|---|---|---|
| `MOD-API-RENAME-REINDEX` | `RenameReindexesEngineLookup` | Discards by the new name, asserts the renamed lookup is null, prints a distinct rebuild record, rebuilds the same name, executes the restored exact declaration, discards again, and asserts no stale lookup. |
| `MOD-API-COMPILE-FUNCTION` | `CompileFunctionDetachedAttachedAndInvalid` | Asserts both returned external function references release to zero. After invalid flags and null-source calls, directly proves the original module count, exact lookup, and attached function identity are unchanged. It then explicitly discards the owner module, checks lookup removal, creates a same-name clean module with zero functions, and discards it. |
| `MOD-API-REMOVE-FUNCTION` | `RemoveFunctionPreservesExternalOwnership` | Asserts the externally retained removed function reaches final `Release() == 0`; explicitly discards owner and foreign modules and verifies both lookups are null. |
| `MOD-TYPEDEF-INVENTORY-BOUNDS` | `TypedefInventoryUsesForkEmptyBoundary` | Directly asserts the rejected module itself publishes zero typedefs and returns null at index zero, then repeats the empty-module boundary control. Explicitly discards both rejected and empty modules and verifies both engine lookups are null. |
| `MOD-IMPORT-UNBIND-ALL` | `UnbindAllImportsThenRebinds` | Gives each imported slot its own wrapper and separately requires the exact unbound-function exception after unbind-all. Exception text is nullable-guarded, and each context is unprepared and released. A zero-import module executes `LocalOnly() == 97` before and after unbind-all. The consumer rebind executes cleanly, then empty, consumer, and provider modules are explicitly discarded and all lookups are verified null. |
| `MOD-PRECLASS-METADATA-APPLICATION` | `PreClassMetadataAppliesOnlyToExactDeclaration` | Explicitly discards the owner module, verifies name removal, and directly observes that the application-owned `InitialUserData.Value` remains `101`. It creates a clean same-name module with neither old type, discards it, re-observes the token, and asserts no stale lookup. The module stores the supplied user-data pointer non-owningly; no callback or ownership transfer is fabricated. |
| `MOD-NESTED-IMPORT-VISIBILITY` | `NestedImportModuleVisibilityAndDeduplication` | Validates both resolved imported functions are non-null and executes them for exact `103` and `101` results; the shared raw execution path observes its context release; explicitly discards consumer/provider/base and verifies all name lookups are null. |

## Fork-specific behavior retained

- Script-level `typedef` remains rejected in this fork; the test continues to require the parser diagnostic containing `Expected identifier` and directly verifies that the rejected module has no partially published typedef inventory.
- `asCModule::CompileFunction` adds an external reference before returning the function. The new final `Release() == 0` assertions intentionally exercise that caller-owned reference baseline; attached functions remain represented by the module inventory until its explicit discard.
- `ImportModule` is a `void` API in the current fork. Its observable behavior remains direct function identity plus actual execution; no synthetic return-code assertion was added.

## Static verification performed

- Confirmed all seven product IDs remain bound to their specified existing Exact Owner methods.
- Inspected all newly added cleanup sequences for explicit `Discard` / `DiscardModule` result assertions followed by engine lookup null assertions; none rely only on scope destruction.
- Confirmed new nullable function/module/context pointers are asserted before dereference, and updated the class-private execution helper to observe its case-owned context `Release()` result rather than silently discarding it.
- Rechecked the independent review findings: failed `CompileFunction` calls now prove non-mutation on the affected module; typedef rejection is observed on the failed module; both import slots and the zero-import control execute independently; application-owned pre-class user data is observed after discard and same-name recreation.
- Every compilation of the rename source now has a stable printed record, including the same-source new-name rebuild.
- The target source is currently an untracked file in the `Plugins/Angelscript` submodule, so it has no repository baseline for ordinary scoped `git diff`. A `git diff --no-index --check` comparison against the empty path emitted no whitespace diagnostics (its non-zero diff status is expected for an untracked source).
- Build/test verification: intentionally not run. Compiler and runtime behavior therefore remain pending the allowed narrow SDK run.

## Risks / next verification

The cleanup assertions use current raw SDK lifecycle conventions (`Release() == 0` for the caller-owned function/context external reference and `DiscardModule` hiding the name immediately). When execution is permitted, run the narrow `Angelscript.TestModule.AngelScriptSDK.Module.ApiContracts` prefix first, then the full `Angelscript.TestModule.AngelScriptSDK` prefix. If a fork-specific count differs, retain the observed source-backed contract and update this handoff with the exact result rather than weakening the oracle.
