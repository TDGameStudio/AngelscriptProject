# Module Core Assertion-Depth Implementation Handoff

## Scope

This implementation deepens the direct assertions for the nine Module `ChangeRequired` products assigned to this handoff. `MOD-MODULE-API-CONTRACT` / `ModuleApiContractTests` is intentionally excluded.

No build or automation tests were run, per the task boundary. Static checks performed are recorded below.

## Implementation policy

- The catalogued exact owner remains the sole `AS_NATIVE_PRODUCT(...)` declaration for each product.
- Existing supporting methods are attached to the exact catalog scenario through `AS_NATIVE_PRODUCT_PART(...)`.
- Methods that previously combined independent scenarios were split so each scenario owns its setup and direct API result.
- Cleanup and isolation are asserted through explicit discard, post-discard name lookup, the fork's retained indexed-inventory contract, independent-engine, or cross-engine publication checks. Scope guards remain fallback cleanup, not the asserted oracle.
- Runtime paths assert exact return values. Metadata paths assert exact declarations, names, namespaces, table counts, storage, or identities. Failure paths assert exact API failures where stable and verify that no partial tables remain published.
- Generated AngelScript in the bytecode restore owner and helper continues to be printed through `PrintGeneratedAsSource`; inline literal fixtures remain normalized through `ASTEST_AS_ANSI`.

## Product evidence

### MOD-BYTECODE-STREAM-RESTORE

Owner: `FRestorePrimitiveTests.CopyScriptSaveDeterminismAndCurrentForkLoadRestriction`

- `primitive_round_trip`: source execution, framed bytecode save/load, debug-info preservation, exact restored function/global inventory, explicit global initialization, restored execution returning `42`, and explicit removal.
- `debug_info_stripped_round_trip`: stripped flag, restored global initialization, restored execution returning `42`, and explicit removal.
- `empty_stream_rejected`: failed load plus empty function/global/object/enum/typedef/import tables and explicit removal.
- `truncated_stream_rejected`: truncated current stream rejection plus empty publication tables and explicit removal.
- `failed_load_leaves_module_clean`: empty publication tables after failure, explicit failed-module removal, same-name complete-stream retry, global reset, execution returning `42`, and final removal.
- `legacy_version_one_rejected`: framed version-byte mutation from `2` to `1`, rejection, empty publication tables, and explicit removal.
- Owner scenario: executes the `asBC_CopyScript` function and returns `73`, checks lifecycle recorder balance, proves identical output across two distinct engines, verifies the exact shared `$obj` rejection diagnostic, verifies all destination tables remain empty, and explicitly clears both engine/module states.

### MOD-FUNCTION-INVENTORY-RUNTIME

Owner: `FModuleFunctionTests.EnumerateFunctions`

- Owner asserts exact function count and declaration order (`Alpha`, `Beta`, `Gamma`), exact lookup, runtime results `1/2/3`, explicit context prepare/execute/return/unprepare, explicit module discard, and independent-engine non-publication.
- `scalar_return_types` executes the declared bool, signed/unsigned integer, float-slot, and double return cases.
- `argument_return_round_trip` executes signed integer, `uint64`, floating, and boolean argument/return paths with exact values.

### MOD-GLOBAL-STATE-LIFECYCLE

Owner: `FModuleGlobalTests.ModuleGlobalEnumerate`

- Owner asserts the exact order, names, declarations, empty namespaces, type IDs, const flags, storage, initialized `d == 0xC0DE`, execution through the supported `int32` execution helper reading the same unsigned storage, explicit discard, and independent-engine non-publication.
- `reset_preserves_inventory` verifies that `ResetGlobalVars` succeeds, declarations remain indexed, and this fork's pure-constant storage mutations remain observable.
- `remove_reindexes_inventory` verifies only the selected global is removed, the retained declaration moves to index zero, and its initialized storage remains `2`.

### MOD-IMPORT-BINDING-CONTRACT

Owner: `FModuleImportTests.ImportMetadataBeforeBinding`

- Owner asserts the unbound import count, index, exact declaration, exact provider module, explicit consumer removal, and independent-engine non-publication.
- `manual_bind_execute` asserts compatible manual bind success, provider execution returning `77`, and retained import inventory.
- `signature_mismatch_rejected` independently asserts `asINVALID_INTERFACE` and retained import metadata.
- `invalid_index_rejected` independently asserts `asINVALID_ARG` for index `7` and preservation of the valid slot.
- `unbind_rebind_execute` executes provider A (`11`), unbinds, binds provider B, executes `29`, and verifies declaration preservation.
- `bind_all_missing_rejected` independently asserts `asCANT_BIND_ALL_FUNCTIONS` and retained missing import state.
- `bind_all_execute` independently asserts automatic binding success and execution returning `42`.

### MOD-LIFECYCLE-REBUILD-ISOLATION

Owner: `FModuleLifecycleTests.ModuleLifecycleCreate`

- Owner builds and executes `Entry`, explicitly discards the module, asserts name-lookup removal, and directly retains the current fork's indexed module count and exact indexed module identity. It also proves an independent engine has no same-name publication.
- `discard_existing`: pre-discard execution, exact `asSUCCESS`, missing name lookup, unchanged indexed inventory count, retained indexed module identity, and an explicit fork-limitation record.
- `discard_missing`: exact `asNO_MODULE` and unchanged inventory.
- `parallel_name_isolation`: distinct function identities and independent runtime values for two module names.
- `always_create_replacement`: distinct module/function identities and latest-body execution.
- `discard_recompile`: discard lookup removal, replacement module/function identities, and latest-body execution.
- `discard_rebuild_function_and_type_identity`: distinct replacement module, function, and type identities plus replacement-only type publication and exact runtime values.

### MOD-NAMESPACE-LOOKUP-CONTRACT

Owner: `FModuleNamespaceTests.DefaultNamespaceDoesNotRehomeDeclarations`

- Owner verifies the default namespace does not rehome an unqualified function, global, or class; verifies exact namespace readback; explicitly discards; and proves independent-engine non-publication.
- `explicit_namespace_qualified_lookup` verifies global versus `Tools` function namespaces, qualified type lookup, and rejection of unqualified lookup.
- `invalid_default_preserves_previous` asserts exact `asINVALID_DECLARATION` and preservation of the prior `Valid` namespace.

### MOD-SAVELOAD-FUNCTION-RESTORE

Owner: `FModuleSaveLoadTests.RoundTripPreservesFunctionDeclarations`

- The shared execution helper now explicitly unprepares every context before release.
- Owner executes the source result `42`, saves non-empty bytecode, explicitly removes the source, verifies debug state and exact restored declarations/count, executes the restored result `42`, explicitly removes it, and proves independent-engine non-publication.
- `stripped_debug_flag`: exact stripped flag plus restored execution returning `42`.
- `truncated_then_complete_retry`: failed-load empty tables, explicit failed-module removal, same-name complete retry, and execution returning `42`.
- `multi_function_restore_execute`: exact three-function inventory and independent restored execution of `Left == 20`, `Right == 22`, and `Entry == 42`.

### MOD-SECTION-BUILD-DIAGNOSTIC

Owner: `FModuleSectionTests.SyntaxErrorReportsSectionAndOffset`

- Owner asserts a diagnostic at exact section `SectionDiagnostic.as` and exact row `20` (source row `3` plus offset `17`), verifies all public module tables remain empty after build failure, explicitly removes the failed module, and proves both module and diagnostic isolation in a distinct engine.
- `declaring_section_metadata`: exact `Helpers.as` / `Entry.as` function metadata plus execution returning `42`.
- `single_section_pipeline`: successful single-section execution returning `42`.
- `multi_section_call`: two-section build and cross-section call returning `30`.
- `cross_section_symbol`: sibling-section symbol resolution returning `42`.

### MOD-STATE-TABLE-REBUILD

Owner: `FModuleStateTableTests.RichModuleStoresTopLevelTablesAndExecutesEntry`

- Owner asserts exact function/global/object/enum/typedef inventories, namespace and global declaration metadata, storage, namespaced runtime result `47`, explicit removal, and independent-engine non-publication.
- `rebuild_clears_previous_tables`: captures version-one module/function/object/enum identities and global value, rebuilds under the same name, verifies replacement identities, removes every old lookup/table entry, verifies the new global index/value and exact table counts, executes `202`, and explicitly removes the replacement.

## Static verification

Performed without compiling or running tests:

- `git -C Plugins/Angelscript diff --check -- <nine scoped Module test files>`: passed; only existing line-ending conversion warnings were reported.
- Scoped macro scan: all supporting scenarios use `AS_NATIVE_PRODUCT_PART`; no `AS_NATIVE_NON_PRODUCT` remains in the nine files.
- Scoped naming scan: no new `TEST_METHOD` contains the forbidden generic theme term.
- Product ownership scan: one `AS_NATIVE_PRODUCT` remains in each catalogued exact owner.
- Independent review then found and repaired two blocking static defects: the unsupported `ExecuteScriptFunction<uint32>` call now uses the existing `int32` specialization with an explicit unsigned comparison, and both lifecycle discard scenarios now assert the already confirmed `AS-FORK-DEFECT-003` name/index distinction rather than a false inventory decrement.
- Every new independent-engine observation now installs immediate destruction fallback and returns before dereference if creation fails; the duplicate import-test macro include was removed.

## Residual risks

- The exact section diagnostic row (`20`) is derived from normalized source row `3` plus `AddScriptSection` offset `17`; it requires the intentionally deferred automation run to confirm this fork reports the offset with that exact convention.
- Several bytecode load failure codes are intentionally asserted as non-success rather than a single numeric code because the catalog requires rejection and atomic cleanup, while the fork may distinguish malformed stream shapes internally.
- The current CopyScript loader rejection remains a declared fork restriction. The owner now proves deterministic serialization, exact diagnostic text, runtime behavior before serialization, and atomic cleanup; it does not convert the restriction into a successful restore.
- Compilation/API compatibility and runtime behavior remain unconfirmed because build and tests were explicitly out of scope.
